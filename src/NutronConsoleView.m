//
//  NutronConsoleView.m
//  Nutron
//
//  Created by Jeff Buck on 9/22/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//

#import "NutronConsoleView.h"


@implementation NutronConsoleView

- (id)initWithFrame:(NSRect)frame
{
	self = [super initWithFrame:frame];
	
	if (self == nil)
		return nil;

	return self;
}


- (void)keyDown:(NSEvent *)event
{
	// Only do this if the Control key is down
	if (([event modifierFlags] & NSControlKeyMask) != 0)
	{
		id<NutronConsoleViewDelegate> cvd = (id<NutronConsoleViewDelegate>)[self delegate];
	
		switch ([event keyCode])
		{
			case 0:
				[cvd moveToStartOfInput];
				break;

			case 14:
				[cvd moveToEndOfInput];
				break;
		}
	}
	
	[super keyDown:event];
}

@end
