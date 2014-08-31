//
//  Document.h
//  ClassStructureAnalyzer
//
//  Created by Le Viet Gia Khanh on 8/30/14.
//  Copyright (c) 2014 Recruit. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CSADocument : NSPersistentDocument<NSTableViewDataSource,NSTableViewDelegate>

@property (nonatomic,readonly) NSDictionary *dependenceStructure;

@end
