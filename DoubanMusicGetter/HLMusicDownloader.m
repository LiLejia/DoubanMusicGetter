//
//  HLMusicDownloader.m
//  DoubanMusicGetter
//
//  Created by Henry Lee on 13-1-5.
//  Copyright (c) 2013年 Henry Lee. All rights reserved.
//

#import "HLMusicDownloader.h"


#define INFO_REQUEST 1000001

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
        downloadingCount = 0;
        
    }
    return self;
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


- (void)requestFailed:(ASIHTTPRequest *)request{
    
    NSLog(@"request failed because: %@ and tag id is %d",
          [request.error localizedDescription],request.tag);
    
}

- (void)requestRedirected:(ASIHTTPRequest *)request{
    
    NSLog(@"request redirected");
    
}

- (void)requestFinished:(ASIHTTPRequest *)request{
    
    if(request.tag == INFO_REQUEST){
        
        
        
    }
    
}

- (void)getDownloadInfo{
    
    NSString *requestPath = @"http://www.douban.com/j/app/radio/people?type=s&sid=366815&pt=9.1&channel=-3&app_name=radio_ipad&version=3&user_id=23323558&expire=1371206486&token=c5381df9e5";
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:requestPath]];
    
    request.tag = INFO_REQUEST;
    
    [requestQueue addOperation:request];

}

- (void)downloadMp3:(NSString *)mp3Path{
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:mp3Path]];
    
    request.tag = downloadingCount++;
    
    [requestQueue addOperation:request];
    
}



@end
