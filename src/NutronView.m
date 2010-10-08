//
//  NutronView.m
//  Nutron
//
//  Created by Jeff Buck on 10/7/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//

#import "NutronView.h"


@implementation NutronView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
	
	[self setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
	[self setAutoresizesSubviews:YES];

    if (self == nil)
		return nil;

    return self;
}

@end
