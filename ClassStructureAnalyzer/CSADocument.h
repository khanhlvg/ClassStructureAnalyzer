//
//  Document.h
//  ClassStructureAnalyzer
//
//  Created by Le Viet Gia Khanh on 8/30/14.
//  Copyright (c) 2014 Recruit. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CSADocument : NSPersistentDocument<NSTableViewDataSource,NSTableViewDelegate,NSTextFieldDelegate,NSMatrixDelegate>

@property (nonatomic,readonly) NSDictionary *dependenceStructure;

- (void)saveToCoreData;

- (IBAction)copy:sender;
- (IBAction)paste:sender;

@end
