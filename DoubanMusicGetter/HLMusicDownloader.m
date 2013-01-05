//
//  HLMusicDownloader.m
//  DoubanMusicGetter
//
//  Created by Henry Lee on 13-1-5.
//  Copyright (c) 2013年 Henry Lee. All rights reserved.
//

#import "HLMusicDownloader.h"


#define INFO_REQUEST 1000001
#define MP3_REQUEST 1000002
#define COVER_REQUEST 1000003

#define CONTENT_LENGTH @"Content-Length"

@implementation HLMusicDownloader
@synthesize delegate;

- (id)init{
    
    self = [super init];
    
    if(self){
    
    }
    
    return  self;
}

- (id)initWithDelegate:(id <HLMusicDownloaderDelegate>) aDelegate{
    
    self = [super init];

    if(self){
        
        requestQueue = [[ASINetworkQueue alloc]init];
        requestQueue.delegate = self;
        [requestQueue setRequestDidFinishSelector:@selector(requestFinished:)];
        [requestQueue setRequestDidFailSelector:@selector(requestFailed:)];
        [requestQueue setRequestWillRedirectSelector:@selector(requestRedirected:)];
        requestQueue.shouldCancelAllRequestsOnFailure = NO;
        requestQueue.showAccurateProgress = YES;
        self.delegate = aDelegate;
        [self start];
        
        downloadedMusicInfo = [[NSMutableArray alloc]init];
        
        songIds = [[NSMutableArray alloc]init];
        
        saveMusicFile = [[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingFormat:@"/mylovingsong.plist"] retain];
        
        NSLog(@"saveMusicFile = %@",saveMusicFile);
        
        saveImageDir = [[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]  stringByAppendingFormat:@"/image/"] retain];
        
        saveMp3Dir = [[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]  stringByAppendingFormat:@"/music/"] retain];
        
        [[NSFileManager defaultManager]createDirectoryAtPath:saveImageDir withIntermediateDirectories:YES attributes:nil error:NULL];
        
        [[NSFileManager defaultManager]createDirectoryAtPath:saveMp3Dir withIntermediateDirectories:YES attributes:nil error:NULL];
        
        failedCount = 0;
        
        lastCount = 0;
        
    }
    return self;
}

- (void)dealloc{
    self.delegate = nil;
    [downloadedMusicInfo release];
    [requestQueue release];
    [songIds release];
    [super dealloc];
}


- (BOOL)isRunning{
    return ![requestQueue isSuspended];
}

- (void)start{
    if([requestQueue isSuspended])
        [requestQueue go];
}

- (void)pause{
    [requestQueue setSuspended:YES];
}

- (void)resume{
    [requestQueue setSuspended:NO];
}

- (void)cancel{
    [requestQueue cancelAllOperations];
}

- (BOOL)hasSong:(NSString *)sid{
    for(NSString *addedSid in songIds){
        if([addedSid isEqualToString:sid])
            return YES;
    }
    return NO;
}


- (void)requestFailed:(ASIHTTPRequest *)request{
    
    NSLog(@"request failed because: %@ and tag id is %d",
          [request.error localizedDescription],request.tag);
    
}

- (void)requestRedirected:(ASIHTTPRequest *)request{
    
    NSLog(@"request redirected");
    
}

- (void)request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders{
    
    [request.userInfo setValue:[responseHeaders objectForKey:CONTENT_LENGTH] forKey:CONTENT_LENGTH];
}

- (void)request:(ASIHTTPRequest *)request incrementDownloadSizeBy:(long long)newLength{
//    NSLog(@"increment length = %lld",newLength);
    
    if(delegate && [delegate respondsToSelector:@selector(downLoadingMusic:withLenthAdd:)])
    {
        [delegate downLoadingMusic:request withLenthAdd:newLength];
    }
}


- (void)requestFinished:(ASIHTTPRequest *)request{
    
    if(request.tag == INFO_REQUEST){
        
        NSDictionary *result = [request.responseString JSONValue];
        
        NSArray *array = [result objectForKey:@"song"];
        
        [downloadedMusicInfo addObjectsFromArray:array];
        
        //{"picture":"http:\/\/img3.douban.com\/mpic\/s3845165.jpg","albumtitle":"Come Away with Me","company":"Blue Note","rating_avg":4.42071,"public_time":"2002","ssid":"ccb1","album":"\/subject\/1394747\/","like":1,"artist":"Norah Jones","url":"http:\/\/mr3.douban.com\/201301051305\/aa78f34cb12732e98fb20a067012f1cd\/view\/song\/small\/p1027778.mp3","title":"Don't Know Why","subtype":"","length":186,"sid":"1027778","aid":"1394747"}
        
        for(NSDictionary *song in array)
        {
            NSString *sid = [song objectForKey:@"sid"];
            
            //如果已经包含这个歌曲
            if([self hasSong:sid]){
                continue;
            }
            
            [downloadedMusicInfo addObject:song];
            
            [songIds addObject:sid];
            
            [self downloadMp3:song];
            
        }
        
        //527是我的歌曲
        if([songIds count]<527){
            
            [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(getDownloadInfo) userInfo:nil repeats:NO];
        }
        
        [songIds writeToFile:saveMusicFile atomically:YES];
        
    }else if(request.tag == MP3_REQUEST){
        
        NSDictionary *musicInfo = [request userInfo];
        
        NSLog(@"%@ - %@ downloaded finished. Total number is %d",[musicInfo objectForKey:@"artist"],[musicInfo objectForKey:@"title"],[songIds count]);
        
        NSData *downloadingData = [request responseData];
        
        NSString *mp3Name = [[musicInfo objectForKey:@"sid"]stringByAppendingPathExtension:@"mp3"];
        
        NSString *fileName = [saveMp3Dir stringByAppendingPathComponent:mp3Name];
        
        [downloadingData writeToFile:fileName atomically:YES];
        
    }else if(request.tag == COVER_REQUEST){
        
        NSDictionary *musicInfo = [request userInfo];
        
        NSData *downloadingData = [request responseData];
        
        NSString *imageName = [[[musicInfo objectForKey:@"picture"] lastPathComponent]stringByAppendingPathExtension:@"jpg"];
        
        [downloadingData writeToFile:[saveImageDir stringByAppendingPathComponent:imageName] atomically:YES];
    }
}

- (void)getDownloadInfo{
    
    NSString *requestPath = @"http://www.douban.com/j/app/radio/people?type=s&sid=366815&pt=9.1&channel=-3&app_name=radio_ipad&version=3&user_id=23323558&expire=1371206486&token=c5381df9e5";
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:requestPath]];
    
    request.delegate = self;
    
    request.downloadProgressDelegate = self;
    
    request.tag = INFO_REQUEST;
    
    [requestQueue addOperation:request];

}

- (void)downloadMp3:(NSDictionary *)musicInfo{
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[musicInfo objectForKey:@"url" ]]];
    
    request.tag = MP3_REQUEST;
    
    request.userInfo = musicInfo;
    
    [requestQueue addOperation:request];
    
    ASIHTTPRequest *imageRequest = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[musicInfo objectForKey:@"picture" ]]];
    
    imageRequest.tag = COVER_REQUEST;
    
    imageRequest.userInfo = musicInfo;
    
    [requestQueue addOperation:imageRequest];
    
}





@end
