//
//  NutronObjectViewController.m
//  Nutron
//
//  Created by Jeff Buck on 9/24/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//

#import "objc/runtime.h"
#import "Nu/Nu.h"
#import "Nutron.h"
#import "NutronObjectView.h"
#import "NutronObjectViewController.h"
#import "NutronRuntime.h"


@implementation NutronCachedObject

@synthesize object = _object;
@synthesize cachedObject = _cachedObject;
@synthesize parent = _parent;
@synthesize ivar = _ivar;
@synthesize key = _key;
@synthesize index = _index;


+ (NutronCachedObject*)nutronCachedObjectForObject:(id)item withParent:(id)p key:(NSString*)k index:(int)i
{
	NutronDebug(@"cachedObjectForObject: %@", item);
	
	NutronCachedObject* object = nil;
	
	if ([item isKindOfClass:[NSDictionary class]])
	{
		object = [[[NutronCachedDictionary alloc] initWithObject:item parent:p key:k index:i] autorelease];
	}
	else if ([item isKindOfClass:[NSArray class]])
	{
		object = [[[NutronCachedArray alloc] initWithObject:item parent:p key:k index:i] autorelease];
	}
	else if ([item isKindOfClass:[NuSymbolTable class]])
	{
		object = [[[NutronCachedSymbolTable alloc] initWithObject:item parent:p key:k index:i] autorelease];
	}
	else if ([item isKindOfClass:[NSObject class]])
	{
		object = [[[NutronCachedObject alloc] initWithObject:item parent:p key:k index:i] autorelease];
	}
	else
	{
		assert(0);
	}
	
	return object;
}

- (id)initWithObject:(id)o parent:(id)p key:(NSString*)k index:(int)i
{
	self = [super init];
	
	if (self == nil)
		return nil;

	_object = [o retain];
	_parent = [p retain];
	_key = [k copy];
	_index = i;

	return self;
}

- (void)dealloc
{
	[_object release];
	[_cachedObject release];
	[_parent release];
	[_children release];
	[_ivar release];
	[_key release];
	
	[super dealloc];
}

- (NSString*)name
{
	return _key;

	if (_ivar)
	{
		return [_ivar name];
	}
	else if ([_parent isKindOfClass:[NSDictionary class]])
	{
		return [_parent valueForKey:_key];
	}
	else if ([_parent isKindOfClass:[NSArray class]])
	{
		return [NSString stringWithFormat:@"%d", _index];
	}
	else
	{
		return @"Unknown";
	}
}

- (NSString*)type
{
	if (_object)
	{
		NSString* className = [_object className];
		
		if (   _ivar
			&& (   ([className isEqualToString:@"NSCFNumber"])
			    || ([className isEqualToString:@"NSNull"])))
		{
			// We can be more precise
			return [[_ivar type]
					mapTypeEncodingToObjcEncoding:[_ivar typeEncoding]];
		}
		else
		{
			return className;
		}
	}
	else if (_ivar)
	{
		return [_ivar typeEncoding];
	}
	else
	{
		return @"Unknown";
	}
}

- (id)value
{
	return [_object stringValue];
}

- (BOOL)isAtomicTypeEncoding:(NSString*)typeEncoding
{
	if (   ([typeEncoding isEqualToString:@"@"]) 
		|| ([typeEncoding length] > 1))
	{
		// typeEncoding length > 1 is a class name, so not atomic
		return NO;
	}
	else
	{
		// int, char, etc.
		return YES;
	}
}

- (BOOL)isExpandable
{
	// Depends on if the type of ivar is expandable
	if (_object == nil)
	{
		return NO;
	}
	else if (_ivar)
	{
		NSString* typeEncoding = [[_ivar type] typeEncoding];
		NutronDebug(@"  cachedIvar: %@  typeEncoding: %@  type: %@",
			  [_ivar name],
			  typeEncoding,
			  [_ivar type]);
		
		return ![self isAtomicTypeEncoding:typeEncoding];
	}
	else if ([_object isKindOfClass:[NSObject class]])
	{
		return YES;
	}
	else
	{
		return NO;
	}
}

- (NSArray*)children
{
	if (_children)
		return _children;
	
	if (_object == nil)
	{
		// Can have a null object at this node
		// If so, it's a leaf
		return nil;
	}

	if (   _ivar
		&& ([self isAtomicTypeEncoding:[_ivar typeEncoding]]))
	{
		// Atomic types like int, double, etc. don't have children
		return nil;
	}
	else
	{
		// We're an object. Return ivars by default
		_children = [[NSMutableArray alloc] init];
		
		NutronRuntimeClass* objectClass = [[[NutronRuntimeClass alloc]
										  initWithName:[_object className]]
										 autorelease];
		if (objectClass)
		{
			NSArray* ivarArray = [objectClass ivars];
			
			int ivarCount = [ivarArray count];

			for (int i = 0; i < ivarCount; i++)
			{
				NutronRuntimeIvar* nutronIvar = [ivarArray objectAtIndex:i];

				id ivarValue = [_object valueForIvar:[nutronIvar name]];

				NutronCachedObject* child = [NutronCachedObject nutronCachedObjectForObject:ivarValue 
																				 withParent:self
																						key:[nutronIvar name]
																					  index:i];
				child.ivar = nutronIvar;
		
				[_children addObject:child];
			}
			
			return _children;
		}
		else
		{
			assert(0);
		}
	}
}


- (int)numberOfChildren
{	
	return [[self children] count];
}

- (id)childAtIndex:(int)i
{
	return [[self children] objectAtIndex:i];
}

@end


@implementation NutronCachedSymbolTable

- (id)initWithObject:(id)symbolTable parent:(id)p key:(NSString*)k index:(int)i
{
	self = [super initWithObject:symbolTable parent:p key:k index:i];
	
	if (self == nil)
		return nil;
	
	_cachedObject = [[symbolTable all] retain];

	return self;
}

- (void)dealloc
{
	[super dealloc];
}

- (id)value
{
	return [NSString stringWithFormat:@"%d Items", [_cachedObject count]];
}

- (BOOL)isExpandable
{
	return YES;
}

- (NSArray*)children
{
	if (_children)
		return _children;
	
	int symbolCount = [_cachedObject count];
	
	if (symbolCount == 0)
		return nil;
	
	_children = [[NSMutableArray alloc] initWithCapacity:symbolCount];

	for (int i = 0; i < symbolCount; i++)
	{
		NuSymbol* symbol = [_cachedObject objectAtIndex:i];

		NutronCachedObject* child = [NutronCachedObject nutronCachedObjectForObject:symbol
																		 withParent:self
																				key:[symbol description]
																			  index:i];
		[_children addObject:child];
	}
	
	return _children;
}

- (int)numberOfChildren
{
	return [_cachedObject count];
}

@end


@implementation NutronCachedDictionary

- (id)initWithObject:(id)dictionary parent:(id)p key:(NSString*)k index:(int)i
{
	self = [super initWithObject:dictionary parent:p key:k index:i];
	
	if (self == nil)
		return nil;
	
	_cachedObject = [[dictionary allKeys] retain];
	
	return self;
}

- (void)dealloc
{
	[super dealloc];
}

- (id)value
{
	return [NSString stringWithFormat:@"%d Items", [_cachedObject count]];
}

- (BOOL)isExpandable
{
	return (_cachedObject && ([_cachedObject count] > 0));
}

- (NSArray*)children
{
	if (_children)
		return _children;
	
	int keyCount = [_cachedObject count];
	
	if (keyCount == 0)
		return nil;

	_children = [[NSMutableArray alloc] initWithCapacity:keyCount];
	
	for (int i = 0; i < keyCount; i++)
	{
		// itemKey could be a string or a NuSymbol so use an id
		id itemKey = [_cachedObject objectAtIndex:i];

		id value = [_object objectForKey:itemKey];
		NutronCachedObject* child = [NutronCachedObject nutronCachedObjectForObject:value
																		 withParent:self
																				key:itemKey
																			  index:i];
		[_children addObject:child];
	}
	
	return _children;
}

- (int)numberOfChildren
{
	return [_cachedObject count];
}

@end


@implementation NutronCachedArray

- (id)initWithObject:(id)array parent:(id)p key:(NSString*)k index:(int)i
{
	self = [super initWithObject:array parent:p key:k index:i];
	
	if (self == nil)
		return nil;
	
	return self;
}

- (void)dealloc
{
	[super dealloc];
}

- (id)value
{
	return [NSString stringWithFormat:@"%d Items", [_object count]];
}

- (BOOL)isExpandable
{
	return (_object && ([_object count] > 0));
}

- (NSArray*)children
{
	if (_children)
		return _children;
	
	int keyCount = [_object count];

	if (keyCount == 0)
		return nil;
	
	_children = [[NSMutableArray alloc] initWithCapacity:keyCount];

	for (int i = 0; i < keyCount; i++)
	{
		id itemKey = [NSString stringWithFormat:@"%d", i];
		id value = [_object objectAtIndex:i];
		NutronCachedObject* child = [NutronCachedObject nutronCachedObjectForObject:value
																		 withParent:self
																				key:itemKey
																			  index:i];
		[_children addObject:child];
	}
	
	return _children;
}

- (int)numberOfChildren
{
	return [_object count];
}

@end




@implementation NutronObjectViewController

@synthesize outlineView = _outlineView;
@synthesize scrollView = _scrollView;
@synthesize rootObject = _rootObject;

- (id)initWithFrame:(NSRect)frame rootObject:(id)object
{
	self = [super init];

	if (self)
	{
		_rootObject = [[NutronCachedObject nutronCachedObjectForObject:object
															withParent:nil
																   key:nil
																 index:-1] retain];
		
		_outlineView = [[NutronObjectView alloc] initWithFrame:NSMakeRect(0,
																		  0,
																		  frame.size.width,
																		  frame.size.height)];
		[_outlineView setAutoresizingMask:(NSViewHeightSizable | NSViewWidthSizable)];

		_scrollView = [[NSScrollView scrollViewWrappedAroundView:_outlineView withFrame:frame] retain];
		
		[_outlineView setDelegate:self];
		[_outlineView setDataSource:self];
		[_outlineView setUsesAlternatingRowBackgroundColors:YES];
		
		NSTableColumn* tc;
		
		tc = [[NSTableColumn alloc] initWithIdentifier:@"Key"];
		[[tc headerCell] setStringValue:@"Key"];
		[tc setWidth:200.0];
		[_outlineView addTableColumn:tc];
		[_outlineView setOutlineTableColumn:tc];
		[tc release];
		
		tc = [[NSTableColumn alloc] initWithIdentifier:@"Type"];
		[[tc headerCell] setStringValue:@"Type"];
		[tc setWidth:200.0];
		[_outlineView addTableColumn:tc];
		[tc release];
		
		tc = [[NSTableColumn alloc] initWithIdentifier:@"Value"];
		[[tc headerCell] setStringValue:@"Value"];
		[tc setWidth:300.0];
		[_outlineView addTableColumn:tc];
		[tc release];
		
		[_outlineView reloadData];
	}

	return self;
}

- (void)dealloc
{
	[_scrollView release];
	[_outlineView release];
	[_rootObject release];

	[super dealloc];
}



#pragma mark -
#pragma mark NSOutlineViewDataSource methods

- (BOOL)outlineView:(NSOutlineView*)ov isItemExpandable:(id)item
{
	NutronCachedObject* object = (NutronCachedObject*)item;
	
	if (object == nil)
		object = _rootObject;

	NutronDebug(@"isItemExpandable %@", [object description]);
	return [object isExpandable];
}

- (NSInteger)outlineView:(NSOutlineView*)ov numberOfChildrenOfItem:(id)item
{
	NutronCachedObject* object = (NutronCachedObject*)item;
	
	if (object == nil)
		object = _rootObject;

	NutronDebug(@"# of children: item %@", object);
	return [object numberOfChildren];
}

- (id)outlineView:(NSOutlineView *)ov child:(NSInteger)index ofItem:(id)item
{
	NutronCachedObject* object = (NutronCachedObject*)item;

	if (object == nil)
		object = _rootObject;
	
	NutronDebug(@"child:%d ofItem:%@", index, object);
	return [object childAtIndex:index];
}

- (id)outlineView:(NSOutlineView *)ov objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
	NutronDebug(@"objectValueForTableColumn:%@ byItem:%@", tableColumn, item);

	NutronCachedObject* object = (NutronCachedObject*)item;
	
	if (object == nil)
		object = _rootObject;

	NSString* columnName = [[tableColumn headerCell] stringValue];

	if ([columnName compare:@"Key"] == NSOrderedSame)
	{
		return [object name];
	}
	else if ([columnName compare:@"Type"] == NSOrderedSame)
	{
		return [object type];
	}
	else
	{
		id value = [object value];
			
		if ([value respondsToSelector:@selector(description)])
			return [value description];
		else if ([value respondsToSelector:@selector(stringValue)])
			return [value stringValue];
		else
			return @"Unknown CachedObject Value";
	}
}


#pragma mark -
#pragma mark NSOutlineViewDelegate methods

- (BOOL)outlineView:(NSOutlineView*)ov shouldSelectItem:(id)item
{
	// Disable selection of headers (ivars, global, etc.)
	return YES;
}

- (BOOL)outlineView:(NSOutlineView*)ov shouldEditTableColumn:(NSTableColumn*)tc item:(id)item
{
	return NO;
}


@end
