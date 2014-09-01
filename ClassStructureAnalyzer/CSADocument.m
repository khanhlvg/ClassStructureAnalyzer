//
//  Document.m
//  ClassStructureAnalyzer
//
//  Created by Le Viet Gia Khanh on 8/30/14.
//  Copyright (c) 2014 Recruit. All rights reserved.
//

/*
 
 追加したい機能
 　1. 複数のクラスを選択したら、使われるリストには、それらのクラスが使われる全クラスのリストを出力する
 　2. 使われるクラスの１階層目だけでなく、②階層目まで拾いにいくこと　（本当に必要なのかな？）
 　3. クラスをMVCに分類して、結果的にはある案件で、影響がある機能(method)+画面（ViewController）+Viewがどれかをすぐ言えるようにしたい
 　4. xibを拾えるようにする
 　5. Categoryを拾えるようにする
 
 */


#import "CSADocument.h"
#import "CSAClassStructureManager.h"

@interface CSADocument()

@property (weak) IBOutlet NSTableView *classListTable;
@property (weak) IBOutlet NSTableView *classUsedTable;
@property (weak) IBOutlet NSTextField *classNameSearchText;

@property (nonatomic) NSArray *classListMatchSearchString;
@property (nonatomic) NSMutableDictionary *dependenceStructure;

@end

@implementation CSADocument

- (id)init
{
    self = [super init];
    if (self) {
        // Add your subclass-specific initialization here.
        
    }
    return self;
}

- (BOOL)configurePersistentStoreCoordinatorForURL:(NSURL *)url ofType:(NSString *)fileType modelConfiguration:(NSString *)configuration storeOptions:(NSDictionary *)storeOptions error:(NSError *__autoreleasing *)error
{
    BOOL ret = [super configurePersistentStoreCoordinatorForURL:url ofType:fileType modelConfiguration:configuration storeOptions:storeOptions error:error];
    
    if (ret) {
        [self loadFromCoreData];
    }
    
    return ret;
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
    NSManagedObject *entityDesc = [NSEntityDescription insertNewObjectForEntityForName:@"Content"
                                                                inManagedObjectContext:self.managedObjectContext];

    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.dependenceStructure];

    [entityDesc setValue:data forKey:@"dependenceStructure"];
    
    [self.managedObjectContext insertObject:entityDesc];
    
    /*NSError *error;
    [self.managedObjectContext save:&error];*/
}

- (void)loadFromCoreData
{
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"Content" inManagedObjectContext:self.managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];

    [request setEntity:entityDescription];
    
    NSError *error;
    NSArray *array = [self.managedObjectContext executeFetchRequest:request error:&error];
    if ((array == nil) || (array.count == 0))
    {
        self.dependenceStructure = @{};
    } else {
        NSManagedObject *object = array[0];
        NSData *rawData = [object valueForKey:@"dependenceStructure"];
        self.dependenceStructure = [NSKeyedUnarchiver unarchiveObjectWithData:rawData];
    }
    
    self.classListMatchSearchString = [self.dependenceStructure allKeys];
    
    [self.classListTable reloadData];
}

/*
- (void)saveDocument:(id)sender
{
    [super saveDocument:sender];
    [self.managedObjectContext save:nil];
}*/

#pragma mark - NSTableViewDataSource protocol
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    if (tableView == self.classListTable) {
        return [self.classListMatchSearchString count];
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
        return self.classListMatchSearchString[row];
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

#pragma mark - TextField delegate methods
- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor
{
    NSString *classNameSearchString = fieldEditor.string;
    self.classListMatchSearchString = [self subArrayOf:[self.dependenceStructure allKeys] matchString:classNameSearchString];
    [self.classListTable reloadData];
    return YES;
}

#pragma mark - Class list match search string methods

- (NSArray *)subArrayOf:(NSArray *)array matchString:(NSString *)matchString
{
    if ([matchString isEqualToString:@""]) {
        return [array copy];
    }
    
    NSMutableArray *ret = [NSMutableArray array];
    
    for (id item in array) {
        if ([[item class] isSubclassOfClass:[NSString class]]) {
            NSString *str = (NSString *)item;
            if ([str rangeOfString:matchString options:NSCaseInsensitiveSearch].location != NSNotFound) {
                [ret addObject:str];
            }
        }
    }
    
    return ret;
}

- (NSInteger)numberOfItemInArray:(NSArray *)array matchString:(NSString *)matchString
{
    NSInteger count = 0;
    
    for (id item in array) {
        if ([[item class] isSubclassOfClass:[NSString class]]) {
            NSString *str = (NSString *)item;
            if ([str rangeOfString:matchString].location != NSNotFound) {
                count++;
            }
        }
    }
    
    return count;
}

@end
