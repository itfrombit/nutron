//
//  NutronCachedObject.h
//  Nutron
//
//  Created by Jeff Buck on 10/2/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define kNutronCachedObjectKeyIsa               @"isa"

#define kNutronCachedObjectKeyObject            @"object"
#define kNutronCachedObjectKeyIvars             @"ivars"
#define kNutronCachedObjectKeyProperties        @"properties"
#define kNutronCachedObjectKeyClassMethods      @"class methods"
#define kNutronCachedObjectKeyInstanceMethods   @"instanceMethods"
#define kNutronCachedObjectKeyProtocols         @"protocols"


@class NutronRuntimeIvar;

@interface NutronCachedObject : NSObject
{
	id					_object;
	id					_cachedObject;
	id					_parent;
	NSMutableArray*		_children;

	NutronRuntimeIvar*	_ivar;
	NSString*			_key;
	int					_index;

	NSString*			_name;
	NSString*			_type;
	id					_value;

	BOOL				_isExpanded;
}

@property (nonatomic, retain) id parent;
@property (nonatomic, retain) id object;
@property (nonatomic, retain) id cachedObject;
@property (nonatomic, retain) NutronRuntimeIvar* ivar;
@property (nonatomic, copy) NSString* key;
@property (nonatomic, assign) int index;
@property (nonatomic, assign) BOOL isExpanded;

+ (NutronCachedObject*)nutronCachedObjectForObject:(id)item withParent:(id)p key:(NSString*)k index:(int)i;

- (id)initWithObject:(id)o parent:(id)p key:(NSString*)k index:(int)i;

- (NSString*)name;
- (NSString*)type;
- (id)value;

- (BOOL)isExpandable;

- (int)numberOfChildren;
- (NSArray*)children;
- (id)childAtIndex:(int)i;

@end


@interface NutronCachedConcreteValue : NutronCachedObject
{
}

- (id)initWithObject:(id)o parent:(id)p key:(NSString*)k index:(int)i;

@end


@interface NutronCachedSymbolTable : NutronCachedObject
{
}

- (id)initWithObject:(id)symbolTable parent:(id)p key:(NSString*)k index:(int)i;

@end


@interface NutronCachedDictionary : NutronCachedObject

- (id)initWithObject:(id)dictionary parent:(id)p key:(NSString*)k index:(int)i;

@end


@interface NutronCachedArray : NutronCachedObject

- (id)initWithObject:(id)array parent:(id)p key:(NSString*)k index:(int)i;

@end


@interface NutronCachedRuntimeObject : NutronCachedObject

- (id)initWithObject:(id)runtimeClass parent:(id)p key:(NSString*)k index:(int)i;

@end

