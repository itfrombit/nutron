//
//  NutronWindowController.m
//  Nutron
//
//  Created by Jeff Buck on 9/22/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//

#import "Nutron.h"
#import "NutronConsoleViewController.h"
#import "NutronConsoleWindowController.h"


@implementation NutronConsoleWindowController

@synthesize console = _console;

- (id)init
{
	self = [super initWithWindow:[[NSPanel alloc] 
								  initWithContentRect:NSMakeRect(0, 0, 600, 200)
								  styleMask:NSTitledWindowMask
											| NSClosableWindowMask
											| NSMiniaturizableWindowMask
											| NSResizableWindowMask
											| NSUtilityWindowMask
								  backing:NSBackingStoreBuffered
								  defer:NO]];
	if (!self)
		return nil;

	NSWindow* w = [self window];
	NSRect frame = [w frame];

	_console = [[NutronConsoleViewController alloc] 
				initWithFrame:frame];

	[w setContentView:[_console scrollView]];

	[w center];
	[w setTitle:@"Nutron Console"];
	[w setDelegate:self];
	[w setOpaque:NO];
	[w setHidesOnDeactivate:YES];
	[w setFrameOrigin:NSMakePoint(frame.origin.x, 80)];
	[w setMinSize:NSMakeSize(600, 100)];
	[w makeKeyAndOrderFront:self];

	[_console setFonts];
	//[_console loadFile:@"~/.nu"];

	return self;
}

- (void)dealloc
{
	[[self window] setDelegate:nil];

	[_console release];
	[super dealloc];
}

- (void)windowDidResize:(NSNotification *)notification
{
	[_console moveToEndOfInput];
}


@end
