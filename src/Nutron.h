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

@interface Nutron : NSObject

+ (NutronConsoleWindowController*)console;
+ (NutronObjectViewWindowController*)inspect:(id)object;
+ (NutronClassTextViewWindowController*)viewClass:(NSString*)className;
+ (NutronClassOutlineViewWindowController*)outlineClass:(NSString*)className;

+ (id)selectView;

@end

