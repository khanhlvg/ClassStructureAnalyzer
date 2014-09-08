//
//  CSADigResultDto.h
//  ClassStructureAnalyzer
//
//  Created by Le Viet Gia Khanh on 2014/09/03.
//  Copyright (c) 2014年 Recruit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSADigResultDto : NSObject <NSCoding, NSCopying>

@property (nonatomic) NSString *className;
@property (nonatomic) NSString *route;

@end