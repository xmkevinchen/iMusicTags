//
//  AppController.mm
//  iMusicTags
//
//  Created by Kevin Chen on 10-7-23.
//  Copyright 2010 Kevin Chen's workstation. All rights reserved.
//

#import "AppController.h"
#import "MusicFileInfo.h"
#import "CharacterEncoding.h"

@implementation AppController

@synthesize encoding;

- (void)awakeFromNib
{
	[tableView registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType,nil]];
	
	// Initialize Encoding Menu 
	[self initEncodingMenu];
	
	// Initialize Encoding Popup Button 
	[self initEncodingPopUpButton];
	
	[btnEncodingCatalog selectItemWithTag:C_SIMPLIFIED_CHINESE];
	[self chooseCatalog:btnEncodingCatalog];
	
}

- (IBAction)open:(id)sender
{
	NSOpenPanel *panel = [NSOpenPanel openPanel];
	[panel setCanChooseFiles:YES];
	[panel setAllowsMultipleSelection:YES];
	
	if ([panel runModal] == NSOKButton) {
		
		if (displayInfo) {
			[displayInfo release];
		}
		
		displayInfo = [[NSMutableArray alloc] init];
		fileUrls = [[NSMutableArray alloc] init];
		fileSet = [[NSMutableSet alloc] init];
		
		
		for (NSURL *url in [panel URLs]) {
			if(![fileSet containsObject:url]) {
				MusicFileInfo *fileInfo = [[MusicFileInfo alloc] initWithUrl:url];
				if (fileInfo) {
					[displayInfo addObject:fileInfo];
					[fileUrls addObject:url];
					[fileSet addObject:url];
				}
			}
			
		}
		
		[tableView reloadData];
		[tableView sizeToFit];
	}
}


- (NSInteger)numberOfRowsInTableView:(NSTabView *)aTableView
{
	return [displayInfo count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn
			row:(NSInteger)rowIndex
{
	id theRecord, theValue;
	
	NSParameterAssert((rowIndex >= 0) && (rowIndex < [displayInfo count]));
	
	theRecord = [displayInfo objectAtIndex:rowIndex];
	theValue = [theRecord valueForKey:[aTableColumn identifier]];
	return theValue;
}

- (void)tableView:(NSTableView *)aTableView
   setObjectValue:anObject
   forTableColumn:(NSTableColumn *)aTableColumn
			  row:(int)rowIndex
{
    id theRecord;
	
    NSParameterAssert(rowIndex >= 0 && rowIndex < [displayInfo count]);
    theRecord = [displayInfo objectAtIndex:rowIndex];
    [theRecord setObject:anObject forKey:[aTableColumn identifier]];
    return;
}



- (NSDragOperation)tableView:(NSTableView *)aTableView 
				validateDrop:(id <NSDraggingInfo>)info
				 proposedRow:(NSInteger)row 
	   proposedDropOperation:(NSTableViewDropOperation)op
{
	return NSDragOperationEvery;
}

- (BOOL)tableView:(NSTableView *)aTableView
	   acceptDrop:(id <NSDraggingInfo>)info 
			  row:(NSInteger)row
	dropOperation:(NSTableViewDropOperation)operation
{
	NSPasteboard *pboard = [info draggingPasteboard];
	
	if ([[pboard types] containsObject:NSFilenamesPboardType]) {
		if (nil == displayInfo) {
			displayInfo = [[NSMutableArray alloc] init];
		}
		if (nil == fileUrls) {
			fileUrls = [[NSMutableArray alloc] init];
		}
		if (nil == fileSet) {
			fileSet = [[NSMutableSet alloc] init];
		}
		
		for (NSString *path in [pboard propertyListForType:NSFilenamesPboardType])
		{
			if ([path isEqualToString:@""]) {
				continue;
			}
			
			NSURL *url = [NSURL fileURLWithPath:path];
			if (![fileUrls containsObject:url]) {
				MusicFileInfo *fileInfo = [[MusicFileInfo alloc] initWithUrl:url];
				if (fileInfo) {
					[displayInfo addObject:fileInfo];
					[fileUrls addObject:url];
					[fileSet addObject:url];
				}
			}
			
		}
		
		[tableView reloadData];
		[tableView sizeToFit];
		
		return YES;
	}
	
	return NO;
}

- (IBAction)preview:(id)sender
{
	[displayInfo release];
	displayInfo = [[NSMutableArray alloc] init];
	
	for (NSURL *url in fileUrls) {
		[displayInfo addObject:[[MusicFileInfo alloc] initWithUrl:url withEncoding:encoding]];
	}	
	
	[tableView reloadData];
}

- (IBAction)deleteRows:(id)sender
{
	NSIndexSet *selected = [tableView selectedRowIndexes];
	
	if ([selected count] <= 0) {
		NSBeep();
		return;
	}
	
	NSUInteger *indexBuff = nil;
	indexBuff = (NSUInteger *)(malloc(sizeof(NSUInteger) * [selected count]));
	if (nil == indexBuff) {
		return;
	}
	NSRange range = NSMakeRange([selected firstIndex], [selected lastIndex] + 1);
	[selected getIndexes:indexBuff maxCount:[selected count] inIndexRange:&range];
	
	NSUInteger *index = indexBuff;
	for (int i = 0; i < [selected count]; i++) {
		MusicFileInfo *file = (MusicFileInfo *)[displayInfo objectAtIndex:*(index + i)];
		[fileUrls removeObject:file.fileUrl];
		[fileSet removeObject:file.fileUrl];
	}
	[displayInfo removeObjectsAtIndexes:selected];
	
	[tableView reloadData];
	[tableView deselectAll:self];
	free(indexBuff);
}

- (IBAction)convert:(id)sender
{
	for (id info in displayInfo) {
		[(MusicFileInfo *)info writeTagsWithEncoding:encoding];
	}
	[displayInfo removeAllObjects];
	[fileUrls removeAllObjects];
	[fileSet removeAllObjects];
	[tableView reloadData];
	NSBeep();
}

/**
 * Initialize the Encoding Menu Item with specified character encoding
 */
- (void)initEncodingMenu
{
	NSMenuItem *newItem;
	CharacterEncodingUtil *util = [[CharacterEncodingUtil alloc] init];
	
	[mEncoding setAutoenablesItems:NO];
	
	for (CharacterCatalog *c in [CharacterCatalog catalogs]) {
		NSMenuItem *menuItem = [[NSMenuItem allocWithZone:[NSMenu menuZone]] init];
		[menuItem setTitle:[c description]];
		[menuItem setTag:[c catalogValue]];
		
		NSMenu *menu = [[NSMenu allocWithZone:[NSMenu menuZone]] initWithTitle:[c description]];
		[menuItem setSubmenu:menu];
		
		for (CharacterEncoding *e in [util encodings:[c catalogValue]]) {
			newItem = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:[e description]
																		   action:@selector(chooseEncoding:) 
																	keyEquivalent:@""];
			[newItem setTag:[e encodingCode]];
			[newItem setTarget:self];
			[menu addItem:newItem];
		}
		
		[mEncoding addItem:menuItem];
	}
}

/*!
 @method initEncodingPopUpButton    
 @abstract   Initialize the Encoding Popup Button with specified character encoding
 @discussion 
 */
- (void)initEncodingPopUpButton
{
	
	NSMenuItem *newItem;
	
	for (CharacterCatalog *c in [CharacterCatalog catalogs]) 
	{
		newItem = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:[c description]
																		action:@selector(chooseCatalog:)
																 keyEquivalent:@""];
		[newItem setTarget:self];
		[newItem setTag:[c catalogValue]];
		[[btnEncodingCatalog menu] addItem:newItem];
	}
	[btnEncodingCatalog sizeToFit];
	
}

- (IBAction)chooseEncoding:(id)sender
{
	NSMenuItem *item = (NSMenuItem *)sender;
	if ([item parentItem]) {
		[btnEncodingCatalog selectItemWithTag:[[item parentItem] tag]];
		[self chooseCatalog:[item parentItem]];
	}
	[btnEncoding selectItemWithTag:[(NSMenuItem *)sender tag]];
	[self setEncoding:[(NSMenuItem *)sender tag]];
}

- (IBAction)chooseCatalog:(id)sender
{
	[[btnEncoding menu] removeAllItems];
	
	NSMenuItem *newItem;
	CharacterEncodingUtil *util = [[CharacterEncodingUtil alloc] init];
	
	NSInteger aValue = [(NSMenuItem *)sender tag];
	for (CharacterEncoding *e in [util encodings:aValue]) {
		newItem = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:[e description]
																	   action:@selector(chooseEncoding:)
																 keyEquivalent:@""];
		[newItem setTag:[e encodingCode]];
		[newItem setTarget:self];
		[[btnEncoding menu] addItem:newItem];
	}
	
	[btnEncoding sizeToFit];
	[self chooseEncoding:[btnEncoding itemAtIndex:0]];
}

@end
