//
//  NutronObjectViewController.h
//  Nutron
//
//  Created by Jeff Buck on 9/24/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//

#import <Cocoa/Cocoa.h>

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
}

@property (nonatomic, retain) id parent;
@property (nonatomic, retain) id object;
@property (nonatomic, retain) id cachedObject;
@property (nonatomic, retain) NutronRuntimeIvar* ivar;
@property (nonatomic, copy) NSString* key;
@property (nonatomic, assign) int index;

- (id)initWithObject:(id)o parent:(id)p key:(NSString*)k index:(int)i;

- (NSString*)name;
- (NSString*)type;
- (id)value;

- (BOOL)isExpandable;

- (int)numberOfChildren;
- (id)childAtIndex:(int)i;

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




@interface NutronObjectViewController : NSObject <NSOutlineViewDelegate,
												  NSOutlineViewDataSource>
{
	NSOutlineView*			_outlineView;
	NSScrollView*			_scrollView;

	id						_rootObject;
}

@property (nonatomic, retain) NSOutlineView* outlineView;
@property (nonatomic, retain) NSScrollView* scrollView;
@property (nonatomic, retain) id rootObject;

- (id)initWithFrame:(NSRect)frame rootObject:(id)object;

@end
