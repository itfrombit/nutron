//
//  NutronViewController.m
//  Nutron
//
//  Created by Jeff Buck on 10/7/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//

#import "NutronViewController.h"
#import "NutronView.h"

const float kNutronSplitViewDividerThickness = 9.0;

@implementation NutronViewController

@synthesize view = _view;
@synthesize consoleViewer = _consoleViewer;
@synthesize objectViewer = _objectViewer;
@synthesize classViewer = _classViewer;

- (id)initWithFrame:(NSRect)frame object:(id)object name:(NSString*)name
{
	self = [super init];

	if (self == nil)
		return nil;

	_view = [[NutronView alloc] initWithFrame:frame];

	// Left/Right splitting: 60% to left
	// Top/Bottom splitting: 60% to top
	float lrSplitRatio = 0.6;
	float tbSplitRatio = 0.6;

	float leftWidth = frame.size.width * lrSplitRatio - kNutronSplitViewDividerThickness;
	float rightWidth = frame.size.width - leftWidth;
	float topHeight = frame.size.height * tbSplitRatio - kNutronSplitViewDividerThickness;
	float bottomHeight = frame.size.height - topHeight;

	// Create the splitter windows, first the left/right
	_lrSplitView = [[NSSplitView alloc]
					initWithFrame:NSMakeRect(0, 0, frame.size.width, frame.size.height)];
	[_lrSplitView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
	[_lrSplitView setAutoresizesSubviews:YES];

	[_lrSplitView setDelegate:self];
	[_lrSplitView setVertical:YES];

	_tbSplitView = [[NSSplitView alloc]
					initWithFrame:NSMakeRect(0, 0, leftWidth, frame.size.height)];
	[_tbSplitView setDelegate:self];

	_consoleViewer = [[NutronConsoleViewController alloc]
					  initWithFrame:NSMakeRect(0, 0, leftWidth, bottomHeight)];
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

	_objectViewer = [[NutronObjectViewController alloc]
					 initWithFrame:NSMakeRect(0, 0, leftWidth, topHeight)
						rootObject:_object
						      name:_objectName];
	[_objectViewer setDelegate:self];

	_classViewer = [[NutronClassOutlineViewController alloc]
					initWithFrame:NSMakeRect(0, 0, rightWidth, frame.size.height)
						className:[_object className]];

	[_tbSplitView addSubview:[_objectViewer scrollView]];
	[_tbSplitView addSubview:[_consoleViewer scrollView]];

	[_lrSplitView addSubview:_tbSplitView];
	[_lrSplitView addSubview:[_classViewer scrollView]];

	[_view addSubview:_lrSplitView];

	return self;
}

- (void)postInitSetup
{
	[_consoleViewer setFonts];
}

- (void)setParser:(id)parser
{
	[_consoleViewer setParser:parser];
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
	[_view release];

	[super dealloc];
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

@end
