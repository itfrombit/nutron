/*
 *  Nutron.h
 *  Nutron
 *
 *  Created by Jeff Buck on 9/22/10.
 *  Copyright 2010 Jeff Buck. All rights reserved.
 *
 */

#define Nutron_LPAREN	'('
#define	Nutron_RPAREN	')'

#import "NutronExtensions.h"

#ifndef SYMBOLS_KEY
// Hack to get the unexposed Nu symbol table
#define SYMBOLS_KEY @"symbols"
#endif


//#define NUTRON_DEBUG	1

#ifdef NUTRON_DEBUG
#define NutronDebug(arg...) NSLog(arg)
#else
#define NutronDebug(arg...)
#endif

@class NutronConsoleWindowController;
@class NutronObjectViewWindowController;
@class NutronClassTextViewWindowController;
@class NutronClassOutlineViewWindowController;
@class NutronWindowController;

@interface Nutron : NSObject

+ (NutronConsoleWindowController*)console;
+ (NutronObjectViewWindowController*)inspect:(id)object withName:(NSString*)name;
+ (NutronClassTextViewWindowController*)viewClass:(NSString*)className;
+ (NutronClassOutlineViewWindowController*)outlineClass:(NSString*)className;
+ (NutronWindowController*)nutronWithObject:(id)object andName:(NSString*)name;
+ (NutronWindowController*)nutronWithParser:(id)parser;
+ (NutronWindowController*)nutron;
+ (id)selectView;

@end

