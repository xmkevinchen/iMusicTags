//
//  CharacterEncoding.h
//  iMusicTags
//
//  Created by Kevin Chen on 10-8-24.
//  Copyright 2010 KevinChen's workstation. All rights reserved.
//

#import <Cocoa/Cocoa.h>


enum E_CharacterCatalog {
	C_SIMPLIFIED_CHINESE = 0,
	C_TRADITIONAL_CHINESE = 1,
	C_LAST_ONE = 0xFF
};

@interface CharacterEncoding : NSObject {
	NSString *description;
	NSInteger encodingType;
	NSInteger encodingCode;
}

@property NSInteger encodingType;
@property NSInteger encodingCode;
@property(readwrite, copy) NSString *description;

- (id) initWithCode:(CFStringEncoding)anEncodingCode desciption:(NSString *)aDescription type:(NSInteger)aType;

@end

@interface CharacterCatalog : NSObject
{
	NSString *description;
	NSInteger catalogValue;
}

@property NSInteger catalogValue;
@property(readwrite, copy)NSString *description;

+ (NSArray *)catalogs;

@end


@interface CharacterEncodingUtil : NSObject

- (NSArray *)encodings:(NSInteger)catalogType;

@end


@interface CharacterEncodingUtil (Private)

- (NSArray *)simplifiedChinese;
- (NSArray *)traditionalChinese;
@end


