//
//  NutronCachedObject.m
//  Nutron
//
//  Created by Jeff Buck on 10/2/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//

#import "objc/runtime.h"
#import "Nu/Nu.h"
#import "Nutron.h"
#import "NutronRuntime.h"
#import "NutronCachedObject.h"

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


@implementation NutronCachedRuntimeObject

- (id)initWithObject:(id)runtimeClass parent:(id)p key:(NSString*)k index:(int)i
{
	self = [super initWithObject:runtimeClass parent:p key:k index:i];
	
	if (self == nil)
		return nil;
	
	return self;
}

- (void)dealloc
{
	[super dealloc];
}

- (NSString*)name
{
	if ([[_parent object] isKindOfClass:[NutronRuntimeClass class]])
	{
		return @"";
	}
	else
	{
		return _key;
	}
}

- (NSString*)type
{
	if ([[_parent object] isKindOfClass:[NutronRuntimeClass class]])
	{
		return [NSString stringWithFormat:@"%@ (%d)", _key, [self numberOfChildren]];
	}
	else
	{
		if ([_object isKindOfClass:[NutronRuntimeIvar class]])
		{
			return [[(NutronRuntimeIvar*)_object type] objcEncoding];
		}
		else if ([_object isKindOfClass:[NutronRuntimeProperty class]])
		{
			return [[(NutronRuntimeProperty*)_object type] objcEncoding];
		}
		else if ([_object isKindOfClass:[NutronRuntimeMethod class]])
		{
			return [[(NutronRuntimeMethod*)_object returnType] objcEncoding];
		}
		else if ([_object isKindOfClass:[NutronRuntimeProtocol class]])
		{
			return @"";
		}
	}
	
	return @"";
}

- (NSString*)value
{
	if (_object)
	{
		return [_object description];
	}
	else
	{
		return [NSString stringWithFormat:@"%@ (%d)", _key, [self numberOfChildren]];
	}
}

- (BOOL)isExpandable
{
	return ([_object isKindOfClass:[NutronRuntimeClass class]]
			|| [[_parent object] isKindOfClass:[NutronRuntimeClass class]]);

	//	return (_object != nil) || ((_object == nil) && (_key != nil));
}

- (int)numberOfChildren
{
	if ([_key isEqualToString:@"object"])
	{
		return 5;
	}
	else if ([_key isEqualToString:@"ivars"])
	{
		return [[[_parent object] ivars] count];
	}
	else if ([_key isEqualToString:@"properties"])
	{
		return [[[_parent object] properties] count];
	}
	else if ([_key isEqualToString:@"class methods"])
	{
		return [[[_parent object] classMethods] count];
	}
	else if ([_key isEqualToString:@"instance methods"])
	{
		return [[[_parent object] instanceMethods] count];
	}
	else if ([_key isEqualToString:@"protocols"])
	{
		return [[[_parent object] protocols] count];
	}

	return 0;
}

- (NSMutableArray*)childrenArrayForObjects:(NSArray*)array
{
	int count = [array count];
	
	NSMutableArray* childArray = [[NSMutableArray alloc] init];

	for (int i = 0; i < count; i++)
	{
		id childObject = [array objectAtIndex:i];
		
		NSString* childKey;

		if ([_key isEqualToString:@"protocols"])
		{
			childKey = [childObject name];
		}
		else
		{
			childKey = [childObject name];	// objcDeclaration
		}

		NutronCachedRuntimeObject* child = [[[NutronCachedRuntimeObject alloc]
											 initWithObject:childObject
											 parent:self
											 key:childKey
											 index:i] autorelease];
		[childArray addObject:child];
	}
	
	return [childArray autorelease];
}

- (NSArray*)children
{
	if (_children)
		return _children;
	
	
	if ([_object isKindOfClass:[NutronRuntimeClass class]])
	{
		_children = [[NSMutableArray alloc] init];

		NutronCachedRuntimeObject* child;
		
		child = [[[NutronCachedRuntimeObject alloc] initWithObject:nil parent:self key:@"ivars" index:-1] autorelease];
		[_children addObject:child];
		child = [[[NutronCachedRuntimeObject alloc] initWithObject:nil parent:self key:@"properties" index:-1] autorelease];
		[_children addObject:child];
		child = [[[NutronCachedRuntimeObject alloc] initWithObject:nil parent:self key:@"class methods" index:-1] autorelease];
		[_children addObject:child];
		child = [[[NutronCachedRuntimeObject alloc] initWithObject:nil parent:self key:@"instance methods" index:-1] autorelease];
		[_children addObject:child];
		child = [[[NutronCachedRuntimeObject alloc] initWithObject:nil parent:self key:@"protocols" index:-1] autorelease];
		[_children addObject:child];
	}
	else if ([_key isEqualToString:@"ivars"])
	{
		_children = [[self childrenArrayForObjects:[[_parent object] ivars]] retain];
	}
	else if ([_key isEqualToString:@"properties"])
	{
		_children = [[self childrenArrayForObjects:(NSArray*)[[_parent object] properties]] retain];
	}
	else if ([_key isEqualToString:@"class methods"])
	{
		_children = [[self childrenArrayForObjects:[[_parent object] classMethods]] retain];
	}
	else if ([_key isEqualToString:@"instance methods"])
	{
		_children = [[self childrenArrayForObjects:[[_parent object] instanceMethods]] retain];
	}
	else if ([_key isEqualToString:@"protocols"])
	{
		_children = [[self childrenArrayForObjects:[[_parent object] protocols]] retain];
	}	
	else if ([_object isKindOfClass:[NutronRuntimeIvar class]])
	{

	}
	else if ([_object isKindOfClass:[NutronRuntimeProperty class]])
	{

	}
	else if ([_object isKindOfClass:[NutronRuntimeMethod class]])
	{

	}
	else if ([_object isKindOfClass:[NutronRuntimeProtocol class]])
	{

	}


	return _children;
}

@end


