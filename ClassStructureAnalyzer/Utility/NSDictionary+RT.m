//
//  NSDictionary+RT.m
//  ClassStructureAnalyzer
//
//  Created by Le Viet Gia Khanh on 2014/09/08.
//  Copyright (c) 2014年 Recruit. All rights reserved.
//

#import "NSDictionary+RT.h"

@implementation NSDictionary (RT)

- (instancetype)sortedByStringKeys
{
    NSMutableArray *allKeys = [[self allKeys] mutableCopy];
    
    for (id keyStr in allKeys) {
        if (![[keyStr class] isSubclassOfClass:[NSString class]]) {
            return nil;
        }
    }
    
    [allKeys sortUsingComparator:^(NSString *firstObj, NSString *secondObj) {
        return [firstObj caseInsensitiveCompare:secondObj];
    }];
    
    NSMutableDictionary *ret = [NSMutableDictionary dictionary];
    for (NSString *keyStr in allKeys) {
        [ret setObject:[self objectForKey:keyStr] forKey:keyStr];
    }
    
    return [NSDictionary dictionaryWithDictionary:ret];
}

@end
