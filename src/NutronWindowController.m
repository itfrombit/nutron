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

/*
	_console = [[NutronConsoleViewController alloc] 
				initWithFrame:frame];

	[w setContentView:[_console scrollView]];
*/
	// Create the splitter windows, first the left/right
	_lrSplitView = [[NSSplitView alloc] initWithFrame:NSMakeRect(0, 0, 1200, 600)];
	[_lrSplitView setDelegate:self];
	[_lrSplitView setVertical:YES];

	_tbSplitView = [[NSSplitView alloc] initWithFrame:NSMakeRect(0, 0, 800, 600)];
	[_tbSplitView setDelegate:self];

	_consoleViewer = [[NutronConsoleViewController alloc] initWithFrame:NSMakeRect(0, 0, 800, 200)];
	[_consoleViewer setDelegate:self];
	
	if (object == nil)
	{
		// Use the parser's context as default
		_object = [[[_consoleViewer parser] context] retain];
		_objectName = @"context";
	}
	else
	{
		_object = [object retain];
		_objectName = [name copy];
	}
	
	_objectViewer = [[NutronObjectViewController alloc] initWithFrame:NSMakeRect(0, 0, 800, 400)
														   rootObject:_object name:_objectName];
	[_objectViewer setDelegate:self];

	_classViewer = [[NutronClassOutlineViewController alloc] initWithFrame:NSMakeRect(0, 0, 400, 600)
																 className:[_object className]];

	[_tbSplitView addSubview:[_objectViewer scrollView]];
	[_tbSplitView addSubview:[_consoleViewer scrollView]];
	
	[_lrSplitView addSubview:_tbSplitView];
	[_lrSplitView addSubview:[_classViewer scrollView]];

	[w setContentView:_lrSplitView];

	[w center];
	[w setTitle:@"Nutron"];
	[w setDelegate:self];
	[w setOpaque:NO];
	[w setHidesOnDeactivate:YES];
	[w setFrameOrigin:NSMakePoint(frame.origin.x, 80)];
	[w setMinSize:NSMakeSize(600, 100)];
	[w makeKeyAndOrderFront:self];
	
	[_consoleViewer setFonts];
	return self;
}

- (id)initWithParser:(id)parser
{
	[self initWithObject:[parser context] andName:@"parser context"];
	[_consoleViewer setParser:parser];
	
	return self;
}

- (void)dealloc
{
	[_object release];
	[_objectName release];

	[_classViewer release];
	[_objectViewer release];
	[_consoleViewer release];
	[_tbSplitView release];
	[_lrSplitView release];

	[[self window] setDelegate:nil];
	
	[super dealloc];
}


#pragma mark NSWindowDelegate methods

- (void)windowDidResize:(NSNotification *)notification
{

}


#pragma mark NutronConsoleViewControllerDelegate methods

- (void)commandProcessed:(NSString*)commandString withResult:(id)value
{
	// Refresh the object viewer
	//[_objectViewer setRootObject:[[_consoleViewer parser] context] withKey:@"(context)"];
	[_objectViewer refresh];
}


#pragma mark NutronObjectViewControllerDelegate methods

- (void)itemSelectedWithKey:(NSString*)key type:(NSString*)type value:(id)value
{
	[_classViewer setClassName:type];
	[_classViewer refresh];
}


#pragma mark NSSplitViewDelegate methods

static const float kNutronSplitViewMinLHSWidth = 100.0;

- (CGFloat)splitView:(NSSplitView *)sv 
constrainMinCoordinate:(CGFloat)coord
		 ofSubviewAt:(NSInteger)index
{
	return coord + kNutronSplitViewMinLHSWidth;
}


- (CGFloat)splitView:(NSSplitView *)sv 
constrainMaxCoordinate:(CGFloat)coord
		 ofSubviewAt:(NSInteger)index
{
	return coord - kNutronSplitViewMinLHSWidth;
}


- (BOOL)splitView:(NSSplitView *)splitView shouldAdjustSizeOfSubview:(NSView *)view
{
	if (splitView == _lrSplitView)
	{
		return view == [_classViewer scrollView];
	}
	else
	{
		return YES;
	}
}

/*
- (void)splitView:(NSSplitView*)sender resizeSubviewsWithOldSize:(NSSize)oldSize
{
	if (sender == _lrSplitView)
	{		
		// Lock the LHS width
		NSRect frame = [sender frame];
		NSView *lhs = [[sender subviews] objectAtIndex:0];
		NSRect lhsRect = [lhs frame];
		NSView *rhs = [[sender subviews] objectAtIndex:1];
		NSRect rhsRect = [rhs frame];
		
		CGFloat dividerThickness = [sender dividerThickness];
		
		lhsRect.size.height = frame.size.height;
		
		rhsRect.size.width = frame.size.width - lhsRect.size.width - dividerThickness;
		rhsRect.size.height = frame.size.height;
		rhsRect.origin.x = lhsRect.size.width + dividerThickness;
		
		[lhs setFrame:lhsRect];
		[rhs setFrame:rhsRect];
	}
}
*/


@end
