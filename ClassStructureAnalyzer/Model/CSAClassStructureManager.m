//
//  ClassStructureDto.m
//  ClassStructureAnalyzer
//
//  Created by Le Viet Gia Khanh on 8/31/14.
//  Copyright (c) 2014 Recruit. All rights reserved.
//

#import "CSAClassStructureManager.h"

@interface CSAClassStructureManager()
{
    NSArray *_allSourceFileList;
    NSMutableDictionary *_dependenceStructure;
    NSArray *_classToDisplayList;
    NSMutableArray *_fetchAllClassName;
}

//@property (nonatomic) NSMutableDictionary *dependenceStructure;
@property (nonatomic) NSString *sourceDirectoryPath;

@end

NSString * const kClassNameRegexPattern = @"@interface[\\W]*([\\w]*)";

@implementation CSAClassStructureManager

- (instancetype)initWithSourceCodeDirectory:(NSString *)path
{
    self = [super init];
    if (self) {
        if (![[path substringFromIndex:[path length] - 1] isEqualToString:@"/"]) {
            path = [NSString stringWithFormat:@"%@/",path];
        }
        self.sourceDirectoryPath = path;
    }
    return self;
}

#pragma mark - Getter methods

- (NSArray *)allSourceFileList
{
    if (_allSourceFileList) {
        return _allSourceFileList;
    }
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    NSDirectoryEnumerator *dirEnum = [fm enumeratorAtPath:self.sourceDirectoryPath];
    
    NSMutableArray *result = [NSMutableArray array];
    
    NSString *file;
    while ((file = [dirEnum nextObject])) {
        if (([[file pathExtension] isEqualToString: @"h"]) || ([[file pathExtension] isEqualToString: @"m"])) {
            if ((self.skipPods && ([file rangeOfString:@"Pods/"].location == NSNotFound)) || (!self.skipPods)) {
                NSString *fullPath = [NSString stringWithFormat:@"%@%@",self.sourceDirectoryPath,file];
                [result addObject:fullPath];
            }
        }
    }

    _allSourceFileList = result;
    
    return result;
}

- (NSDictionary *)dependenceStructure
{
    if (!_dependenceStructure) {
        [self buildDependenceStructure];
    }
    
    return _dependenceStructure;
}

- (NSArray *)fetchAllClassName
{
    if (!_fetchAllClassName) {
        [self buildFetchAllClassName];
    }
    
    return _fetchAllClassName;
}

#pragma mark - Private methods

- (BOOL) isFile:(NSString *)filePath containsClassCall:(NSString *)className
{
    NSError *error = nil;
    NSString *fileContent = [NSString stringWithContentsOfURL:[NSURL fileURLWithPath:filePath]
                                                     encoding:NSUTF8StringEncoding error:&error];
    
    NSString *pattern = [NSString stringWithFormat:@"\\W%@\\W",className];
    
    NSRegularExpression *regexExp = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                              options:NSRegularExpressionCaseInsensitive
                                                                                error:&error];
    
    if ([regexExp numberOfMatchesInString:fileContent options:NSMatchingReportProgress range:NSMakeRange(0, fileContent.length)]) {
        return YES;
    } else {
        return NO;
    }
}

- (NSString *)fileNameFromFullPath:(NSString *)fullPath
{
    return [[fullPath lastPathComponent] stringByDeletingPathExtension];
}

- (void)buildDependenceStructure
{
    _dependenceStructure = [[NSMutableDictionary alloc] init];
    
    NSArray *allClassName = [self fetchAllClassName];
    
    for (NSString *className in allClassName) {
        NSMutableSet *emptyArray = [NSMutableSet new];
        [_dependenceStructure setValue:emptyArray forKey:className];
    }
    
    for (NSString *filePath in self.allSourceFileList) {
        for (NSString *className in allClassName) {
            if ([self isFile:filePath containsClassCall:className]) {
                NSMutableSet *set = [_dependenceStructure objectForKey:className];
                [set addObject:[self fileNameFromFullPath:filePath]];
            }
        }
    }
    
    for (NSString *className in allClassName) {
        NSMutableSet *set = [_dependenceStructure objectForKey:className];
        [_dependenceStructure setValue:[set allObjects] forKey:className];
    }
}

- (void)buildFetchAllClassName
{
    _fetchAllClassName = [NSMutableArray array];
    
    for (NSString *filePath in self.allSourceFileList) {
        NSError *error = nil;
        
        NSString *fileContent = [NSString stringWithContentsOfURL:[NSURL fileURLWithPath:filePath]
                                                         encoding:NSUTF8StringEncoding error:&error];
        NSRegularExpression *regexExp = [NSRegularExpression regularExpressionWithPattern:kClassNameRegexPattern
                                                                                  options:NSRegularExpressionCaseInsensitive
                                                                                    error:&error];
        
        NSArray *matchList = [regexExp matchesInString:fileContent options:NSMatchingReportProgress range:NSMakeRange(0, fileContent.length)];
        for (NSTextCheckingResult *checkResult in matchList) {
            NSRange matchRange = [checkResult rangeAtIndex:1];
            NSString *matchedString = [fileContent substringWithRange:matchRange];
            [_fetchAllClassName addObject:matchedString];
        }
        
    }
    
}


@end
