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
    NSMutableArray *ret;
    
    // return original array if there is no query string
    if ([matchString isEqualToString:@""]) {
        ret = [array mutableCopy];
    }
    else {
        ret = [NSMutableArray array];
        
        NSArray *matchStringArray = [matchString
                                            componentsSeparatedByCharactersInSet:[NSCharacterSet
                                                                                  characterSetWithCharactersInString:@",\n"]];
        
        for (id item in array) {
            if ([[item class] isSubclassOfClass:[NSString class]]) {
                NSString *str = (NSString *)item;
                for (NSString *singleMatchString in matchStringArray) {
                    if ([str rangeOfString:singleMatchString options:NSCaseInsensitiveSearch].location != NSNotFound) {
                        [ret addObject:str];
                        break;
                    }
                }
            }
        }
    }
    
    return [ret sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
}


@end
