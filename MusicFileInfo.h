//
//  MyAudioFile.h
//  Mp3ID3TagDemo
//
//  Created by Kevin Chen on 10-7-23.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TagLib/taglib.h"
#import "TagLib/tag.h"
#import "TagLib/fileref.h"
#import "TagLib/tstring.h"
#import "TagLib/id3v2tag.h"

@interface MusicFileInfo : NSObject {

	NSString *title;
	NSString *artist;
	NSString *album;
	NSString *genre;
	NSUInteger year;
	NSUInteger track;
	NSURL *url;
}

- (id)initWithUrl:(NSURL *)fileUrl;
- (id)initWithUrl:(NSURL *)fileUrl withEncoding:(CFStringEncoding)encoding;
- (void)writeTags:(CFStringEncoding)encoding;
- (void)setAlbumArt:(NSImage *)image;

@property (readwrite, copy) NSString *title;
@property (readwrite, copy) NSString *artist;
@property (readwrite, copy) NSString *album;
@property (readwrite, copy) NSString *genre;
@property NSUInteger year;
@property NSUInteger track;
@property (readwrite, assign) NSURL *url;

@end
