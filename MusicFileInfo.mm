//
//  MusicFileInfo.m
//  iMusicTags
//
//  Created by Kevin Chen on 10-7-23.
//  Copyright 2010 Kevin Chen's workstation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MusicFileInfo.h"

#import <TagLib/taglib.h>
#import <TagLib/tag.h>
#import <TagLib/fileref.h>
#import <TagLib/tstring.h>
#import <TagLib/mpegfile.h>
#import <TagLib/id3v1tag.h>
#import <TagLib/id3v2tag.h>


@implementation MusicFileInfo

- (id)initWithUrl:(NSURL *)aUrl
{
	return [self initWithUrl:aUrl withEncoding:kCFStringEncodingUTF8];
}

- (id)initWithUrl:(NSURL *)aUrl withEncoding:(CFStringEncoding)anEncoding
{
	self = [super init];
	if (self) {
		fileUrl = aUrl;
		guessEncoding = anEncoding;
		
		TagLib::FileRef fileRef([[aUrl path] UTF8String]);
		
		if (fileRef.isNull()) {
			return nil;
		}
		TagLib::Tag *tag = fileRef.tag();
		NSString *extension = [aUrl pathExtension];
		if ([extension isEqualToString:@"mp3"]) {
			[self mp3Info:aUrl encoding:anEncoding];
		}
				
		self.track = tag->track();
		self.year = tag->year();
	}
			
	return self;
}

- (void)writeTags
{
		
}

- (void)writeTagsWithEncoding:(CFStringEncoding)anEncoding
{
	
}
- (void)dealloc
{
	[title release];
	[artist release];
	[album release];
	[genre release];
	[super dealloc];
}

- (NSUInteger)hash
{
	return [self.fileUrl hash];
}

- (BOOL)isEqual:(id)object
{
	if ([object isKindOfClass:[MusicFileInfo class]]) {
		return NO;
	}
	
	if (nil == [(MusicFileInfo *)object fileUrl]) {
		return NO;
	}
	
	return [self.fileUrl isEqual:[(MusicFileInfo *)object fileUrl]];
}

- (void)mp3Info:(NSURL *)aUrl encoding:(CFStringEncoding)anEncoding
{
	TagLib::MPEG::File file([[aUrl path] UTF8String]);
	
	TagLib::Tag *tag;
	
	if ([self hasID3v2Tag:aUrl]) {
		tag = file.ID3v2Tag();
	}else {
		tag = file.ID3v1Tag();
	}
	
	if (kCFStringEncodingUTF8 == anEncoding) {
		self.title = [NSString stringWithCString:tag->title().toCString(true)
										encoding:NSUTF8StringEncoding];
		self.artist = [NSString stringWithCString:tag->artist().toCString(true)
										 encoding:NSUTF8StringEncoding];
		self.album = [NSString stringWithCString:tag->album().toCString(true)
										encoding:NSUTF8StringEncoding];
		self.genre = [NSString stringWithCString:tag->genre().toCString(true)
										encoding:NSUTF8StringEncoding];
	} else {
		self.title = [NSString stringWithCString:tag->title().toCString()
										encoding:CFStringConvertEncodingToNSStringEncoding(anEncoding)];
		self.artist = [NSString stringWithCString:tag->artist().toCString()
										 encoding:CFStringConvertEncodingToNSStringEncoding(anEncoding)];
		
		self.album = [NSString stringWithCString:tag->album().toCString()
										encoding:CFStringConvertEncodingToNSStringEncoding(anEncoding)];
		self.genre = [NSString stringWithCString:tag->genre().toCString()
										encoding:CFStringConvertEncodingToNSStringEncoding(anEncoding)];
	}
	

}

- (BOOL)hasID3v2Tag:(NSURL *)aUrl
{
	NSError *error;
	NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingFromURL:aUrl error:&error];
	[fileHandle seekToFileOffset:0L];
	NSData *data = [fileHandle readDataOfLength:3];
	NSString *id3v2id = [[NSString alloc] initWithCString:(const char *)[data bytes]];
	if ([id3v2id isEqual:@"ID3"]) {
		[fileHandle closeFile];
		return YES;
	}
	
	[fileHandle closeFile];
	return NO;
}

@synthesize title;
@synthesize artist;
@synthesize album;
@synthesize genre;
@synthesize year;
@synthesize track;
@synthesize fileUrl;

@end
