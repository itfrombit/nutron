//
//  NutronClassOutlineViewController.m
//  Nutron
//
//  Created by Jeff Buck on 10/2/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//

#import <objc/runtime.h>
#import "Nutron.h"
#import "NutronRuntime.h"
#import "NutronCachedObject.h"
#import "NutronClassOutlineView.h"
#import "NutronClassOutlineViewController.h"


@implementation NutronClassOutlineViewController

@synthesize outlineView = _outlineView;
@synthesize scrollView = _scrollView;
@synthesize rootObject = _rootObject;
@synthesize className = _className;

- (id)initWithFrame:(NSRect)frame className:(NSString*)aClassName
{
	self = [super init];
	
	if (self)
	{
		NutronRuntimeClass* nrc = [[[NutronRuntimeClass alloc] initWithName:aClassName] autorelease];

		_rootObject = [[[NutronCachedRuntimeObject alloc] initWithObject:nrc
																  parent:nil
																	 key:@"object"
																   index:-1] retain];

		_outlineView = [[NutronClassOutlineView alloc] 
						initWithFrame:NSMakeRect(0,
												 0,
												 frame.size.width,
												 frame.size.height)];
		[_outlineView setAutoresizingMask:(NSViewHeightSizable | NSViewWidthSizable)];

		_scrollView = [[NSScrollView scrollViewWrappedAroundView:_outlineView withFrame:frame] retain];

		[_outlineView setDelegate:self];
		[_outlineView setDataSource:self];
		[_outlineView setUsesAlternatingRowBackgroundColors:YES];

		NSTableColumn* tc;

		tc = [[NSTableColumn alloc] initWithIdentifier:@"Type"];
		[[tc headerCell] setStringValue:@"Type"];
		[tc setWidth:200.0];
		[_outlineView addTableColumn:tc];
		[_outlineView setOutlineTableColumn:tc];
		[tc release];

		tc = [[NSTableColumn alloc] initWithIdentifier:@"Name"];
		[[tc headerCell] setStringValue:@"Name"];
		[tc setWidth:300.0];
		[_outlineView addTableColumn:tc];
		[tc release];

		[_outlineView reloadData];
		[_outlineView expandItem:_rootObject];
	}

	return self;
}

- (void)dealloc
{
	[_scrollView release];
	[_outlineView release];
	[_rootObject release];
	
	[super dealloc];
}



#pragma mark -
#pragma mark NSOutlineViewDataSource methods

- (BOOL)outlineView:(NSOutlineView*)ov isItemExpandable:(id)item
{
	NutronCachedObject* object = (NutronCachedObject*)item;

	if (object == nil)
	{
		return YES;
		//object = _rootObject;
	}

	NutronDebug(@"isItemExpandable %@", [object description]);
	return [object isExpandable];
}

- (NSInteger)outlineView:(NSOutlineView*)ov numberOfChildrenOfItem:(id)item
{
	NutronCachedObject* object = (NutronCachedObject*)item;

	if (object == nil)
	{
		return 1;
		//object = _rootObject;
	}
		
	NutronDebug(@"# of children: item %@", object);
	return [object numberOfChildren];
}

- (id)outlineView:(NSOutlineView *)ov child:(NSInteger)index ofItem:(id)item
{
	NutronCachedObject* object = (NutronCachedObject*)item;
	
	if (object == nil)
	{
		return _rootObject;
		//object = _rootObject;
	}

	NutronDebug(@"child:%d ofItem:%@", index, object);
	return [object childAtIndex:index];
}

- (id)outlineView:(NSOutlineView *)ov objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
	NutronDebug(@"objectValueForTableColumn:%@ byItem:%@", tableColumn, item);
	
	NutronCachedObject* object = (NutronCachedObject*)item;
	
	if (object == nil)
		object = _rootObject;
		
	NSString* columnIdentifier = [tableColumn identifier];
		
	if ([columnIdentifier compare:@"Name"] == NSOrderedSame)
	{
		return [object name];
	}
	else if ([columnIdentifier compare:@"Type"] == NSOrderedSame)
	{
		return [object type];
	}
	else
	{
		return [NSString stringWithFormat:@"Unknown Column: %@", columnIdentifier];
	}
}


#pragma mark -
#pragma mark NSOutlineViewDelegate methods

- (BOOL)outlineView:(NSOutlineView*)ov shouldSelectItem:(id)item
{
	// Disable selection of headers (ivars, global, etc.)
	return YES;
}

- (BOOL)outlineView:(NSOutlineView*)ov shouldEditTableColumn:(NSTableColumn*)tc item:(id)item
{
	return NO;
}


@end
