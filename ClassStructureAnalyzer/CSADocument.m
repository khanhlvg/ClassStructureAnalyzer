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
#import "CSAMetaInfoWindowController.h"
#import "CSAClassUtility.h"

@interface CSADocument()

@property (nonatomic) CSAMetaInfoWindowController *metaInfoWC;

@property (weak) IBOutlet NSTableView *classListTable;
@property (weak) IBOutlet NSTableView *classUsedTable;
@property (weak) IBOutlet NSTextField *classNameSearchText;

@property (nonatomic) NSArray *classListMatchSearchString;
@property (nonatomic) NSDictionary *dependenceStructure;
@property (nonatomic) NSDictionary *dependenceStructureWithDigger;
@property (nonatomic) NSMutableDictionary *metaInfoDict;

@end

static NSString *const kContentTableName = @"Content";
static NSString *const kDependenceStructureColumnName = @"dependenceStructure";
static NSString *const kDependenceStructureDiggerColumnName = @"dependenceStructureDigger";
static NSString *const kMetaDictInfoColumnName = @"metaInfoDict";

static NSString *const kTableViewUsedInUIColumnId = @"usedInUIColumn";
static NSString *const kTableViewRouteColumnId = @"routeColumn";

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
    //delete old data
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:kContentTableName inManagedObjectContext:self.managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    
    NSError *error;
    NSArray *array = [self.managedObjectContext executeFetchRequest:request error:&error];
    for (NSManagedObject *object in array) {
        [self.managedObjectContext deleteObject:object];
    }
    
    //resave new data
    
    NSManagedObject *entityDesc = [NSEntityDescription insertNewObjectForEntityForName:kContentTableName
                                                                inManagedObjectContext:self.managedObjectContext];

    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.dependenceStructure];
    [entityDesc setValue:data forKey:kDependenceStructureColumnName];
    
    data = [NSKeyedArchiver archivedDataWithRootObject:self.metaInfoDict];
    [entityDesc setValue:data forKey:kMetaDictInfoColumnName];
    
    data = [NSKeyedArchiver archivedDataWithRootObject:self.dependenceStructureWithDigger];
    [entityDesc setValue:data forKey:kDependenceStructureDiggerColumnName];
    
    [self.managedObjectContext insertObject:entityDesc];
    
    /*NSError *error;
    [self.managedObjectContext save:&error];*/
}

- (void)loadFromCoreData
{
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:kContentTableName
                                              inManagedObjectContext:self.managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];

    [request setEntity:entityDescription];
    
    NSError *error;
    NSArray *array = [self.managedObjectContext executeFetchRequest:request error:&error];
    if ((array == nil) || (array.count == 0))
    {
        self.dependenceStructure = @{};
        self.dependenceStructureWithDigger = @{};
    } else {
        NSManagedObject *object = array[0];
        
        NSData *rawData = [object valueForKey:kDependenceStructureColumnName];
        self.dependenceStructure = [NSKeyedUnarchiver unarchiveObjectWithData:rawData];
        
        rawData = [object valueForKey:kMetaDictInfoColumnName];
        self.metaInfoDict = [NSKeyedUnarchiver unarchiveObjectWithData:rawData];
        
        rawData = [object valueForKey:kDependenceStructureDiggerColumnName];
        self.dependenceStructureWithDigger = [NSKeyedUnarchiver unarchiveObjectWithData:rawData];
    }
    
    self.classListMatchSearchString = [self.dependenceStructureWithDigger allKeys];
    
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
            NSString *selectedClassName = self.classListMatchSearchString[classListRow];
            return [[self.dependenceStructureWithDigger objectForKey:selectedClassName] count];
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
        NSString *selectedClassName = self.classListMatchSearchString[classListRow];
        CSADigResultDto *resultDto = [self.dependenceStructureWithDigger objectForKey:selectedClassName][row];
        
        // if there is no row in class list selected, then return nil
        if (classListRow < 0) {
            return nil;
        }
        
        if ([tableColumn.identifier isEqualToString:kTableViewUsedInUIColumnId]) {
            NSString *classNameMetaInfo = [self.metaInfoDict objectForKey:resultDto.className];
            return classNameMetaInfo;
        } if ([tableColumn.identifier isEqualToString:kTableViewRouteColumnId]) {
            return resultDto.route;
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

#pragma mark - NSTableViewDelegate methods

- (BOOL)tableView:(NSTableView *)tableView shouldEditTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    return NO;
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
            self.dependenceStructureWithDigger = csm.dependenceStructureWithDigger;
            self.metaInfoDict = [self metaInfoDictionaryFromStructure:self.dependenceStructureWithDigger];
            self.classListMatchSearchString = [self.dependenceStructureWithDigger allKeys];
            [self.classListTable reloadData];
            
            [self saveToCoreData];
            
        }
    }];

}

- (IBAction)pushEditMeta:(NSButton *)sender {
    
    if (!self.metaInfoWC) {
        self.metaInfoWC = [[CSAMetaInfoWindowController alloc] init];
        self.metaInfoWC.metaInfoDict = self.metaInfoDict;
        self.metaInfoWC.documentEntity = self;
    }
    
    CSAMetaInfoWindowController *mvc = self.metaInfoWC;
    
    mvc.window.title = [NSString stringWithFormat:@"Meta Data Editor - %@",self.windowForSheet.title];
    
    [mvc showWindow:self];
    
}


#pragma mark - TextField delegate methods
- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor
{
    NSString *classNameSearchString = fieldEditor.string;
    self.classListMatchSearchString = [CSAClassUtility subArrayOf:[self.dependenceStructureWithDigger allKeys]
                                                      matchString:classNameSearchString];
    [self.classListTable reloadData];
    return YES;
}

#pragma mark - Meta data methods

- (NSMutableDictionary *)metaInfoDictionaryFromStructure:(NSDictionary *)structure
{
    NSMutableDictionary *ret = [NSMutableDictionary dictionary];
    
    for (NSString *className in structure.allKeys) {
        if ([CSAClassUtility shouldClassHasMetaData:className]) {
            [ret setObject:className forKey:className];
        }
    }
    
    return ret;
}

@end
