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

@class NutronConsoleWindowController;
@class NutronObjectViewWindowController;

@interface Nutron : NSObject

+ (NutronConsoleWindowController*)console;
+ (NutronObjectViewWindowController*)viewObject:(id)object;

+ (id)selectView;

@end

