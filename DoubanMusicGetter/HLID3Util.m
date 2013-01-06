//
//  HLID3Util.m
//  DoubanMusicGetter
//
//  Created by Henry Lee on 13-1-6.
//  Copyright (c) 2013年 Henry Lee. All rights reserved.
//

#import "HLID3Util.h"
#import "ID3Parser.h"

@implementation HLID3Util

- (void)test{
    
    NSString *notag = [[NSBundle mainBundle]pathForResource:@"10952" ofType:@".mp3"];
    NSString *paradise = [[NSBundle mainBundle]pathForResource:@"Paradise" ofType:@".mp3"];
    
    NSData *notagData = [NSData dataWithContentsOfFile:notag];
    NSError *notagError = nil;
    NSArray *notagarray = [ID3Parser parseTagWithData:notagData error:&notagError];
    if(notagError!=nil)
        NSLog(@"notagError = %@",[notagError localizedDescription]);
    else
        NSLog(@"notagError :%@",[notagarray description]);
    
    NSData *paradiseData = [NSData dataWithContentsOfFile:paradise];
    NSError *paradiseError = nil;
    NSArray *array = [ID3Parser parseTagWithData:paradiseData error:&paradiseError];
    
    if(paradiseError!=nil)
        NSLog(@"notagError = %@",[paradiseError localizedDescription]);
    else
        NSLog(@"array :%@",[array description]);

}

@end
