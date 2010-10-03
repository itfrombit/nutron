//
//  Nutron.m
//  Nutron
//
//  Created by Jeff Buck on 9/22/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//

#import "Nutron.h"
#import "NutronConsoleWindowController.h"
#import "NutronObjectViewWindowController.h"
#import "NutronClassTextViewWindowController.h"
#import "NutronClassOutlineViewWindowController.h"

#import "NutronViewSelector.h"

@implementation Nutron

+ (NutronConsoleWindowController*)console
{
	return [[[NutronConsoleWindowController alloc] init] autorelease];
}

+ (NutronObjectViewWindowController*)inspect:(id)object
{
	return [[[NutronObjectViewWindowController alloc] initWithRootObject:object] autorelease];
}

+ (NutronClassTextViewWindowController*)viewClass:(NSString*)className
{
	NutronClassTextViewWindowController* c = 
	[[[NutronClassTextViewWindowController alloc] initWithClassName:className] autorelease];

	return c;
}

+ (NutronClassOutlineViewWindowController*)outlineClass:(NSString*)className
{
	NutronClassOutlineViewWindowController* c = 
	[[[NutronClassOutlineViewWindowController alloc] initWithClassName:className] autorelease];
	
	return c;
}

+ (id)selectView
{
	NutronViewSelector* vs = [[NutronViewSelector alloc] init];
	
	id result = [vs selectView];
	
	[vs release];
	
	return result;
}

@end
