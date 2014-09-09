//
//  ClassStructureDto.m
//  ClassStructureAnalyzer
//
//  Created by Le Viet Gia Khanh on 8/31/14.
//  Copyright (c) 2014 Recruit. All rights reserved.
//

#import "CSAClassStructureManager.h"
#import "CSAClassUtility.h"
#import "NSDictionary+RT.h"

@interface CSAClassStructureManager()
{
    //member=NSString
    NSArray *_allSourceFileList;
    
    //member=NSString
    NSMutableArray *_fetchAllClassName;
    
    //key=NSString : value=NSArray[NSString]
    NSMutableDictionary *_dependenceStructure;
    
    //key=NSString : value=NSMutableArray[CSADigResultDto]
    NSMutableDictionary *_digResult;
    //key=NSString : value=NSArray[CSADigResultDto]
    NSMutableDictionary *_dependenceStructureWithDigger;
    
}

//@property (nonatomic) NSMutableDictionary *dependenceStructure;
@property (nonatomic) NSString *sourceDirectoryPath;

@end

NSString * const kClassNameRegexPattern = @"@interface[\\W]*([\\w]*)";
NSInteger _debugDepth = 0;

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
    
    return [NSArray arrayWithArray:result];
}

- (NSDictionary *)dependenceStructure
{
    if (!_dependenceStructure) {
        [self buildDependenceStructure];
    }
    
    return [NSDictionary dictionaryWithDictionary:_dependenceStructure];
}

- (NSArray *)fetchAllClassName
{
    if (!_fetchAllClassName) {
        [self buildFetchAllClassName];
    }
    
    return [NSArray arrayWithArray:_fetchAllClassName];
}

- (NSDictionary *)dependenceStructureWithDigger
{
    if (!_dependenceStructureWithDigger) {
        [self buildDependenceStructureWithDigger];
    }
    
    return [NSDictionary dictionaryWithDictionary:_dependenceStructureWithDigger];
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

#pragma mark - Private Getter data builders

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
#warning 使われるclass名を、filenameからではなく、実際にcodeを解析して、どのクラスに使われるかを特定するロジックに改良したい
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

#pragma mark - Private class list digger

//recuresive method to dig
- (NSArray *)digClass:(NSString *)className withCurrentRoute:(NSString *)route
{
    //NSLog(@"digger: className=%@ route=%@",className,route);
    _debugDepth++;
    NSLog(@"depth=%zd",_debugDepth);
    
    if ([className isEqualToString:@"HACoreData"]) {
        int i=0;
    }
    
    NSMutableArray *result = [NSMutableArray array];
    
    //if has cached data than skip digging and create result from cache
    if ([_digResult objectForKey:className]) {
        
        //NSLog(@"use cache data for class=%@",className);
        
        NSArray *cachedResult = [_digResult objectForKey:className];
        for (CSADigResultDto *singleCachedResult in cachedResult) {
            CSADigResultDto *singleResult = [[CSADigResultDto alloc] init];
            singleResult.className = singleCachedResult.className;
            singleResult.route = [NSString stringWithFormat:@"%@%@",route,singleCachedResult.route];
            [result addObject:singleResult];
        }
        
        _debugDepth--;
        return result;
    }
    
    //as there is no cached data, we will dig deeper and cache that result
    NSMutableArray *resultToCache = [NSMutableArray array];
    
    // if current class has meta data then return
    /*if ([CSAClassUtility shouldClassHasMetaData:className]) {
        //cache result
        CSADigResultDto *dto = [[CSADigResultDto alloc] init];
        dto.className = className;
        dto.route = [NSString stringWithFormat:@"->%@",className];
        [resultToCache addObject:dto];
        [_digResult setObject:resultToCache forKey:className];
        
        //create real result
        dto = [[CSADigResultDto alloc] init];
        dto.className = className;
        dto.route = [NSString stringWithFormat:@"%@->%@",route,className];
        [result addObject:dto];
        
        _debugDepth--;
        return result;
    }*/
    
    NSMutableArray *rawDiggingResult = [NSMutableArray array];
    // normal case -> do recursive
    for (NSString *usedClassName in [self.dependenceStructure objectForKey:className]) {
        
        // don't dig into visited class, or it will create an eternal loop
        if ([route rangeOfString:usedClassName].location != NSNotFound) {
            continue;
        }
        
        // if this class is a UI item, then don't dig further but return itself
        if ([CSAClassUtility shouldClassHasMetaData:usedClassName]) {
            CSADigResultDto *dto = [[CSADigResultDto alloc] init];
            dto.className = usedClassName;
            dto.route = [NSString stringWithFormat:@"%@->%@->%@",route,className,usedClassName];
            [rawDiggingResult addObject:dto];
            continue;
        }
    
        // don't dig into itself, or it will create an eternal loop
        if ([usedClassName isEqualToString:className]) {
            continue;
        }
    
        NSArray *digFurtherResult = [self digClass:usedClassName
                                  withCurrentRoute:[NSString stringWithFormat:@"%@->%@",route,className]];
        [rawDiggingResult addObjectsFromArray:digFurtherResult];
    }
    
    // refine raw result to get minimal path for each class
    for (CSADigResultDto *singleRawResult in rawDiggingResult) {
        CSADigResultDto *dtoInCache = [self getFirstDigResultFromArray:result byClassname:singleRawResult.className];
        if (dtoInCache) {
            // if found a new raw result that has route shorter than the one in cache, then we replace the one in cache with this newly found dto in raw result array
            NSInteger countInCache = [[dtoInCache.route componentsSeparatedByString:@"->"] count];
            NSInteger countInRaw = [[singleRawResult.route componentsSeparatedByString:@"->"] count];
            if (countInRaw < countInCache) {
                dtoInCache.route = singleRawResult.route;
            }
        } else {
            [result addObject:singleRawResult];
        }
    }
    
    //NSLog(@"dig->%@ refinedResult->%@",className,resultToCache);
    
    
    // create result to cache by removing current route from returning result
    for (CSADigResultDto *singleCacheResult in result) {
        CSADigResultDto *resultDto = [[CSADigResultDto alloc] init];
        resultDto.className = singleCacheResult.className;
        resultDto.route = [singleCacheResult.route substringFromIndex:route.length];
        //NSLog(@"%@ %@",resultDto.route,route);
        [resultToCache addObject:resultDto];
    }
    
    // cache this result
    [_digResult setObject:resultToCache forKey:className];
    
    _debugDepth--;
    return [NSArray arrayWithArray:result];
}

- (CSADigResultDto *)getFirstDigResultFromArray:(NSArray *)resultArray byClassname:(NSString *)className
{
    for (id item in resultArray) {
        if ([item class] == [CSADigResultDto class]) {
            CSADigResultDto *dto = (CSADigResultDto *)item;
            if ([dto.className isEqualToString:className]) {
                return dto;
            }
        }
    }
    return nil;
}

- (void)buildDependenceStructureWithDigger
{
    _digResult = [NSMutableDictionary dictionary];
    
    _dependenceStructureWithDigger = [NSMutableDictionary dictionary];
    
    // loop over all class in project and dig each of them
    for (NSString *className in self.dependenceStructure) {
        //NSLog(@"start digging %@",className);
        NSArray *usedClassList = [self digClass:className withCurrentRoute:@""];
        
        //shorten route string
        NSString *prefix = [NSString stringWithFormat:@"->%@",className];
        for (CSADigResultDto *dto in usedClassList) {
            /*if ([dto.route isEqualToString:prefix]) {
                dto.route = @"(self)";
            } else {*/
                if (prefix.length >= dto.route.length) {
                    NSLog(@"%@,route=%@",prefix,dto.route);
                }
                dto.route = [dto.route substringFromIndex:prefix.length];
                dto.route = [NSString stringWithFormat:@"(self)%@",dto.route];
            //}
        }
        
        [_dependenceStructureWithDigger setObject:usedClassList forKey:className];
    }
    
}


@end
