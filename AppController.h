//
//  AppController.h
//  Mp3ID3TagDemo
//
//  Created by Kevin Chen on 10-7-23.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MusicFileInfo.h"

@interface AppController : NSObject {
	NSMutableSet *fileSet;
	NSMutableArray *fileUrls;
	NSMutableArray *displayInfo;
	IBOutlet NSTableView *tableView;
	IBOutlet NSButton *preview;
	IBOutlet NSButton *confirm;
	IBOutlet NSPopUpButton *btnEncoding;
	IBOutlet NSMenu *mEncoding;
	IBOutlet NSMenuItem *miEncoding;
	IBOutlet NSControl *deleteControl;
	
	CFStringEncoding encoding;
}

- (IBAction)open:(id)sender;
- (IBAction)deleteRows:(id)sender;
- (IBAction)preview:(id)sender;
- (IBAction)convert:(id)sender;
- (IBAction)chooseEncoding:(id)sender;

- (void)initEncodingMenu;
- (void)initEncodingPopUpButton;

@property CFStringEncoding encoding;

@end
