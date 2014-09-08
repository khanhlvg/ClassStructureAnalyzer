//
//  CSAMetaInfoWindowController.m
//  ClassStructureAnalyzer
//
//  Created by Le Viet Gia Khanh on 2014/09/01.
//  Copyright (c) 2014年 Recruit. All rights reserved.
//

#import "CSAMetaInfoWindowController.h"
#import "CSADocument.h"
#import "CSAClassUtility.h"

@interface CSAMetaInfoWindowController ()

@property (weak) IBOutlet NSTableView *metaInfoTable;
@property (weak) IBOutlet NSTextField *filterClassnameText;

@property (nonatomic) NSArray *classListMatchSearchString;

@end

static NSString *const kClassNameColumnIdentifer = @"ClassNameColumn";
static NSString *const kDescriptionColumnIdentifer = @"DescriptionColumn";

@implementation CSAMetaInfoWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (NSString *)windowNibName
{
    return @"CSAMetaInfoWindowController";
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (void)windowWillLoad
{
    [super windowWillLoad];
    self.classListMatchSearchString = [self.metaInfoDict allKeys];
}

#pragma mark - NSTableViewDataSource methods
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [self.classListMatchSearchString count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    if ([tableColumn.identifier isEqualToString:kClassNameColumnIdentifer]) {
        return self.classListMatchSearchString[row];
    } else if ([tableColumn.identifier isEqualToString:kDescriptionColumnIdentifer]) {
        return [self.metaInfoDict objectForKey:self.classListMatchSearchString[row]];
    }
    
    return nil;
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    if ([tableColumn.identifier isEqualToString:kDescriptionColumnIdentifer]) {
        [self.metaInfoDict setObject:object forKey:self.classListMatchSearchString[row]];
        [self.documentEntity saveToCoreData];
    }

}

#pragma mark - NSTableViewDelegate methods

- (BOOL)tableView:(NSTableView *)tableView shouldEditTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    if ([tableColumn.identifier isEqualToString:kDescriptionColumnIdentifer]) {
        return YES;
    }
    
    return NO;
}

#pragma mark - TextField delegate methods
- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor
{
    if (control != self.filterClassnameText) {
        return YES;
    }
    
    NSString *classNameSearchString = fieldEditor.string;
    self.classListMatchSearchString = [CSAClassUtility subArrayOf:[self.metaInfoDict allKeys]
                                                      matchString:classNameSearchString];
    [self.metaInfoTable reloadData];
    return YES;
}

@end
