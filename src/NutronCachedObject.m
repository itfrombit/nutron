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
@synthesize isExpanded = _isExpanded;

@class NSConcreteValue;

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
	else if ([item isKindOfClass:NSClassFromString(@"NSConcreteValue")])
	{
		object = [[[NutronCachedConcreteValue alloc] initWithObject:item parent:p key:k index:i] autorelease];
	}
	else if ([item isKindOfClass:[NSObject class]])
	{
		object = [[[NutronCachedObject alloc] initWithObject:item parent:p key:k index:i] autorelease];
	}
	else if (item == nil)
	{
		object = [[[NutronCachedObject alloc] initWithObject:[NSNull null] parent:p key:k index:i] autorelease];
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
		else if (   [_key isKindOfClass:[NSString class]]
				 && [_key isEqualToString:@"isa"])
		{
			return [_object name];
		}
		else
		{
			return className;
		}
	}
	else if (_ivar)
	{
		// It's an ivar, but is nil, so use the static pointer type
		return [_ivar typeEncoding];
	}
	else
	{
		return @"Unknown";
	}
}

- (id)value
{
	if (   [_key isKindOfClass:[NSString class]]
		&& [_key isEqualToString:@"isa"])
	{
		return @"";
	}
	else
	{
		return [_object stringValue];
	}
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
		
		NutronRuntimeClass* objectClass = nil;

		if (   [_object isKindOfClass:[NutronRuntimeClass class]]
			&& [_key isKindOfClass:[NSString class]]
			&& [_key isEqualToString:@"isa"])
		{
			objectClass = [[[NutronRuntimeClass alloc] initWithName:[_object name]] autorelease];
		}
		else
		{
			objectClass = [[[NutronRuntimeClass alloc] initWithName:[_object className]] autorelease];
		}
		
		NSArray* ivarArray = nil;

		if (objectClass)
		{
			NSString* superclassName = [objectClass superclassName];
	
			// If we have a super class, insert an isa object for superclass' ivars
			if (   superclassName
				&& ![superclassName isEqualToString:@""]
				&& ![superclassName isEqualToString:@"nil"])
			{
				NutronRuntimeClass* superclass = [[[NutronRuntimeClass alloc]
												   initWithName:superclassName]
												  autorelease];

				NutronCachedObject* isaChild = [NutronCachedObject nutronCachedObjectForObject:superclass
																					  withParent:self
																							 key:@"isa"
																						   index:-1];
				[_children addObject:isaChild];
			}
			
			// Insert our ivars
			id objectWithIvars = nil;
			id ivarParent = nil;

			if (   [_key isKindOfClass:[NSString class]]
				&& [_key isEqualToString:@"isa"])
			{
				// We're getting superclass ivars.
				// Link to the parent object, as it is the one
				// we will query for ivar values.
				ivarArray = [_object ivars];
				
				// Walk up the isa hierarchy until we find our root object
				id ancestor = _parent;
				while (   [[ancestor key] isKindOfClass:[NSString class]]
					   && [[ancestor key] isEqualToString:@"isa"])
				{
					ancestor = [ancestor parent];
				}
				
				objectWithIvars = [ancestor object];
				ivarParent = _parent;
			}
			else
			{
				// We're getting the immediate ivars (not those of a superclass),
				// so we're the parent object.
				ivarArray = [objectClass ivars];
				objectWithIvars = _object;
				ivarParent = self;
			}

			int ivarCount = [ivarArray count];

			for (int i = 0; i < ivarCount; i++)
			{
				NutronRuntimeIvar* nutronIvar = [ivarArray objectAtIndex:i];
				
				id ivarValue;

				NSString* ivarTypeEncoding = [nutronIvar typeEncoding];
				if ([ivarTypeEncoding characterAtIndex:0] == '{')
				{
					if (   ([[ivarTypeEncoding substringToIndex:7] isEqualToString:@"{CGRect"])
					    || ([[ivarTypeEncoding substringToIndex:8] isEqualToString:@"{CGPoint"])
						|| ([[ivarTypeEncoding substringToIndex:7] isEqualToString:@"{CGSize"]))
					{
						// Let the NSConcreteValue fall through.
						ivarValue = [objectWithIvars valueForKey:[nutronIvar name]];
					}
					else
					{
						// Otherwise, we have a struct that we don't map yet.
						ivarValue = [NSNull null];						
					}
				}
				else
				{
					ivarValue = [objectWithIvars valueForIvar:[nutronIvar name]];
				}

				NutronCachedObject* child = [NutronCachedObject nutronCachedObjectForObject:ivarValue 
																				 withParent:ivarParent
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


@implementation NutronCachedConcreteValue

- (id)initWithObject:(id)o parent:(id)p key:(NSString*)k index:(int)i
{
	self = [super initWithObject:o parent:p key:k index:i];
	
	if (self == nil)
		return nil;
	
	return self;
}

- (void)dealloc
{
	[super dealloc];
}

- (BOOL)isExpandable
{
	return NO;
}

- (id)type
{
	return [[_ivar type] mapTypeEncodingToObjcEncoding:[_ivar typeEncoding]];
}

- (id)value
{
	return [_object description];
}

@end


@implementation NutronCachedSymbolTable

- (id)initWithObject:(id)symbolTable parent:(id)p key:(NSString*)k index:(int)i
{
	self = [super initWithObject:symbolTable parent:p key:k index:i];
	
	if (self == nil)
		return nil;
	
	_cachedObject = [[[symbolTable all] sort] retain];
	
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
	
	_cachedObject = [[[dictionary allKeys] sortedArrayUsingComparator:^(id a, id b) {
						return [[a stringValue] compare:[b stringValue]];
					} ] retain];
	
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
	if (_parent == nil)
	{
		return @"<root class>";
	}
	else if (   [[_parent object] isKindOfClass:[NutronRuntimeClass class]]
			 || [[_parent object] isKindOfClass:[NutronRuntimeIvar class]]
			 || [[_parent object] isKindOfClass:[NutronRuntimeProperty class]])
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
	if ([_object isKindOfClass:[NutronRuntimeClass class]])
	{
		return [_object name];
	}	
	else if (   [[_parent object] isKindOfClass:[NutronRuntimeClass class]]
			 || [[_parent object] isKindOfClass:[NutronRuntimeIvar class]]
			 || [[_parent object] isKindOfClass:[NutronRuntimeProperty class]])
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
	return (   [_object isKindOfClass:[NutronRuntimeClass class]]
			|| [[_parent object] isKindOfClass:[NutronRuntimeClass class]]
			|| (   [_object isKindOfClass:[NutronRuntimeIvar class]] 
				&& ![self isAtomicTypeEncoding:[_object typeEncoding]])
			|| (   [_object isKindOfClass:[NutronRuntimeProperty class]] 
				&& ![self isAtomicTypeEncoding:[(NutronRuntimeType*)[_object type] typeEncoding]]));
	
	//	return (_object != nil) || ((_object == nil) && (_key != nil));
}

- (int)numberOfChildren
{
	if ([_key isEqualToString:@"object"])
	{
		return [[self children] count];
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
	else if (   [_object isKindOfClass:[NutronRuntimeIvar class]]
			 || [_object isKindOfClass:[NutronRuntimeProperty class]])
	{
		return [[self children] count];
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
	
	if (   [_object isKindOfClass:[NutronRuntimeClass class]]
		|| [_object isKindOfClass:[NutronRuntimeIvar class]]
		|| [_object isKindOfClass:[NutronRuntimeProperty class]])
	{
		_children = [[NSMutableArray alloc] init];

		NutronCachedRuntimeObject* child;
		id childObject = nil;
		id parentObject = nil;
		NSString* objectClassName;
		
		if ([_object isKindOfClass:[NutronRuntimeClass class]])
		{
			objectClassName = [_object name];
			parentObject = self;
		}
		else
		{
			objectClassName = [[_object type] className];
			NutronRuntimeClass* nrc = [[[NutronRuntimeClass alloc] initWithName:objectClassName] autorelease];
			parentObject = [[[NutronCachedRuntimeObject alloc] initWithObject:nrc parent:self key:@"object" index:-1] autorelease];
		}
		
		// If this class has a superclass, add it as an 'isa'-type item
		Class objectClass = NSClassFromString(objectClassName);
		if (objectClass != nil)
		{
			Class objectSuperClass = class_getSuperclass(objectClass);
			
			if (objectSuperClass != nil)
			{
				const char* szSuperclassName = class_getName(objectSuperClass);
				NSString* superclassName = [NSString stringWithCString:szSuperclassName
															  encoding:NSUTF8StringEncoding];
				NutronRuntimeClass* pnrc = [[[NutronRuntimeClass alloc] initWithName:superclassName] autorelease];
				child = [[[NutronCachedRuntimeObject alloc] initWithObject:pnrc parent:self key:@"object" index:-1] autorelease];
				[_children addObject:child];
			}
		}
		
		child = [[[NutronCachedRuntimeObject alloc] initWithObject:childObject parent:parentObject key:@"ivars" index:-1] autorelease];
		[_children addObject:child];
		child = [[[NutronCachedRuntimeObject alloc] initWithObject:childObject parent:parentObject key:@"properties" index:-1] autorelease];
		[_children addObject:child];
		child = [[[NutronCachedRuntimeObject alloc] initWithObject:childObject parent:parentObject key:@"class methods" index:-1] autorelease];
		[_children addObject:child];
		child = [[[NutronCachedRuntimeObject alloc] initWithObject:childObject parent:parentObject key:@"instance methods" index:-1] autorelease];
		[_children addObject:child];
		child = [[[NutronCachedRuntimeObject alloc] initWithObject:childObject parent:parentObject key:@"protocols" index:-1] autorelease];
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


