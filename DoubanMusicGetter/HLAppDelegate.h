//
//  HLAppDelegate.h
//  DoubanMusicGetter
//
//  Created by Henry Lee on 13-1-5.
//  Copyright (c) 2013年 Henry Lee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HLMusicDownloader.h"

@interface HLAppDelegate : UIResponder <UIApplicationDelegate,HLMusicDownloaderDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
