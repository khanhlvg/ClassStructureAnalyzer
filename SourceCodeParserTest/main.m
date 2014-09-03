//
//  main.m
//  SourceCodeParserTest
//
//  Created by Le Viet Gia Khanh on 8/31/14.
//  Copyright (c) 2014 Recruit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSAClassStructureManager.h"

int main(int argc, const char * argv[])
{

    @autoreleasepool {
        
        // insert code here...
        /*NSFileManager *fm = [NSFileManager defaultManager];
        
        NSString *path = @"/Volumes/DATAOSX/Users/giakhanhlv/Projects/Studying/ClassicPhotos-stalled/";
        
        NSDirectoryEnumerator *dirEnum = [fm enumeratorAtPath:path];
        
        NSString *pattern = @"@interface[\\W]*([\\w]*)";

        NSString *file;
        while ((file = [dirEnum nextObject])) {
            if (([[file pathExtension] isEqualToString: @"h"]) || ([[file pathExtension] isEqualToString: @"m"])) {
                // process the document
                NSError *error = nil;
                NSString *fullPath = [NSString stringWithFormat:@"%@%@",path,file];
                NSString *fileContent = [NSString stringWithContentsOfURL:[NSURL fileURLWithPath:fullPath]
                                                                 encoding:NSUTF8StringEncoding error:&error];
                
                NSRegularExpression *regexExp = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                                          options:NSRegularExpressionCaseInsensitive
                                                                                            error:&error];
                
                NSArray *matchList = [regexExp matchesInString:fileContent options:NSMatchingReportProgress range:NSMakeRange(0, fileContent.length)];
                for (NSTextCheckingResult *checkResult in matchList) {
                    NSRange matchRange = [checkResult rangeAtIndex:1];
                    NSString *matchedString = [fileContent substringWithRange:matchRange];
                    NSLog(@"%@",matchedString);
                }
                
            }
        }*/
        
        
        
        //NSLog(@"%@", fileList);
        
        CSAClassStructureManager *csm = [[CSAClassStructureManager alloc] initWithSourceCodeDirectory:@"/Users/lvgkhanh/Projects/iOS Study/Dandori Demo_Extended"];
        csm.skipPods = YES;
        
        //NSLog(@"%@", [csm dependenceStructure]);
        
        NSLog(@"%@", [csm dependenceStructureWithDigger]);
        
        /*NSDictionary *dict = [csm dependenceStructureWithDigger];
        for (NSString *className in dict.allKeys) {
            for (CSADigResultDto *dto in [dict objectForKey:className]) {
                NSLog(@"");
            }
        }*/
        
        
        /*if ([csm isFile:@"/Volumes/DATAOSX/Users/giakhanhlv/Projects/Studying/ClassicPhotos-stalled/ClassicPhotos/ListViewController.m" containsClassCall:@"PendingOperations"]) {
            NSLog(@"contain!");
        }*/
        
    }
    return 0;
}

