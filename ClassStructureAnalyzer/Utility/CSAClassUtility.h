//
//  CSAClassUtility.h
//  ClassStructureAnalyzer
//
//  Created by Le Viet Gia Khanh on 2014/09/01.
//  Copyright (c) 2014年 Recruit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSAClassUtility : NSObject

+ (BOOL) shouldClassHasMetaData:(NSString *)className;
+ (NSArray *)subArrayOf:(NSArray *)array matchString:(NSString *)matchString;

@end
