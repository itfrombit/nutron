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

#import "NutronViewSelector.h"

@implementation Nutron

+ (NutronConsoleWindowController*)console
{
	return [[[NutronConsoleWindowController alloc] init] autorelease];
}

+ (NutronObjectViewWindowController*)viewObject:(id)object
{
	return [[[NutronObjectViewWindowController alloc] initWithRootObject:object] autorelease];
}

+ (id)selectView
{
	NutronViewSelector* vs = [[NutronViewSelector alloc] init];
	
	id result = [vs selectView];
	
	[vs release];
	
	return result;
}

@end
