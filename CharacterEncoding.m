//
//  CharacterEncoding.m
//  iMusicTags
//
//  Created by Kevin Chen on 10-8-24.
//  Copyright 2010 KevinChen's workstation. All rights reserved.
//

#import "CharacterEncoding.h"


@implementation CharacterEncoding

@synthesize description;
@synthesize encodingType;
@synthesize encodingCode;

- (id)initWithCode:(CFStringEncoding)anEncodingCode desciption:(NSString *)aDescription type:(NSInteger)aType
{
	if ([super init]) {
		[self setEncodingType:aType];
		[self setEncodingCode:anEncodingCode];
		[self setDescription:aDescription];
		
		return self;
	}
	
	return nil;
}

- (void)dealloc
{
	[super dealloc];
	[description release];
}

@end

@implementation CharacterCatalog

- (id)initWithValue:(NSInteger)aValue description:(NSString *)aDescription
{
	if ([super init]) {
		[self setCatalogValue:aValue];
		[self setDescription:aDescription];
		
		return self;
	}
	return nil;
}

+ (NSArray *)catalogs
{
	NSMutableArray *catalogs = [[NSMutableArray alloc] init];
	
	// Choose Catalog mention
	[catalogs addObject:[[CharacterCatalog alloc] initWithValue:C_CATALOG_CHOOSE
													description:@"          "]];
	
	// Simplified Chinese
	[catalogs addObject:[[CharacterCatalog alloc] initWithValue:C_SIMPLIFIED_CHINESE
													description:@"Simplified Chinese"]];
	
	// Traditional Chinese
	[catalogs addObject:[[CharacterCatalog alloc] initWithValue:C_TRADITIONAL_CHINESE
													description:@"Traditional Chinese"]];
	
	return catalogs;
					
}

@synthesize catalogValue;
@synthesize description;

@end


@implementation CharacterEncodingUtil

- (NSArray *)encodings:(NSInteger)catalogType
{
	NSArray *encodings = [[NSMutableArray alloc] init];
	
	switch (catalogType) {
		case C_SIMPLIFIED_CHINESE:
			encodings = [self simplifiedChinese];
			break;
		case C_TRADITIONAL_CHINESE:
			encodings = [self traditionalChinese];
			break;
			
		default:
			break;
	}
	return encodings;
}

- (NSArray *)simplifiedChinese
{
	NSMutableArray *encodings = [[NSMutableArray alloc] init];
	
	// GB18030
	[encodings addObject:[[CharacterEncoding alloc] initWithCode:kCFStringEncodingGB_18030_2000
													  desciption:@"18030"
															type:C_SIMPLIFIED_CHINESE]];
	// GBK
	[encodings addObject:[[CharacterEncoding alloc] initWithCode:kCFStringEncodingGBK_95
													  desciption:@"GBK" 
															type:C_SIMPLIFIED_CHINESE]];
	
	// GB2312
	[encodings addObject:[[CharacterEncoding alloc] initWithCode:kCFStringEncodingGB_2312_80
													  desciption:@"2312"
															type:C_SIMPLIFIED_CHINESE]];
	return encodings;
}

- (NSArray *)traditionalChinese
{
	NSMutableArray *encodings = [[NSMutableArray alloc] init];
	
	[encodings addObject:[[CharacterEncoding alloc] initWithCode:kCFStringEncodingBig5
													  desciption:@"BIG5"
															type:C_TRADITIONAL_CHINESE]];
	[encodings addObject:[[CharacterEncoding alloc] initWithCode:kCFStringEncodingBig5_E
													  desciption:@"BIG5_E"
															type:C_TRADITIONAL_CHINESE]];
	[encodings addObject:[[CharacterEncoding alloc] initWithCode:kCFStringEncodingBig5_HKSCS_1999
													  desciption:@"BIG5_HKSCS" 
															type:C_TRADITIONAL_CHINESE]];
	
	return encodings;
}

@end





