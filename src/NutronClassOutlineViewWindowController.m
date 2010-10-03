//
//  NutronClassOutlineViewWindowController.m
//  Nutron
//
//  Created by Jeff Buck on 10/2/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//

#import "NutronClassOutlineViewWindowController.h"


@implementation NutronClassOutlineViewWindowController

@synthesize classViewer = _classViewer;
@synthesize className = _className;

- (id)initWithClassName:(NSString *)aClassName
{
	self = [super initWithWindow:[[NSPanel alloc]
								  initWithContentRect:NSMakeRect(0, 0, 700, 400)
								  styleMask:NSTitledWindowMask
								  | NSClosableWindowMask
								  | NSResizableWindowMask
								  | NSUtilityWindowMask
								  backing:NSBackingStoreBuffered
								  defer:NO]];
	
	if (!self)
		return nil;
	
	_className = [aClassName copy];

	NSWindow* w = [self window];
	NSRect frame = [w frame];
	
	_classViewer = [[NutronClassOutlineViewController alloc]
					initWithFrame:frame className:_className];
	
	[w setContentView:[_classViewer scrollView]];
	
	[w center];
	[w setTitle:[NSString stringWithFormat:@"Nutron Class Viewer - %@", _className]];
	[w setDelegate:self];
	[w setOpaque:NO];
	[w setHidesOnDeactivate:YES];
	[w setFrameOrigin:NSMakePoint(frame.origin.x, 200)];
	[w setMinSize:NSMakeSize(600, 100)];
	[w makeKeyAndOrderFront:self];
	
	return self;
}

- (void)dealloc
{
	[[self window] setDelegate:nil];
	[_classViewer release];
	[_className release];
	
	[super dealloc];
}

@end
