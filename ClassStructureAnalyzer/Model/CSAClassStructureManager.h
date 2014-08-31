//
//  ClassStructureDto.h
//  ClassStructureAnalyzer
//
//  Created by Le Viet Gia Khanh on 8/31/14.
//  Copyright (c) 2014 Recruit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSAClassStructureManager : NSObject

@property (nonatomic, readonly) NSString *sourceDirectoryPath;
@property (nonatomic, readonly) NSDictionary *dependenceStructure;
@property (nonatomic, readonly) NSArray *allSourceFileList;
@property (nonatomic) BOOL skipPods;

//initializers
- (instancetype)initWithSourceCodeDirectory:(NSString *) path;

//getters
- (NSArray *)fetchAllClassName;


- (BOOL) isFile:(NSString *)filePath containsClassCall:(NSString *)className;

@end
