//
//  AppController.mm
//  Mp3ID3TagDemo
//
//  Created by Kevin Chen on 10-7-23.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AppController.h"
#import "MusicFileInfo.h"

@implementation AppController

@synthesize encoding;

- (void)awakeFromNib
{
	[tableView registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType,nil]];
	
	// Initialize Encoding Menu 
	[self initEncodingMenu];
	
	// Initialize Encoding Popup Button 
	[self initEncodingPopUpButton];
	
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
		[fileUrls removeObject:[file url]];
		[fileSet removeObject:[file url]];
	}
	[displayInfo removeObjectsAtIndexes:selected];
	
	[tableView reloadData];
	[tableView deselectAll:self];
	free(indexBuff);
}

- (IBAction)convert:(id)sender
{
	for (id info in displayInfo) {
		[(MusicFileInfo *)info writeTags:encoding];
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
	
	[mEncoding setAutoenablesItems:NO];
	
	// Simplified Chinese Submenu
	NSMenuItem *spChineseItem = [[[NSMenuItem allocWithZone:[NSMenu menuZone]] 
								  initWithTitle:NSLocalizedString(@"MENU_ENCODING_ITEM_SIMPLIFIED_CHINESE",@"Simplified Chinese") 
								  action:nil
								  keyEquivalent:@""] autorelease];
	NSMenu *mspChinese = [[[NSMenu allocWithZone:[NSMenu menuZone]] 
						   initWithTitle:NSLocalizedString(@"MENU_ENCODING_SUBMENU_SIMPLIFIED_CHINESE",@"Simplified Chinese")] 
						  autorelease];
	//[mspChinese setAutoenablesItems:NO];
	[spChineseItem setSubmenu:mspChinese];
	
	//	// GBK
	//	newItem = [[[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:@"GBK"
	//																	action:@selector(chooseEncoding:)
	//															 keyEquivalent:@""] autorelease];
	//	[newItem setTag:kCFStringEncodingGBK_95];
	//	[newItem setTarget:self];
	//	[mspChinese addItem:newItem];
	
	//	// GB2312
	//	newItem = [[[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:@"GB2312"
	//																	action:@selector(chooseEncoding:)
	//															 keyEquivalent:@""] autorelease];
	//	[newItem setTag:kCFStringEncodingGB_2312_80];
	//	[newItem setTarget:self];
	//	[mspChinese addItem:newItem];
	//
	// GB18030
	newItem = [[[NSMenuItem allocWithZone:[NSMenu menuZone]] 
				initWithTitle:NSLocalizedString(@"MENU_ENCODING_ITEM_SIMPLIFIED_CHINESE",@"GB18030")
				action:@selector(chooseEncoding:)
				keyEquivalent:@""] autorelease];
	[newItem setTag:kCFStringEncodingGB_18030_2000];
	[newItem setTarget:self];
	[mspChinese addItem:newItem];
	
	[mEncoding addItem:spChineseItem];
	
	// Traditional Chinese Submenu
	NSMenuItem *tcChineseItem = [[[NSMenuItem allocWithZone:[NSMenu menuZone]]
								  initWithTitle:NSLocalizedString(@"MENU_ENCODING_SUBMENU_TRADITIONAL_CHINESE",@"Traditional Chinese") 
								  action:@selector(chooseEncoding:)
								  keyEquivalent:@""] autorelease];
	
	NSMenu *mtcChinese = [[[NSMenu allocWithZone:[NSMenu menuZone]] 
						   initWithTitle:NSLocalizedString(@"MENU_ENCODING_SUBMENU_TRADITIONAL_CHINESE",@"Traditional Chinese")] 
						  autorelease];
	[tcChineseItem setSubmenu:mtcChinese];
	
	// Big5
	newItem = [[[NSMenuItem allocWithZone:[NSMenu menuZone]] 
				initWithTitle:NSLocalizedString(@"MENU_ENCODING_ITEM_TRADITIONAL_CHINESE_COMMON",@"Common")
					   action:@selector(chooseEncoding:)
				keyEquivalent:@""] autorelease];
	[newItem setTag:kCFStringEncodingBig5];
	[newItem setTarget:self];
	[mtcChinese addItem:newItem];
	
	// Big5_TW
	newItem = [[[NSMenuItem allocWithZone:[NSMenu menuZone]] 
				initWithTitle:NSLocalizedString(@"MENU_ENCODING_ITEM_TRADITIONAL_CHINESE_TAIWAN",@"Taiwan")
					   action:@selector(chooseEncoding:)
				keyEquivalent:@""] autorelease];
	[newItem setTag:kCFStringEncodingBig5_E];
	[newItem setTarget:self];
	[mtcChinese addItem:newItem];
	
	
	// Big5_HK
	newItem = [[[NSMenuItem allocWithZone:[NSMenu menuZone]] 
				initWithTitle:NSLocalizedString(@"MENU_ENCODING_ITEM_TRADITIONAL_CHINESE_HK",@"HongKong")
					   action:@selector(chooseEncoding:)
				keyEquivalent:@""] autorelease];
	[newItem setTag:kCFStringEncodingBig5_HKSCS_1999];
	[newItem setTarget:self];
	[mtcChinese addItem:newItem];
	
	
	[mEncoding addItem:tcChineseItem];
	
}

/*!
 @method initEncodingPopUpButton    
 @abstract   Initialize the Encoding Popup Button with specified character encoding
 @discussion 
 */
- (void)initEncodingPopUpButton
{
	
	NSMenuItem *newItem;
	
	// empty option
	//	newItem = [[[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:@"Please choose encoding"
	//																	action:@selector(chooseEncoding:)
	//															 keyEquivalent:@""] autorelease];
	//	[newItem setTag:0];
	//	[newItem setTarget:self];
	//	[[btnEncoding menu] addItem:newItem];
	
	// GB18030
	newItem = [[[NSMenuItem allocWithZone:[NSMenu menuZone]] 
				initWithTitle:NSLocalizedString(@"POPUPBTN_OPTION_SIMPLIFIED_CHINESE",@"Simplified Chinese")
					   action:@selector(chooseEncoding:)
				keyEquivalent:@""] autorelease];
	[newItem setTag:kCFStringEncodingGB_18030_2000];
	[newItem setTarget:self];
	[[btnEncoding menu] addItem:newItem];
	
	//	// GB2312
	//	newItem = [[[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:@"GB2312"
	//																	action:@selector(chooseEncoding:)
	//															 keyEquivalent:@""] autorelease];
	//	[newItem setTag:kCFStringEncodingGB_2312_80];
	//	[newItem setTarget:self];
	//	[[btnEncoding menu] addItem:newItem];
	//	
	//	// GBK
	//	newItem = [[[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:@"GBK"
	//																	action:@selector(chooseEncoding:)
	//															 keyEquivalent:@""] autorelease];
	//	[newItem setTag:kCFStringEncodingGBK_95];
	//	[newItem setTarget:self];
	//	[[btnEncoding menu] addItem:newItem];
	
	// Big5
	newItem = [[[NSMenuItem allocWithZone:[NSMenu menuZone]] 
				initWithTitle:NSLocalizedString(@"POPUPBTN_OPTION_TRADITIONAL_CHINESE_COMMON", @"Traditional Chinese")
					   action:@selector(chooseEncoding:)
				keyEquivalent:@""] autorelease];
	[newItem setTag:kCFStringEncodingBig5];
	[newItem setTarget:self];
	[[btnEncoding menu] addItem:newItem];
	
	// Big5_TW
	newItem = [[[NSMenuItem allocWithZone:[NSMenu menuZone]] 
				initWithTitle:NSLocalizedString(@"POPUPBTN_OPTION_TRADITIONAL_CHINESE_TAIWAN",@"Traditional Chinese -- Taiwan")
					   action:@selector(chooseEncoding:)
				keyEquivalent:@""] autorelease];
	[newItem setTag:kCFStringEncodingBig5_E];
	[newItem setTarget:self];
	[[btnEncoding menu] addItem:newItem];
	
	// Big5_HK
	newItem = [[[NSMenuItem allocWithZone:[NSMenu menuZone]] 
				initWithTitle:NSLocalizedString(@"POPUPBTN_OPTION_TRADITIONAL_CHINESE_HK", @"Traditional Chinese -- HongKong")
					   action:@selector(chooseEncoding:)
				keyEquivalent:@""] autorelease];
	[newItem setTag:kCFStringEncodingBig5_HKSCS_1999];
	[newItem setTarget:self];
	[[btnEncoding menu] addItem:newItem];
	
	[btnEncoding sizeToFit];
	[self setEncoding:kCFStringEncodingGBK_95];
}

- (IBAction)chooseEncoding:(id)sender
{
	[btnEncoding selectItemWithTag:[(NSMenuItem *)sender tag]];
	[self setEncoding:[(NSMenuItem *)sender tag]];
}

@end
