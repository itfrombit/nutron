//
//  NutronRuntime.m
//  Nutron
//
//  Created by Jeff Buck on 4/16/08.
//  Copyright 2008 Jeff Buck. All rights reserved.

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

#import "Nu/Nu.h"
#import "NutronRuntime.h"

@interface NSMutableArray (toPlist)
- (NSMutableArray*) toPlist;
@end

@implementation NSMutableArray (toPlist)
- (NSMutableArray*) toPlist
{
	NSMutableArray* a = [NSMutableArray array];
	for (id item in self)
	{
		[a addObject:[item toPlist]];
	}
	
	return a;
}
@end

///////////////////////////////////////////////////////////////
@implementation NutronRuntimeType

@synthesize name = _name;
@synthesize typeEncoding = _typeEncoding;
@synthesize objcEncoding = _objcEncoding;
@synthesize objcEncodingSuffix = _objcEncodingSuffix;
//@synthesize properties;

+ (NSString*) mapNativeType:(NSString*)typeEncoding
{
	static NSDictionary*	typeDictionary = nil;
	
	if (typeDictionary == nil)
	{		
		// From Objective-C 2.0 Programming Language, pg. 123
		typeDictionary = [[NSDictionary dictionaryWithObjectsAndKeys:
		@"char",					@"c",
		@"int",						@"i",
		@"short",					@"s",
		@"long",					@"l",
		@"long long",				@"q",
		@"unsigned char",			@"C",
		@"unsigned int",			@"I",
		@"unsigned short",			@"S",
		@"unsigned long",			@"L",
		@"unsigned long long",		@"Q",
		@"float",					@"f",
		@"double",					@"d",
		@"BOOL",					@"B",
		@"void",					@"v",
		@"char*",					@"*",
		@"SEL",						@":",
		@"Class",					@"#",
		@"void*",					@"?",
		nil] retain];
	}

	return [typeDictionary objectForKey:typeEncoding];
}

- (NSString*) mapTypeEncodingToObjcEncoding:(NSString*)encoding
{
	NSString*	objcType = nil;
	NSString*	objcTypeSuffix = [NSString stringWithString:@""];
	NSString*	tag;
	NSRange		range;

	char		c = [encoding characterAtIndex:0];
	int			idx;

	switch (c) 
	{
		case '@':
			if ([encoding length] == 1)
				objcType = @"id";
			else
				objcType = [NSString stringWithFormat:@"%@*",
					[encoding substringWithRange:NSMakeRange(2,[encoding length] - 3)]];
			break;

		case '^':	/* pointer */
			if ([encoding characterAtIndex:1] == '?')
				// Likely a function pointer, but no other details are given
				// by the objc runtime.
				objcType = @"void (*functionPtr)()";
			else
				objcType = [NSString stringWithFormat:@"%@*", 
							[self mapTypeEncodingToObjcEncoding:
							 [encoding substringFromIndex:1]]];
			break;

		case '[':	// array: [12i]
			idx = 1;
			while (isdigit([encoding characterAtIndex:idx]))
			{
				++idx;
			}
			objcTypeSuffix = [NSString stringWithFormat:@"[%@]",
								[encoding substringWithRange:NSMakeRange(1,idx-1)]];
			objcType = [self mapTypeEncodingToObjcEncoding:
						 [encoding substringFromIndex:idx]];
			break;

		case '{':	// struct: {tag="name1"type1"name2"type2}
		case '(':	// union:  (tag="name1"type1"name2"type2)
			range = [encoding rangeOfString:@"=" 
									options:NSLiteralSearch
									  range:NSMakeRange(1, [encoding length] - 1)];
			if (range.location == NSNotFound)
			{
				// There may not be an =
				tag = [encoding substringWithRange:NSMakeRange(1, [encoding length] - 2)];
			}
			else
			{
				// This needs more parsing work...
				tag = [encoding substringWithRange:NSMakeRange(1, range.location - 1)];
			}

			if (c == '{')
				objcType = [NSString stringWithFormat:@"struct %@", tag];
			else
				objcType = [NSString stringWithFormat:@"union %@", tag];

			break;

		default:
			objcType = [NutronRuntimeType mapNativeType:[encoding substringToIndex:1]];
			break;
	}

	if (objcType)
		self.objcEncoding = [NSString stringWithString:objcType];
	else
		self.objcEncoding = @"";

	self.objcEncodingSuffix = [NSString stringWithString:objcTypeSuffix];

	return self.objcEncoding;
}


- (id) initWithTypeEncoding:(NSString*)encoding
{
	self = [super init];

	self.typeEncoding = encoding; //[encoding copy];
	[self mapTypeEncodingToObjcEncoding:encoding];

	return self;
}

- (NSString*) className
{
	NSString* typecode = [self typeEncoding];
	
	if ([typecode characterAtIndex:0] == '@')
	{
		if ([typecode length] == 1)
			return @"id";
		else
			return [typecode substringWithRange:NSMakeRange(2,[typecode length] - 3)];
	}
	else
	{
		return nil;
	}
	
}

- (void) dealloc
{
	[super dealloc];
}


- (void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeObject:_typeEncoding forKey:@"typeEncoding"];
}

- (id)initWithCoder:(NSCoder *)coder
{
	NSString* encoding = [coder decodeObjectForKey:@"typeEncoding"];
	return [self initWithTypeEncoding:encoding];
}


- (NSMutableDictionary*) toPlist
{
	NSMutableDictionary* d = [NSMutableDictionary dictionary];

	[d setObject:_typeEncoding forKey:@"typeEncoding"];

	return d;
}

- (id) initWithPlist:(NSMutableDictionary*) plist
{
	NSString* encoding = [plist objectForKey:@"typeEncoding"];
	return [self initWithTypeEncoding:encoding];
}

- (NSString*) toJSON
{
	NSString* s = @"";

	return s;
}

- (id) initWithJSON:(NSString*) json
{
	return nil;
}

- (NSString*) description
{
	return [NSString stringWithFormat:@"%@  (%@)",
				[self typeEncoding], 
				[self objcEncoding]];
}

@end


///////////////////////////////////////////////////////////////
@implementation NutronRuntimeIvar

@synthesize	name = _name;
@synthesize	typeEncoding = _typeEncoding;
@synthesize	type = _type;
@synthesize	offset = _offset;

//@synthesize properties;

- (id) initWithName:(NSString*)aName typeEncoding:(NSString*)aTypeEncoding offset:(long)anOffset
{
	self = [super init];
//	properties = [[NSMutableDictionary alloc] init];
	
//	[properties setValue:name forKey:@"name"];
//	[properties setValue:typeEncoding forKey:@"typeEncoding"];
//	[properties setValue:[NSNumber numberWithLong:offset] forKey:@"offset"];
	
//	[properties setValue:[[NutronRuntimeType alloc] initWithTypeEncoding:typeEncoding] 
//				forKey:@"type"];

	self.name = aName;
	self.typeEncoding = aTypeEncoding;
	self.offset = anOffset;

	self.type = [[[NutronRuntimeType alloc] initWithTypeEncoding:aTypeEncoding] autorelease];

	return self;
}


- (void) dealloc
{
	[_type release];
//	[properties release];
	[super dealloc];
}


- (void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeObject:_name forKey:@"name"];
	[coder encodeObject:_typeEncoding forKey:@"typeEncoding"];
	[coder encodeInt:_offset forKey:@"offset"];
}

- (id)initWithCoder:(NSCoder *)coder
{
	NSString* cName = [coder decodeObjectForKey:@"name"];
	NSString* cTypeEncoding = [coder decodeObjectForKey:@"typeEncoding"];
	int cOffset = [coder decodeIntForKey:@"offset"];
	return [self initWithName:cName typeEncoding:cTypeEncoding offset:cOffset];
}


- (NSMutableDictionary*) toPlist
{
	NSMutableDictionary* d = [NSMutableDictionary dictionary];
	
	[d setObject:_name forKey:@"name"];
	[d setObject:_typeEncoding forKey:@"typeEncoding"];
	[d setObject:[NSNumber numberWithInt:_offset] forKey:@"offset"];
	
	return d;
}


- (id) initWithPlist:(NSMutableDictionary*) plist
{
	NSString* cName = [plist objectForKey:@"name"];
	NSString* cTypeEncoding = [plist objectForKey:@"typeEncoding"];
	int cOffset = [[plist objectForKey:@"offset"] intValue];

	return [self initWithName:cName typeEncoding:cTypeEncoding offset:cOffset];
}


- (NSString*) description
{
	return [NSString stringWithFormat:@"  %@  %@  %@  %d", 
		_name,
		_typeEncoding,
		[_type description],
		_offset];
//		[properties valueForKey:@"name"], 
//		[properties valueForKey:@"typeEncoding"],
//		[properties valueForKey:@"type.description"], 
//		[properties valueForKey:@"offset"]];
}


- (NSString*) objcDeclaration
{
	NSMutableString* d = [NSMutableString string];

	[d appendFormat:@"%@ %@", [_type objcEncoding], _name];

	if ([[_type objcEncodingSuffix] length] > 0)
	{
		[d appendString:[_type objcEncodingSuffix]];
	}
	
	[d appendString:@";"];
		
	return d;
}


- (NSString*) nuDeclaration
{
	NSMutableString* d = [NSMutableString string];

	[d appendFormat:@"(%@) %@", [_type objcEncoding], _name];

	if ([[_type objcEncodingSuffix] length] > 0)
	{
		[d appendString:[_type objcEncodingSuffix]];
	}
	
	return d;	
}

@end


///////////////////////////////////////////////////////////////
@implementation NutronRuntimeMethod

@synthesize name = _name;
@synthesize selector = _selector;
@synthesize returnType = _returnType;
@synthesize methodType = _methodType;
@synthesize args = _args;
@synthesize method = _method;

- (id) init
{
	self = [super init];

	_args = [[NSMutableArray alloc] init];
	
	return self;
}

- (void) dealloc
{
	[_args release];
	[_returnType release];

	[super dealloc];
}


- (void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeObject:_name forKey:@"name"];
//	[coder encodeObject:selector forKey:@"selector"];
	[coder encodeObject:_returnType forKey:@"returnType"];
	[coder encodeInt:_methodType forKey:@"methodType"];
	[coder encodeObject:_args forKey:@"args"];
}

- (id)initWithCoder:(NSCoder *)coder
{
	self = [super init];

	self.name = [coder decodeObjectForKey:@"name"];
//  selector = [coder decodeObjectForKey:@"selector"];
	self.returnType = [coder decodeObjectForKey:@"returnType"];
	self.methodType = [coder decodeIntForKey:@"methodType"];
	self.args = [coder decodeObjectForKey:@"args"];

	return self;
}


- (NSMutableDictionary*) toPlist
{
	NSMutableDictionary* d = [NSMutableDictionary dictionary];
	
	[d setObject:_name forKey:@"name"];
	[d setObject:[_returnType toPlist] forKey:@"returnType"];
	[d setObject:[NSNumber numberWithInt:_methodType] forKey:@"methodType"];
	[d setObject:[_args toPlist] forKey:@"args"];

	return d;
}


- (id) initWithPlist:(NSMutableDictionary*) plist
{
    self = [super init];

	self.name = [plist objectForKey:@"name"];

//  selector = [plist objectForKey:@"selector"];
	self.returnType = [[[NutronRuntimeType alloc] initWithPlist:[plist objectForKey:@"returnType"]] autorelease];
	self.methodType = [[plist objectForKey:@"methodType"] intValue];
	self.args = [[[NSMutableArray alloc] initWithPlist:@"args"] autorelease];

	return self;
}


- (void) addArgument:(NutronRuntimeType*)anArg
{
	[_args addObject:anArg];
}


- (NSString*) objcDeclarationRoot
{
	NSMutableString* d = [NSMutableString string];
	
	if (_methodType == NutronRuntimeMethodType_Instance)
		[d appendString:@"- "];
	else
		[d appendString:@"+ "];
	
	[d appendFormat:@"(%@) ", [_returnType objcEncoding]];
	
	// Parse the method name to intersperse the arguments
	int idx = 0;
	int argIdx = 0;

	int length = [_name length];

	while (idx < length)
	{	
		NSString* fragment;

		NSRange range= [_name rangeOfString:@":"
									 options:NSLiteralSearch
									   range:NSMakeRange(idx, length - idx)];
		if (range.location == NSNotFound)
		{
			fragment = [_name substringWithRange:NSMakeRange(idx, length - idx)];
			idx = length;
		}
		else
		{
			fragment = [_name substringWithRange:NSMakeRange(idx, range.location - idx)];
			idx = range.location + 1;
		}
		
		if (argIdx > 0)
			[d appendFormat:@" "];

		[d appendFormat:@"%@", fragment];
		
		if (range.location != NSNotFound)
		{
			[d appendFormat:@":(%@)arg%d", [[_args objectAtIndex:argIdx] objcEncoding], argIdx + 1];
		}
		
		++argIdx;
	}

	return d;	
}


- (NSString*) objcDeclaration
{
	return [NSString stringWithFormat:@"%@;",
			[self objcDeclarationRoot]];
}


- (NSString*) objcImplementation
{
	return [NSString stringWithFormat:@"%@\n{\n    return nil;\n}",
			[self objcDeclarationRoot]];
}


- (NSString*) nuDeclarationRoot
{
	NSMutableString* d = [NSMutableString string];
	
	if (_methodType == NutronRuntimeMethodType_Instance)
		[d appendString:@"(- "];
	else
		[d appendString:@"(+ "];
	
	[d appendFormat:@"(%@) ", [_returnType objcEncoding]];
	
	// Parse the method name to intersperse the arguments
	int idx = 0;
	int argIdx = 0;

	int length = [_name length];

	while (idx < length)
	{	
		NSString* fragment;

		NSRange range= [_name rangeOfString:@":"
									 options:NSLiteralSearch
									   range:NSMakeRange(idx, length - idx)];
		if (range.location == NSNotFound)
		{
			fragment = [_name substringWithRange:NSMakeRange(idx, length - idx)];
			idx = length;
		}
		else
		{
			fragment = [_name substringWithRange:NSMakeRange(idx, range.location - idx)];
			idx = range.location + 1;
		}
		
		if (argIdx > 0)
			[d appendFormat:@" "];

		[d appendFormat:@"%@", fragment];
		
		if (range.location != NSNotFound)
		{
			[d appendFormat:@":(%@)arg%d", [[_args objectAtIndex:argIdx] objcEncoding], argIdx + 1];
		}
		
		++argIdx;
	}

	return d;
}


@class NuClass;
@class NuBlock;
@class NuMethod;

- (NSString*) nuDeclaration
{
	NSMutableString* d = [NSMutableString string];

	[d appendString:[self nuDeclarationRoot]];
	[d appendString:@" is nil)"];
	
	return d;
}

- (NSString*) nuImplementation
{
	NSMutableString* d = [NSMutableString string];

	[d appendString:[self nuDeclarationRoot]];

	id numethod = [[[NuMethod alloc] initWithMethod:_method] autorelease];
	id block = [numethod block];
	
	if (block == nil)
	{
		[d appendString:@" is nil)"];
	}
	else
	{
		[d appendFormat:@" is %@\n", [block stringValue]];
	}

	return d;
}


- (NSString*) description
{
	NSMutableString* d = [NSMutableString string];
	
	[d appendFormat:@"  (%@) %@", [_returnType objcEncoding], _name];
	
	int i;
	for (i = 0; i < [_args count]; i++)
	{
		[d appendFormat:@" (%@)", [[_args objectAtIndex:i] objcEncoding]];
	}
	
	return d;
}

@end


///////////////////////////////////////////////////////////////
@implementation NutronRuntimeProperty

@synthesize			name = _name;
@synthesize			attributes = _attributes;
@synthesize			type = _type;
@synthesize			getter = _getter;
@synthesize			setter = _setter;
@synthesize			isReadOnly = _isReadOnly;
@synthesize			isCopied = _isCopied;
@synthesize			isRetained = _isRetained;
@synthesize			isNonatomic = _isNonatomic;
@synthesize			isStrongRef = _isStrongRef;
@synthesize			isWeakRef = _isWeakRef;
@synthesize			isDynamic = _isDynamic;
@synthesize			isSynthesized = _isSynthesized;
@synthesize			synthesizedIvar = _synthesizedIvar;

- (id) init
{
	self = [super init];
		
	_isDynamic = YES;

	return self;
}

- (void) dealloc
{
	[_type release];

	[super dealloc];
}


- (void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeObject:_name forKey:@"name"];
	[coder encodeObject:_attributes forKey:@"attributes"];
}

- (id)initWithCoder:(NSCoder *)coder
{
	NSString* theName = [coder decodeObjectForKey:@"name"];
	NSString* theAttributes = [coder decodeObjectForKey:@"attributes"];

	return [self initWithName:theName attributes:theAttributes];
}


- (NSMutableDictionary*) toPlist
{
	NSMutableDictionary* d = [NSMutableDictionary dictionary];
	
	[d setObject:_name forKey:@"name"];
	[d setObject:_attributes forKey:@"attributes"];

	return d;
}


- (id) initWithPlist:(NSMutableDictionary*) plist
{
	NSString* theName = [plist objectForKey:@"name"];
	NSString* theAttributes = [plist objectForKey:@"attributes"];

	return [self initWithName:theName attributes:theAttributes];
}



- (id) initWithName:(NSString*)aName attributes:(NSString*)theAttributes
{
	self = [self init];
	

	int idx = 0;
	int attrLength = [theAttributes length];
	//NSLog(@"Property name = %@ attributes[%d] = %@", aName, attrLength, _attributes);
	
	self.name = aName;
	self.attributes = theAttributes;
	
	while (idx < attrLength)
	{
		char attribute = [theAttributes characterAtIndex:idx];
		
		/* Get the rest of the attribute string, if there is any. */
		NSRange range= [_attributes rangeOfString:@","
										  options:NSLiteralSearch
										    range:NSMakeRange(idx + 1, attrLength - idx - 1)];

		/* Falls off the edge of the string on the last iteration */
		/* Setting location to the null terminator keeps everything below happy. */
		if (range.location == NSNotFound)
			range.location = attrLength;

		NSString* rest = [theAttributes substringWithRange:NSMakeRange(idx + 1, range.location - idx - 1)];
		
		//NSLog(@"  idx = %d attribute = %c rest = %@ range = {%d, %d}", 
		//	  idx, attribute, rest, range.location, range.length);
		
		switch (attribute) 
		{
			case 'T':
				self.type = [[[NutronRuntimeType alloc] initWithTypeEncoding:rest] autorelease];
				break;

			case 'R':
				_isReadOnly = YES;
				break;

			case 'C':
				_isCopied = YES;
				break;

			case '&':
				_isRetained = YES;
				break;

			case 'P':
				_isStrongRef = YES;
				break;

			case 'W':
				_isWeakRef = YES;
				break;

			case 'D':
				_isDynamic = YES;
				break;
			
			case '?':
				_isNonatomic = YES;
				break;
				
			case 'G':
				self.getter = rest;
				break;

			case 'S':
				self.setter = rest;
				break;
				
			case 'V':	/* synthesized */
				_isSynthesized = YES;
				_isDynamic = NO;			/* properties default to Dynamic */
				self.synthesizedIvar = rest;
				break;
				
			default:
				break;
		}
		
		idx = range.location + 1;
	}
	

	return self;
}

- (NSString*) objcDeclaration
{
	NSString* d;
	NSMutableString* a = [[[NSMutableString alloc] init] autorelease];
	NSMutableString* x = [[[NSMutableString alloc] init] autorelease];

	if (_isCopied)
		[a appendString:@"copy"];
	
	if (_isRetained)
		[a appendString:@"retain"];
	
	if (!_isCopied && !_isRetained)
		[a appendString:@"assign"];	// Default
	
	if (_isReadOnly)
		[a appendString:@", readonly"];
	else
		[a appendString:@", readwrite"];
	
	if (_isNonatomic)
		[a appendString:@", nonatomic"];
	
	if ([_getter length] > 0)
		[a appendFormat:@", getter=%@", _getter];
	
	if ([_setter length] > 0)
		[a appendFormat:@", setter=%@", _setter];
	
	if (_isStrongRef)
		[x appendString:@" __strong"];
	
	if (_isWeakRef)
		[x appendString:@" __weak"];

	d = [NSString stringWithFormat:@"@property(%@) %@ %@;", a, [_type objcEncoding], _name];
	
	return d;
}

- (NSString*) objcImplementation
{
	NSMutableString* d = [[[NSMutableString alloc] init] autorelease];
	
	if (_isSynthesized)
		[d appendString:@"@synthesize "];

	if (_isDynamic)
		[d appendString:@"@dynamic "];

	[d appendString:_name];
	
	if (_isSynthesized && ![_synthesizedIvar isEqualToString:_name])
	{
		[d appendFormat:@" = %@", _synthesizedIvar];
	}
	
	[d appendString:@";"];
		
	return d;
}

- (NSString*) description
{
	return [self objcDeclaration];
}

@end


///////////////////////////////////////////////////////////////
@implementation NutronRuntimeProtocol

@synthesize name = _name;

- (id)initWithName:(NSString*)theName
{
	self = [super init];
	self.name = theName;
	
	return self;
}

- (void) dealloc
{
	[super dealloc];
}

- (void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeObject:_name forKey:@"name"];
}

- (id)initWithCoder:(NSCoder *)coder
{
	self = [super init];

	self.name = [coder decodeObjectForKey:@"name"];

	return self;
}


- (NSMutableDictionary*) toPlist
{
	NSMutableDictionary* d = [NSMutableDictionary dictionary];
	
	[d setObject:_name forKey:@"name"];

	return d;
}

- (id) initWithPlist:(NSMutableDictionary*) plist
{
	NSString* theName = [plist objectForKey:@"name"];

	return [self initWithName:theName];
}


- (NSString*)description
{
	return _name;
}

@end


///////////////////////////////////////////////////////////////
@implementation NutronRuntimeClass

@synthesize name = _name;
@synthesize superclassName = _superclassName;
@synthesize superclass = _superclass;

@synthesize ivars = _ivars;
@synthesize properties = _properties;
@synthesize instanceMethods = _instanceMethods;
@synthesize classMethods = _classMethods;
@synthesize protocols = _protocols;

- (void) buildMethodTable:(NSMutableArray*)table 
			forMethodType:(NutronRuntimeMethodType)methodType 
				 fromList:(Method*)methodList 
				withCount:(int)methodCount
{
	int i;
	int j;
	
	for (i = 0; i < methodCount; i++)
	{
		NutronRuntimeMethod* method = [[[NutronRuntimeMethod alloc] init] autorelease];
		
		method.method = methodList[i];
		method.name = [NSString stringWithCString:sel_getName(method_getName(methodList[i])) encoding:NSUTF8StringEncoding];
		method.selector = method_getName(methodList[i]);
		method.methodType = methodType;
		
		char* szReturnType = method_copyReturnType(methodList[i]);
		method.returnType = [[[NutronRuntimeType alloc] initWithTypeEncoding:
							 [NSString stringWithCString:szReturnType encoding:NSUTF8StringEncoding]] autorelease];
		if (szReturnType)
			free(szReturnType);
		
		unsigned int argCount = method_getNumberOfArguments(methodList[i]);
		/* Arguments 0 and 1 are self and the selector number. Skip them. */
		for (j = 2; j < argCount; j++)
		{
			char* szArgType = method_copyArgumentType(methodList[i], j);
			NutronRuntimeType* argType = [[[NutronRuntimeType alloc] initWithTypeEncoding:
										  [NSString stringWithCString:szArgType encoding:NSUTF8StringEncoding]] autorelease];
			[method addArgument:argType];
			
			if (szArgType)
				free(szArgType);
		}
		
		[table addObject:method];
	}	
}


- (void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeObject:_name forKey:@"name"];
	[coder encodeObject:_superclassName forKey:@"superclassName"];
	[coder encodeObject:_superclass forKey:@"superclass"];
	[coder encodeObject:_ivars forKey:@"ivars"];
	[coder encodeObject:_properties forKey:@"properties"];
	[coder encodeObject:_instanceMethods forKey:@"instanceMethods"];
	[coder encodeObject:_classMethods forKey:@"classMethods"];
	[coder encodeObject:_protocols forKey:@"protocols"];
}

- (id)initWithCoder:(NSCoder *)coder
{
	self = [super init];

	self.name = [coder decodeObjectForKey:@"name"];
	self.superclassName = [coder decodeObjectForKey:@"superclassName"];
	self.superclass = [coder decodeObjectForKey:@"superclass"];
	self.ivars = [coder decodeObjectForKey:@"ivars"];
	self.properties = [coder decodeObjectForKey:@"properties"];
	self.instanceMethods = [coder decodeObjectForKey:@"instanceMethods"];
	self.classMethods = [coder decodeObjectForKey:@"classMethods"];
	self.protocols = [coder decodeObjectForKey:@"protocols"];

	return self;
}

- (void) dealloc
{
	/*
	[ivars removeAllObjects];
	[properties removeAllObjects];
	[instanceMethods removeAllObjects];
	[classMethods removeAllObjects];
	[protocols removeAllObjects];
	 */
	
	[_ivars release];
	[_properties release];
	[_instanceMethods release];
	[_classMethods release];
	[_protocols release];
	
	[super dealloc];
}


- (id) initWithName:(NSString*) aName
{
	int i;
	
	self = [super init];

	self.name = aName;

	const char* szClassName = [aName UTF8String];
	Class cls = objc_getClass(szClassName);

	Class supercls = class_getSuperclass(cls);
	_superclassName = [[NSString stringWithCString:class_getName(supercls) 
										 encoding:NSUTF8StringEncoding] retain];
	
	
	//////////////////////////////////////////////////////////////////////
	Ivar *ivarList = NULL;
	unsigned int ivarCount;

	_ivars = [[NSMutableArray alloc] init];
	ivarList = class_copyIvarList(cls, &ivarCount);
	for (i = 0; i < ivarCount; i++)
	{
		NSString* ivarName = [NSString stringWithCString:ivar_getName(ivarList[i])
												encoding:NSUTF8StringEncoding];
		NSString* ivarTypeEncoding = [NSString stringWithCString:ivar_getTypeEncoding(ivarList[i])
														encoding:NSUTF8StringEncoding];
		long ivarOffset = ivar_getOffset(ivarList[i]);

		NutronRuntimeIvar*	ivar = [[[NutronRuntimeIvar alloc] 
										initWithName:ivarName
										typeEncoding:ivarTypeEncoding
										offset:ivarOffset] autorelease];
		[_ivars addObject:ivar];
	}

	if (ivarList)
		free(ivarList);

	//////////////////////////////////////////////////////////////////////
	Method* instanceMethodList = NULL;
	unsigned int instanceMethodCount;

	_instanceMethods	= [[NSMutableArray alloc] init];
	instanceMethodList = class_copyMethodList(cls, &instanceMethodCount);
	
	[self buildMethodTable:_instanceMethods
			 forMethodType:NutronRuntimeMethodType_Instance
				  fromList:instanceMethodList
				 withCount:instanceMethodCount];

	if (instanceMethodList)
		free(instanceMethodList);

	//////////////////////////////////////////////////////////////////////
	Method* classMethodList = NULL;
	unsigned int classMethodCount;
	
	_classMethods = [[NSMutableArray alloc] init];
	classMethodList = class_copyMethodList(object_getClass(cls), &classMethodCount);
	
	[self buildMethodTable:_classMethods
			 forMethodType:NutronRuntimeMethodType_Class
				  fromList:classMethodList
				 withCount:classMethodCount];

	if (classMethodList)
		free(classMethodList);
	
	//////////////////////////////////////////////////////////////////////
	objc_property_t* propertyList = NULL;
	unsigned int propertyCount;
	
	_properties	= [[NSMutableArray alloc] init];
	propertyList = class_copyPropertyList(cls, &propertyCount);
	
	for (i = 0; i < propertyCount; i++)
	{
		NSString* propertyName = [NSString stringWithCString:property_getName(propertyList[i])
													encoding:NSUTF8StringEncoding];
		NSString* attributes = [NSString stringWithCString:property_getAttributes(propertyList[i])
												  encoding:NSUTF8StringEncoding];
		
		NutronRuntimeProperty* property = 
			[[[NutronRuntimeProperty alloc] initWithName:propertyName
										 attributes:attributes] autorelease];
		[_properties addObject:property];
	}
	
	if (propertyList)
		free(propertyList);

	//////////////////////////////////////////////////////////////////////
	Protocol** protocolList = NULL;
	unsigned int protocolCount;
	
	_protocols	= [[NSMutableArray alloc] init];
	protocolList = class_copyProtocolList(cls, &protocolCount);
	
	for (i = 0; i < protocolCount; i++)
	{
		NSString* protocolName = 
			[NSString stringWithCString:protocol_getName(protocolList[i])
							   encoding:NSUTF8StringEncoding];
		
		/*
		struct objc_method_description* protocolMethodList = NULL;
		unsigned int protocolMethodCount;
		
		protocolMethodList = 
			protocol_copyMethodDescriptionList(protocolList[i], 
											   YES,	// required
											   YES,	// instance
											   &protocolMethodCount);
		
		NSLog(@"protocol: %@ (%d)", protocolName, protocolMethodCount);
		
		for (j = 0; j < protocolMethodCount; j++)
		{
			NSLog(@"  Method[%d]: name = %s types = %s",
				j,
				protocolMethodList[j].name,
				  protocolMethodList[j].types);
		}
		
		if (protocolMethodList)
			free(protocolMethodList);
		*/
		
		NutronRuntimeProtocol* protocol = 
			[[[NutronRuntimeProtocol alloc] initWithName:protocolName] autorelease];

		[_protocols addObject:protocol];
	}
		
	if (protocolList)
		free(protocolList);
	
	//jsbjsb
//	[self dump];
	return self;
}

- (NSString*) objcDeclaration
{
	int i;
//	int j;

	NSMutableString* d = [[[NSMutableString alloc] init] autorelease];
	
	[d appendFormat:@"@interface %@", _name];
	
	if ([_superclassName length] > 0)
		[d appendFormat:@" : %@", _superclassName];

	if ([_protocols count] > 0)
	{
		[d appendString:@" <"];

		for (i = 0; i < [_protocols count]; i++)
		{
			if (i > 0)
				[d appendFormat:@","];
			
			[d appendFormat:@" %@", [[_protocols objectAtIndex:i] name]];
		}

		[d appendString:@" >"];
	}
	
	[d appendString:@"\n{\n"];

	for (i = 0; i < [_ivars count]; i++)
	{
		[d appendFormat:@"    %@\n", [[_ivars objectAtIndex:i] objcDeclaration]];
	}

	[d appendString:@"}\n\n"];
	
	for (i = 0; i < [_properties count]; i++)
	{
		[d appendFormat:@"%@\n", [[_properties objectAtIndex:i] objcDeclaration]];
	}
	
	[d appendString:@"\n"];
	
	for (i = 0; i < [_classMethods count]; i++)
	{
		[d appendFormat:@"%@\n", [[_classMethods objectAtIndex:i] objcDeclaration]];
	}

	[d appendString:@"\n"];
	
	for (i = 0; i < [_instanceMethods count]; i++)
	{
		[d appendFormat:@"%@\n", [[_instanceMethods objectAtIndex:i] objcDeclaration]];
	}

	[d appendString:@"\n"];
	
	[d appendString:@"\n@end"];

	return d;
}

- (NSString*) nuDeclaration
{
	int i;

	NSMutableString* d = [[[NSMutableString alloc] init] autorelease];
	
	[d appendFormat:@"(class %@", _name];
	
	if ([_superclassName length] > 0)
		[d appendFormat:@" is %@\n", _superclassName];

	[d appendFormat:@"  (ivar\n"];
	for (i = 0; i < [_ivars count]; i++)
	{
		[d appendFormat:@"    %@\n", [[_ivars objectAtIndex:i] nuDeclaration]];
	}

	[d appendString:@"  )\n\n"];
	
	for (i = 0; i < [_classMethods count]; i++)
	{
		[d appendFormat:@"  %@\n", [[_classMethods objectAtIndex:i] nuDeclaration]];
	}

	[d appendString:@"\n"];
	
	for (i = 0; i < [_instanceMethods count]; i++)
	{
		[d appendFormat:@"  %@\n", [[_instanceMethods objectAtIndex:i] nuImplementation]];
	}

	[d appendString:@"\n"];
	
	[d appendString:@")\n"];

	return d;
}


- (void) dump
{
	NSLog(@"NutronRuntimeClass:");
	NSLog(@"  Class:         %@", _name);
	NSLog(@"  Super class:   %@", _superclassName);

	NSLog(@"  %lu Ivars:", [_ivars count]);
	for (NutronRuntimeIvar* ivar in _ivars)
	{
		NSLog(@"    %@", [ivar description]);
	}
	
	NSLog(@"  %lu Class Methods:", [_classMethods count]);
	for (NutronRuntimeMethod* method in _classMethods)
	{
		NSLog(@"    %@", [method description]);
	}

	NSLog(@"  %lu Instance Methods:", [_instanceMethods count]);
	for (NutronRuntimeMethod* method in _instanceMethods)
	{
		NSLog(@"    %@", [method description]);
	}
	
	NSLog(@"  %lu Properties:", [_properties count]);
	for (NutronRuntimeProperty* property in _properties)
	{
		NSLog(@"    %@", [property objcDeclaration]);
		NSLog(@"      %@", [property objcImplementation]);
	}
	
	NSLog(@"  %lu Protocols:", [_protocols count]);
	for (NutronRuntimeProtocol* protocol in _protocols)
	{
		NSLog(@"    %@", [protocol description]);
	}
}


- (id)objectLookup:(NSMutableArray*)array withName:(NSString*)key
{
	int		i;
	
	for (i = 0; i < [array count]; i++)
	{
		if ([[[array objectAtIndex:i] name] isEqualToString:key])
			return [array objectAtIndex:i];
	}
	
	return nil;
}

- (NutronRuntimeIvar*)ivarLookup:(NSString*) key
{
	return [self objectLookup:_ivars withName:key];
}


- (NutronRuntimeProperty*)propertyLookup:(NSString*) key
{
	return [self objectLookup:_ivars withName:key];
}


- (NutronRuntimeMethod*)classMethodLookup:(NSString*) key
{
	return [self objectLookup:_classMethods withName:key];
}


- (NutronRuntimeMethod*)instanceMethodLookup:(NSString*) key
{
	return [self objectLookup:_instanceMethods withName:key];
}


- (NutronRuntimeProtocol*)protocolLookup:(NSString*) key
{
	return [self objectLookup:_protocols withName:key];
}


- (NSMutableDictionary*) toPlist
{
	NSMutableDictionary* d = [NSMutableDictionary dictionary];
	
	[d setObject:_name forKey:@"classname"];
	[d setObject:_superclassName forKey:@"superclassName"];
	[d setObject:[_ivars toPlist] forKey:@"ivars"];
	[d setObject:[_properties toPlist] forKey:@"properties"];
	[d setObject:[_classMethods toPlist] forKey:@"classMethods"];
	[d setObject:[_instanceMethods toPlist] forKey:@"instanceMethods"];
	[d setObject:[_protocols toPlist] forKey:@"protocols"];
	
	return d;
}

- (NSString*) toJSON
{
	return @"";
}

- (void) writeToPlist:(NSString*)filename
{
	[[self toPlist] writeToFile:filename atomically:YES];
}

- (void) writeToJSON:(NSString*)filename
{
//	[[self toJSON] writeToFile:filename atomically:YES];
}

@end



