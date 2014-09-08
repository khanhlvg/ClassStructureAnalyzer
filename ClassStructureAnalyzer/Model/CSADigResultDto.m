//
//  CSADigResultDto.m
//  ClassStructureAnalyzer
//
//  Created by Le Viet Gia Khanh on 2014/09/03.
//  Copyright (c) 2014年 Recruit. All rights reserved.
//

#import "CSADigResultDto.h"

static NSString *const kClassName = @"classname";
static NSString *const kRoute = @"route";

@implementation CSADigResultDto

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ : %@",self.className,self.route];
}

#pragma mark - NSCopying protocol

- (id)copyWithZone:(NSZone *)zone
{
    CSADigResultDto *obj = [[CSADigResultDto allocWithZone:zone] init];
    obj.className = self.className;
    obj.route = self.route;
    return obj;
}

#pragma mark - NSCoding protocol

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self) {
        self.className = [aDecoder decodeObjectForKey:kClassName];
        self.route = [aDecoder decodeObjectForKey:kRoute];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.className forKey:kClassName];
    [aCoder encodeObject:self.route forKey:kRoute];
}

@end
