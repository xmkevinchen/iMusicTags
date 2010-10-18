//
//  MusicFileInfo.h
//  iMusicTags
//
//  Created by Kevin Chen on 10-7-23.
//  Copyright 2010 Kevin Chen's workstation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MusicFileInfo : NSObject {

	NSString *title;
	NSString *artist;
	NSString *album;
	NSString *genre;
	NSInteger year;
	NSInteger track;
	
	NSURL *fileUrl;
	CFStringEncoding guessEncoding;
}

- (id)initWithUrl:(NSURL *)aUrl;
- (id)initWithUrl:(NSURL *)aUrl withEncoding:(CFStringEncoding)anEncoding;
- (void)writeTags;
- (void)writeTags:(CFStringEncoding)anEncoding;

- (void)readMPEGInfo:(NSURL *)aUrl encoding:(CFStringEncoding)anEncoding;
- (void)writeMPEGInfo:(NSURL *)aUrl encoding:(CFStringEncoding)anEncoding;
- (BOOL)hasID3v2Tag:(NSURL *)aUrl;

@property (readwrite, copy) NSString *title;
@property (readwrite, copy) NSString *artist;
@property (readwrite, copy) NSString *album;
@property (readwrite, copy) NSString *genre;
@property (readwrite) NSInteger year;
@property (readwrite) NSInteger track;
@property (readwrite, copy) NSURL *fileUrl;

@end
