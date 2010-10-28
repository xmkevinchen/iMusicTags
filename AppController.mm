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
	
	NSMutableArray *content = [[NSMutableArray alloc] initWithObjects:[[CharacterCatalog alloc] initWithValue:C_CATALOG_CHOOSE
																								  description:@""], nil];
	[content addObjectsFromArray:[CharacterCatalog catalogs]];						   
	
	[catalogCtrl setContent:content];
}

- (id)init
{
	self = [super init];
	if (self) {
		encoding = kCFStringEncodingInvalidId;
	}
	
	return self;
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
	if (encoding == kCFStringEncodingInvalidId) {
		NSString *imageName = [[NSBundle mainBundle] pathForResource:@"iMusicTags" ofType:@"icns"];
		NSImage* imageObj = [[NSImage alloc] initWithContentsOfFile:imageName];
		NSAlert *alert = [NSAlert alertWithMessageText:@"Pick up an Encoding, dude" defaultButton:@"Return"
									   alternateButton:nil
										   otherButton:nil
							 informativeTextWithFormat:@"Please choose an encoding before preview music information"];
		[alert setIcon:imageObj];
		[alert runModal];
		[alert release];
		return;
		
	}
	
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
	if (encoding == kCFStringEncodingInvalidId) {
		NSString *imageName = [[NSBundle mainBundle] pathForResource:@"iMusicTags" ofType:@"icns"];
		NSImage* imageObj = [[NSImage alloc] initWithContentsOfFile:imageName];
		NSAlert *alert = [NSAlert alertWithMessageText:@"Pick up an Encoding, dude" defaultButton:@"Return"
									   alternateButton:nil
										   otherButton:nil
							 informativeTextWithFormat:@"Please choose an encoding before convert music information"];
		[alert setIcon:imageObj];
		[alert runModal];
		[alert release];
		return;
	}
	
	for (id info in displayInfo) {
		[(MusicFileInfo *)info writeTags:encoding];
	}
	
	[displayInfo removeAllObjects];
	[fileUrls removeAllObjects];
	[fileSet removeAllObjects];
	[tableView reloadData];
	
	NSBeep();
}


- (IBAction)chooseEncoding:(id)sender
{
	NSInteger selectedEncoding = [[[encodingCtrl selection] valueForKey:@"encodingCode"] intValue];
	encoding = selectedEncoding;
}

- (IBAction)chooseCatalog:(id)sender {
	CharacterEncodingUtil *util = [[CharacterEncodingUtil alloc] init];
	NSInteger catalogType = [[[catalogCtrl selection] valueForKey:@"catalogType"] intValue];
	
	NSMutableArray *content = [[NSMutableArray alloc] initWithObjects:
							   [[CharacterEncoding alloc] initWithEncoding:kCFStringEncodingInvalidId 
																desciption:@"" 
																	  type:catalogType], nil];
	
	
	[content addObjectsFromArray:[util encodings:catalogType]];
	[encodingCtrl setContent:content];
}

@end
