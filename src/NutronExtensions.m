//
//  NutronExtensions.m
//  Nutron
//
//  Created by Jeff Buck on 9/22/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//

#import "Nutron.h"
#import "NutronExtensions.h"


@implementation NSScrollView (NutronExtensions)

+ (NSScrollView*)scrollViewWrappedAroundView:(NSView*)view withFrame:(NSRect)frame
{
	NSScrollView* sv = [[NSScrollView alloc] initWithFrame:frame];
	[sv setHasHorizontalScroller:YES];
	[sv setHasVerticalScroller:YES];
	//[sv setBorderType:NSBezelBorder];
	[sv setWantsLayer:YES];
	[sv setBorderType:NSNoBorder];
	[sv setAutoresizingMask:(NSViewHeightSizable | NSViewWidthSizable)];
	[sv setAutohidesScrollers:YES];
	[sv setDocumentView:view];

	return [sv autorelease];
}

+ (int)scrollerWidth
{
	// We'll use overlays in Lion
	SInt32 major = 0;
	(void)Gestalt(gestaltSystemVersionMajor, &major);

	SInt32 minor = 0;
	(void)Gestalt(gestaltSystemVersionMinor, &minor);

	if ((major == 10) && (minor >= 7))
		return 0;
	else
		return 17;
}
@end


@implementation NSTextStorage (NutronExtensions)

- (int)findOpeningParenForParenAt:(int)position backTo:(int)startOfInput
{
	int count = 0;
	int	index = position;
	BOOL found = NO;

	char c = 0;

	while ((index >= startOfInput) && !found)
	{
		c = [[self string] characterAtIndex:index];
		switch (c)
		{
			case Nutron_LPAREN:
				--count;
				break;

			case Nutron_RPAREN:
				++count;
				break;

			default:
				break;
		}

		if (count == 0)
		{
			found = YES;
		}
		else
		{
			--index;
		}
	}

	if (found)
		return index;
	else
		return -1;
}


- (int)findClosingParenForParenAt:(int)position
{
	int count = 0;
	int index = position;
	int maxIndex = [self length];
	BOOL found = NO;

	char c = 0;

	while ((index < maxIndex) && !found)
	{
		c = [[self string] characterAtIndex:index];

		switch (c)
		{
			case Nutron_LPAREN:
				--count;
				break;

			case Nutron_RPAREN:
				++count;
				break;

			default:
				break;
		}

		if (count == 0)
		{
			found = YES;
		}
		else
		{
			++index;
		}
	}

	if (found)
		return index;
	else
		return -1;
}

@end
