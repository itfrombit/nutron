//
//  NutronObjectViewWindowController.m
//  Nutron
//
//  Created by Jeff Buck on 9/24/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//

#import "NutronObjectViewWindowController.h"


@implementation NutronObjectViewWindowController

@synthesize objectViewer = _objectViewer;

- (id)initWithRootObject:(id)object name:(NSString*)name
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
	
	NSWindow* w = [self window];
	NSRect frame = [w frame];
	
	_objectViewer = [[NutronObjectViewController alloc]
					 initWithFrame:frame 
						rootObject:object
							  name:name];
	
	[w setContentView:[_objectViewer scrollView]];

	[w center];
	[w setTitle:@"Nutron Object Viewer"];
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
	[_objectViewer release];
	
	[super dealloc];
}

- (void)refresh
{
	[_objectViewer refresh];
}
@end
