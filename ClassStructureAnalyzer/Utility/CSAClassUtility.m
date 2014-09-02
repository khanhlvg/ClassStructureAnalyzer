//
//  CSAClassUtility.m
//  ClassStructureAnalyzer
//
//  Created by Le Viet Gia Khanh on 2014/09/01.
//  Copyright (c) 2014年 Recruit. All rights reserved.
//

#import "CSAClassUtility.h"

@implementation CSAClassUtility

+ (BOOL) shouldClassHasMetaData:(NSString *)className
{
    if ([className hasPrefix:@"UI"] || [className hasPrefix:@"NS"]) {
        return NO;
    }
    
    if ([className hasSuffix:@"Controller"] || [className hasSuffix:@"View"] || [className hasSuffix:@"Cell"]) {
        return YES;
    }
    
    return NO;
}

+ (NSArray *)subArrayOf:(NSArray *)array matchString:(NSString *)matchString
{
    if ([matchString isEqualToString:@""]) {
        return [array copy];
    }
    
    NSMutableArray *ret = [NSMutableArray array];
    
    for (id item in array) {
        if ([[item class] isSubclassOfClass:[NSString class]]) {
            NSString *str = (NSString *)item;
            if ([str rangeOfString:matchString options:NSCaseInsensitiveSearch].location != NSNotFound) {
                [ret addObject:str];
            }
        }
    }
    
    return ret;
}


@end
