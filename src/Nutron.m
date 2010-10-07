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
#import "NutronWindowController.h"

#import "NutronViewSelector.h"

@implementation Nutron

+ (void)load
{
	static int initialized = 0;
	if (!initialized)
	{
		initialized = 1;
		[Nu loadNuFile:@"nutron" fromBundleWithIdentifier:@"nu.programming.nutron" withContext:nil];
	}
}


+ (NutronConsoleWindowController*)console
{
	return [[[NutronConsoleWindowController alloc] init] autorelease];
}

+ (NutronObjectViewWindowController*)inspect:(id)object withName:(NSString*)name
{
	return [[[NutronObjectViewWindowController alloc] initWithRootObject:object name:name] autorelease];
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

+ (NutronWindowController*)nutronWithObject:(id)object andName:(NSString*)name
{
	NutronWindowController* c = [[[NutronWindowController alloc] initWithObject:object andName:name] autorelease];
	return c;
}

+ (NutronWindowController*)nutron
{
	return [Nutron nutronWithObject:nil andName:nil];
}

+ (id)selectView
{
	NutronViewSelector* vs = [[NutronViewSelector alloc] init];
	
	id result = [vs selectView];
	
	[vs release];
	
	return result;
}

@end
