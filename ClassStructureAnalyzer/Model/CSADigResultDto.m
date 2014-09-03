//
//  CSADigResultDto.m
//  ClassStructureAnalyzer
//
//  Created by Le Viet Gia Khanh on 2014/09/03.
//  Copyright (c) 2014年 Recruit. All rights reserved.
//

#import "CSADigResultDto.h"

@implementation CSADigResultDto

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ : %@",self.className,self.route];
}

@end
