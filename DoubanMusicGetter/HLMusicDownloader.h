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


@protocol HLMusicDownloaderDelegate <NSObject>

- (void)musicDownloadFinished:(NSString *)musicId;

@end

@interface HLMusicDownloader : NSObject{
    
    ASINetworkQueue *requestQueue;
    
    id <HLMusicDownloaderDelegate> delegate;
    
    int downloadingCount;
    
}

@property (nonatomic,retain) id <HLMusicDownloaderDelegate> delegate;

@end
