//
//  CSAMetaInfoWindowController.h
//  ClassStructureAnalyzer
//
//  Created by Le Viet Gia Khanh on 2014/09/01.
//  Copyright (c) 2014年 Recruit. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class CSADocument;

@interface CSAMetaInfoWindowController : NSWindowController <NSTableViewDelegate, NSTableViewDataSource>

@property (nonatomic, weak) NSMutableDictionary *metaInfoDict;
@property (nonatomic, weak) CSADocument *documentEntity;

@end
