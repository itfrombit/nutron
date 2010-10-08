//
//  NutronWindowController.m
//  Nutron
//
//  Created by Jeff Buck on 10/6/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//

#import "Nutron.h"
#import "NutronWindowController.h"

#import "NutronConsoleViewController.h"
#import "NutronObjectViewController.h"
#import "NutronClassOutlineViewController.h"


@implementation NutronWindowController

- (id)initWithObject:(id)object andName:(NSString*)name;
{
	self = [super initWithWindow:[[NSPanel alloc] 
								  initWithContentRect:NSMakeRect(0, 0, 1200, 600)
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

	_viewController = [[NutronViewController alloc] initWithFrame:frame object:object name:name];

	[w setContentView:[_viewController view]];

	[w center];
	[w setTitle:@"Nutron"];
	[w setDelegate:self];
	[w setOpaque:NO];
	[w setHidesOnDeactivate:YES];
	[w setFrameOrigin:NSMakePoint(frame.origin.x, 80)];
	[w setMinSize:NSMakeSize(600, 100)];
	[w makeKeyAndOrderFront:self];
	
	[_viewController postInitSetup];
	return self;
}

- (id)initWithParser:(id)parser
{
	[self initWithObject:[parser context] andName:@"parser context"];
	[_viewController setParser:parser];
	
	return self;
}

- (void)dealloc
{
	[_viewController release];
	[[self window] setDelegate:nil];
	
	[super dealloc];
}


#pragma mark NSWindowDelegate methods

- (void)windowDidResize:(NSNotification *)notification
{

}

@end
