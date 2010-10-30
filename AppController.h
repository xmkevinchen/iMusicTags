//
//  AppController.h
//  iMusicTags
//
//  Created by Kevin Chen on 10-7-23.
//  Copyright 2010 Kevin Chen's workstation. All rights reserved.
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
	IBOutlet NSPopUpButton *btnEncodingCatalog;
	IBOutlet NSPopUpButton *btnEncoding;

	CFStringEncoding encoding;

	IBOutlet NSArrayController *catalogCtrl;
	IBOutlet NSArrayController *encodingCtrl;
	IBOutlet NSControl *deleteControl;
	
	IBOutlet NSWindow *window;

}

- (IBAction)open:(id)sender;
- (IBAction)deleteRows:(id)sender;
- (IBAction)preview:(id)sender;
- (IBAction)convert:(id)sender;
- (IBAction)chooseEncoding:(id)sender;
- (IBAction)chooseCatalog:(id)sender;
- (IBAction)newWindow:(id)sender;


@property CFStringEncoding encoding;
@property(assign) NSWindow *window;

@end
