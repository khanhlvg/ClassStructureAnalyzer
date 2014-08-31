//
//  Document.m
//  ClassStructureAnalyzer
//
//  Created by Le Viet Gia Khanh on 8/30/14.
//  Copyright (c) 2014 Recruit. All rights reserved.
//

#import "CSADocument.h"
#import "CSAClassStructureManager.h"

@interface CSADocument()

@property (weak) IBOutlet NSTableView *classListTable;
@property (weak) IBOutlet NSTableView *classUsedTable;
@property (nonatomic) NSMutableDictionary *dependenceStructure;

@end

@implementation CSADocument

- (id)init
{
    self = [super init];
    if (self) {
        // Add your subclass-specific initialization here.
        
        /*NSDictionary *dict = @{@"Class1":@[@"Class2",@"Class3"],
                               @"Class2":@[@"Class3"]
                               };
        
        self.dependenceStructure = [dict mutableCopy];*/
    }
    return self;
}

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"CSADocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
    
}

+ (BOOL)autosavesInPlace
{
    return YES;
}

#pragma mark - Document methods
- (void)saveToCoreData
{
    NSManagedObject *entityDesc =
    [NSEntityDescription
     insertNewObjectForEntityForName:@"Content"
     inManagedObjectContext:self.managedObjectContext];
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.dependenceStructure];
    [entityDesc setValue:data forKey:@"dependenceStructure"];
    NSError *error;
    [self.managedObjectContext save:&error];
}

#pragma mark - NSTableViewDataSource protocol
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    if (tableView == self.classListTable) {
        return [self.dependenceStructure count];
    } else {
        NSInteger classListRow = self.classListTable.selectedRow;
        if (classListRow >= 0) {
            NSString *selectedClassName = self.dependenceStructure.allKeys[classListRow];
            return [[self.dependenceStructure objectForKey:selectedClassName] count];
        } else {
            return 0;
        }
    }
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    if (tableView == self.classListTable) {
        return self.dependenceStructure.allKeys[row];
    } else {
        NSInteger classListRow = self.classListTable.selectedRow;
        if (classListRow >= 0) {
            NSString *selectedClassName = self.dependenceStructure.allKeys[classListRow];
            return [self.dependenceStructure objectForKey:selectedClassName][row];
        } else {
            return nil;
        }
    }
}

#pragma mark - NSTableViewDelegate
- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row
{
    if (tableView == self.classListTable) {
        
        return YES;
    } else {
        return NO;
    }
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
    [self.classUsedTable reloadData];
}

#pragma mark - IBAction
- (IBAction)pushLoadData:(NSButton *)sender {
    // Create the File Open Dialog class.
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    
    // Enable the selection of files in the dialog.
    [openDlg setCanChooseFiles:NO];
    
    // Enable the selection of directories in the dialog.
    [openDlg setCanChooseDirectories:YES];
    
    openDlg.allowsMultipleSelection = NO;
    
    // Display the dialog.  If the OK button was pressed,
    // process the files.
    
    [openDlg beginWithCompletionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            
            // grab a reference to what has been selected
            NSURL *selectedDirectory = [[openDlg URLs]objectAtIndex:0];
            
            CSAClassStructureManager *csm = [[CSAClassStructureManager alloc] initWithSourceCodeDirectory:selectedDirectory.path];
            csm.skipPods = YES;
            
            self.dependenceStructure = csm.dependenceStructure;
            [self.classListTable reloadData];
            
            [self saveToCoreData];
            
        }
    }];

}



@end
