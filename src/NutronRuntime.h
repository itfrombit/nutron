//
//  NutronRuntime.h
//  Nutron
//
//  Created by Jeff Buck on 4/16/08.
//  Copyright 2008 Jeff Buck. All rights reserved.

#ifndef SYMBOLS_KEY
// Hack to get the unexposed Nu symbol table
#define SYMBOLS_KEY @"symbols"
#endif

///////////////////////////////////////////////////////////////
typedef enum tagNutronRuntimeMethodType
{
	NutronRuntimeMethodType_Class,
	NutronRuntimeMethodType_Instance
} NutronRuntimeMethodType;


///////////////////////////////////////////////////////////////
@interface NutronRuntimeType : NSObject <NSCoding>
{
	NSString*	_name;
	NSString*	_typeEncoding;
	NSString*	_objcEncoding;
	NSString*	_objcEncodingSuffix;
}

- (NSString*) mapTypeEncodingToObjcEncoding:(NSString*)encoding;
//- (NSString*) mapObjcEncodingToTypeEncoding:(NSString*)encoding withSuffix:(NSString*)suffix;

- (id) initWithTypeEncoding:(NSString*)encoding;
- (NSString*) className;

@property(copy) NSString* name;
@property(copy) NSString* typeEncoding;
@property(copy) NSString* objcEncoding;
@property(copy) NSString* objcEncodingSuffix;

// @property(retain) NSMutableDictionary* properties;

@end


///////////////////////////////////////////////////////////////
@interface NutronRuntimeIvar : NSObject <NSCoding>
{
	NSString*			_name;
	NSString*			_typeEncoding;
	int					_offset;
	NutronRuntimeType*	_runtimeType;

//	NSMutableDictionary*	properties;
}

@property(copy)		NSString*			name;
@property(copy)		NSString*			typeEncoding;
@property(retain)	NutronRuntimeType*	runtimeType;
@property(assign)	int					offset;

//@property(retain)	NSMutableDictionary*	properties;

- (NSString*) objcDeclaration;

@end



///////////////////////////////////////////////////////////////
@interface NutronRuntimeMethod : NSObject <NSCoding>
{
	NSString*				_name;
	SEL						_selector;
	NutronRuntimeType*		_returnType;
	NSMutableArray*			_args;
	NutronRuntimeMethodType	_methodType;
	Method					_method;
}

@property(copy)		NSString*					name;
@property(assign)	SEL							selector;
@property(retain)	NutronRuntimeType*			returnType;
@property(assign)	NutronRuntimeMethodType		methodType;
@property(retain)	NSMutableArray*				args;
@property(assign)	Method						method;

- (void) addArgument:(NutronRuntimeType*)anArg;

@end


///////////////////////////////////////////////////////////////
@interface NutronRuntimeProperty : NSObject <NSCoding>
{
	NSString*			_name;
	NSString*			_attributes;

	NSString*			_typeEncoding;
	NutronRuntimeType*	_runtimeType;

	NSString*			_getter;
	NSString*			_setter;

	BOOL				_isReadOnly;
	BOOL				_isCopied;
	BOOL				_isRetained;

	BOOL				_isNonatomic;

	BOOL				_isStrongRef;
	BOOL				_isWeakRef;

	BOOL				_isDynamic;
	BOOL				_isSynthesized;
	NSString*			_synthesizedIvar;
}

@property(copy)		NSString*		name;
@property(copy)		NSString*		attributes;
@property(retain)	NutronRuntimeType*	runtimeType;
@property(copy)		NSString*		getter;
@property(copy)		NSString*		setter;
@property(assign)	BOOL			isReadOnly;
@property(assign)	BOOL			isCopied;
@property(assign)	BOOL			isRetained;
@property(assign)	BOOL			isNonatomic;
@property(assign)	BOOL			isStrongRef;
@property(assign)	BOOL			isWeakRef;
@property(assign)	BOOL			isDynamic;
@property(assign)	BOOL			isSynthesized;
@property(copy)		NSString*		synthesizedIvar;

- (id) initWithName:(NSString*)aName attributes:(NSString*)attributes;
- (NSString*) objcDeclaration;
- (NSString*) objcImplementation;

@end


///////////////////////////////////////////////////////////////
@interface NutronRuntimeProtocol : NSObject <NSCoding>
{
	NSString*		_name;
}

@property(copy)		NSString* name;

@end


///////////////////////////////////////////////////////////////
@interface NutronRuntimeClass : NSObject <NSCoding>
{
	NSString*			_name;
	NSString*			_superclassName;
	NutronRuntimeClass*	_superclass;

	NSMutableArray*		_ivars;
	NSMutableArray*		_properties;
	NSMutableArray*		_classMethods;
	NSMutableArray*		_instanceMethods;
	NSMutableArray*		_protocols;
}

@property(copy) NSString* name;
@property(copy) NSString* superclassName;
@property(retain) NutronRuntimeClass* superclass;

@property(retain) NSMutableArray* ivars;
@property(retain) NSMutableArray* properties;
@property(retain) NSMutableArray* classMethods;
@property(retain) NSMutableArray* instanceMethods;
@property(retain) NSMutableArray* protocols;

- (id) initWithName:(NSString*) aName;

- (void) dump;

- (NutronRuntimeIvar*) ivarLookup:(NSString*) ivarName;
- (NutronRuntimeProperty*) propertyLookup:(NSString*) propertyName;
- (NutronRuntimeMethod*) classMethodLookup:(NSString*) methodName;
- (NutronRuntimeMethod*) instanceMethodLookup:(NSString*) methodName;
- (NutronRuntimeProtocol*) protocolLookup:(NSString*) protocolName;

- (NSString*) objcDeclaration;
- (NSString*) nuDeclaration;

- (void) writeToPlist:(NSString*)filename;
- (void) writeToJSON:(NSString*)filename;
@end



