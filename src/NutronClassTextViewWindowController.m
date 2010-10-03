//
//  NutronClassTextViewWindowController.m
//  Nutron
//
//  Created by Jeff Buck on 10/2/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//

#import "NutronClassTextViewWindowController.h"


@implementation NutronClassTextViewWindowController

@synthesize textViewController = _textViewController;
@synthesize className = _className;

- (id)initWithClassName:(NSString*)aClassName
{
	self = [super initWithWindow:[[NSPanel alloc] 
								  initWithContentRect:NSMakeRect(0, 0, 600, 400)
								  styleMask:NSTitledWindowMask
								  | NSClosableWindowMask
								  | NSMiniaturizableWindowMask
								  | NSResizableWindowMask
								  | NSUtilityWindowMask
								  backing:NSBackingStoreBuffered
								  defer:NO]];
	if (!self)
		return nil;

	_className = [aClassName copy];

	NSWindow* w = [self window];
	NSRect frame = [w frame];

	_textViewController = [[NutronClassTextViewController alloc] 
						   initWithFrame:frame];

	[w setContentView:[_textViewController scrollView]];

	[w center];
	[w setTitle:@"Nutron Class Viewer"];
	[w setDelegate:self];
	[w setOpaque:NO];
	[w setHidesOnDeactivate:YES];
	[w setFrameOrigin:NSMakePoint(frame.origin.x, 500)];
	[w setMinSize:NSMakeSize(600, 100)];
	[w makeKeyAndOrderFront:self];
	
	[_textViewController setFonts];
	[_textViewController setClassName:_className];

	return self;
}

- (void)dealloc
{
	[[self window] setDelegate:nil];
	
	[_textViewController release];
	[super dealloc];
}


@end
