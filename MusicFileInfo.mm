//
//  MyAudioFile.m
//  Mp3ID3TagDemo
//
//  Created by Kevin Chen on 10-7-23.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MusicFileInfo.h"

@implementation MusicFileInfo


- (id)initWithUrl:(NSURL *)fileUrl
{
	if ([super init]) {
		TagLib::FileRef fileRef([[fileUrl path] UTF8String]);
		
		if (fileRef.file() == nil)
			return nil;
		
		TagLib::Tag *tag = fileRef.tag();
		self.title = [NSString stringWithCString:tag->title().toCString(true) 
										encoding:NSUTF8StringEncoding];
		self.album = [NSString stringWithCString:tag->album().toCString(true)
										encoding:NSUTF8StringEncoding];
		self.artist = [NSString stringWithCString:tag->artist().toCString(true)
										 encoding:NSUTF8StringEncoding];
		self.genre = [NSString stringWithCString:tag->genre().toCString(true)
										encoding:NSUTF8StringEncoding];
		self.year = tag->year();
		self.track = tag->track();
		
		self.url = fileUrl;
		
		return self;
		
	}
	
	return nil;
	
}

- (id)initWithUrl:(NSURL *)fileUrl withEncoding:(CFStringEncoding)encoding
{
	if ([super init]) {
		TagLib::FileRef fileRef([[fileUrl path] UTF8String]);
		
		if (fileRef.file() == nil)
			return nil;
		

		TagLib::Tag *tag = fileRef.tag();
		
		self.title = (NSString *)CFStringCreateWithCString(kCFAllocatorDefault, 
														   tag->title().toCString(), 
														   encoding);
		self.album = (NSString *)CFStringCreateWithCString(kCFAllocatorDefault, 
														   tag->album().toCString(), 
														   encoding);
		self.artist = (NSString *)CFStringCreateWithCString(kCFAllocatorDefault, 
															tag->artist().toCString(), 
															encoding);
		self.genre = (NSString *)CFStringCreateWithCString(kCFAllocatorDefault, 
														   tag->genre().toCString(), 
														   encoding);
		self.url = fileUrl;
		self.year = tag->year();
		self.track = tag->track();
		
		return self;
		
	}
	
	return nil;
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
	return [self.url hash];
}

- (BOOL)isEqual:(id)object
{
	if ([object isKindOfClass:[MusicFileInfo class]]) {
		return NO;
	}
	
	if (nil == [(MusicFileInfo *)object url]) {
		return NO;
	}
	
	return [self.url isEqual:[(MusicFileInfo *)object url]];
}

- (void)writeTags:(CFStringEncoding)encoding
{
	if (nil == self.url) {
		return;
	}
	
	// Use UTF-8 as the default encoding 
	(TagLib::ID3v2::FrameFactory::instance())->setDefaultTextEncoding(TagLib::String::UTF8);
	
	TagLib::FileRef fileRef([[self.url path] UTF8String]);
	TagLib::Tag *tag = fileRef.tag();
	
	// Title
	NSString *sTitle = (NSString *)CFStringCreateWithCString(kCFAllocatorDefault, 
												tag->title().toCString(), 
												encoding);
	tag->setTitle(TagLib::String([sTitle UTF8String], TagLib::String::UTF8));
	
	// Artist
	NSString *sArtist = (NSString *)CFStringCreateWithCString(kCFAllocatorDefault, 
															 tag->artist().toCString(), 
															 encoding);
	tag->setArtist(TagLib::String([sArtist UTF8String], TagLib::String::UTF8));
		
	// Album
	NSString *sAlbum = (NSString *)CFStringCreateWithCString(kCFAllocatorDefault, 
															 tag->album().toCString(), 
															 encoding);
	tag->setAlbum(TagLib::String([sAlbum UTF8String], TagLib::String::UTF8));
	
	// Genre
	NSString *sGenre = (NSString *)CFStringCreateWithCString(kCFAllocatorDefault, 
															tag->genre().toCString(), 
															encoding);
	tag->setGenre(TagLib::String([sGenre UTF8String], TagLib::String::UTF8));
	
	fileRef.save();
}

- (void)setAlbumArt:(NSImage *)image
{
	
}

@synthesize title;
@synthesize artist;
@synthesize album;
@synthesize genre;
@synthesize year;
@synthesize track;
@synthesize url;

@end
