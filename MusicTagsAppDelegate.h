//
//  MusicTagsAppDelegate.h
//  iMusicTags
//
//  Created by Kevin Chen on 10-7-16.
//  Copyright 2010 Kevin Chen's workstation. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MusicTagsAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
}

@property (assign) IBOutlet NSWindow *window;

@end
