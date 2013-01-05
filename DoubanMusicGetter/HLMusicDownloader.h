//
//  HLMusicDownloader.h
//  DoubanMusicGetter
//
//  Created by Henry Lee on 13-1-5.
//  Copyright (c) 2013年 Henry Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "JSON.h"


@protocol HLMusicDownloaderDelegate <NSObject>

@optional

- (void)musicDownloadFinished:(NSString *)musicId;

- (void)downLoadingMusic:(ASIHTTPRequest *)request withLenthAdd:(long long) length;

@end

@interface HLMusicDownloader : NSObject<ASIHTTPRequestDelegate,ASIProgressDelegate>{
    
    ASINetworkQueue *requestQueue;
    
    id <HLMusicDownloaderDelegate> delegate;
    
    NSMutableArray *downloadedMusicInfo;
    
    NSMutableArray *songIds;
    
    
    NSString *saveMusicFile ;
    NSString *saveImageDir ;
    NSString *saveMp3Dir ;
    
    int failedCount;
    int lastCount;
    
}

@property (nonatomic,retain) id <HLMusicDownloaderDelegate> delegate;

- (void)getDownloadInfo;

- (id)initWithDelegate:(id <HLMusicDownloaderDelegate>) aDelegate;

@end
