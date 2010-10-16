//
//  NutronObjectViewController.m
//  Nutron
//
//  Created by Jeff Buck on 9/24/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//

#import "objc/runtime.h"
#import "Nu/Nu.h"
#import "Nutron.h"
#import "NutronObjectView.h"
#import "NutronObjectViewController.h"
#import "NutronRuntime.h"


@implementation NutronObjectViewController

@synthesize outlineView = _outlineView;
@synthesize scrollView = _scrollView;
@synthesize delegate = _delegate;
@dynamic rootObject;

- (id)initWithFrame:(NSRect)frame rootObject:(id)object name:(NSString*)name
{
	self = [super init];

	if (self)
	{
		_rootObject = [[NutronCachedObject nutronCachedObjectForObject:object
															withParent:nil
																   key:name
																 index:-1] retain];
		
		_outlineView = [[NutronObjectView alloc] initWithFrame:NSMakeRect(0,
																		  0,
																		  frame.size.width,
																		  frame.size.height)];
		[_outlineView setAutoresizingMask:(NSViewHeightSizable | NSViewWidthSizable)];

		_scrollView = [[NSScrollView scrollViewWrappedAroundView:_outlineView withFrame:frame] retain];
		
		[_outlineView setDelegate:self];
		[_outlineView setDataSource:self];
		[_outlineView setUsesAlternatingRowBackgroundColors:YES];

		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(selectionDidChange:)
													 name:NSOutlineViewSelectionDidChangeNotification
												   object:_outlineView];

		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(outlineViewItemDidExpand:)
													 name:NSOutlineViewItemDidExpandNotification
												   object:_outlineView];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(outlineViewItemDidCollapse:)
													 name:NSOutlineViewItemDidCollapseNotification
												   object:_outlineView];

		NSTableColumn* tc;
		
		tc = [[NSTableColumn alloc] initWithIdentifier:@"Key"];
		[[tc headerCell] setStringValue:@"Key"];
		[tc setWidth:200.0];
		[_outlineView addTableColumn:tc];
		[_outlineView setOutlineTableColumn:tc];
		[tc release];
		
		tc = [[NSTableColumn alloc] initWithIdentifier:@"Type"];
		[[tc headerCell] setStringValue:@"Type"];
		[tc setWidth:200.0];
		[_outlineView addTableColumn:tc];
		[tc release];
		
		tc = [[NSTableColumn alloc] initWithIdentifier:@"Value"];
		[[tc headerCell] setStringValue:@"Value"];
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
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[_scrollView release];
	[_outlineView release];
	[_rootObject release];

	[super dealloc];
}

- (void)refreshNoExpand
{
	id object = [_rootObject object];
	id key = [_rootObject key];
	
	[_rootObject release];
	
	_rootObject = [[NutronCachedObject nutronCachedObjectForObject:object
														withParent:nil
															   key:key
															 index:-1] retain];
	
	[_outlineView reloadData];	
}

- (NutronCachedObject*)searchArray:(NSArray*)array forKey:(id)key
{
	int count = [array count];
	int i = 0;
	
	while (i < count)
	{
		NutronCachedObject* item = [array objectAtIndex:i];
		
		if ([[item key] isEqualTo:key])
			return item;
		++i;
	}
	
	return nil;
}

- (NutronCachedObject*)expandNode:(NutronCachedObject*)node
				withReferenceNode:(NutronCachedObject*)refNode
					 selectedItem:(NutronCachedObject*)selectedItem
{
	NutronCachedObject* itemToSelect = nil;
	
	if (refNode == selectedItem)
	{
		itemToSelect = node;
	}
	
	if (![refNode isExpanded])
	{
		return itemToSelect;
	}
	else
	{
		// Expand this node
		[_outlineView expandItem:node];
		
		NSArray* nodeChildren = [node children];

		// Expand each of the children
		for (NutronCachedObject* refChild in [refNode children])
		{
			// Find the matching child in the node
			NutronCachedObject* nodeChild = [self searchArray:nodeChildren forKey:[refChild key]];
			if (nodeChild)
			{
				if ([refChild isExpanded])
				{
					NutronCachedObject* returnItem = 
						[self expandNode:nodeChild withReferenceNode:refChild selectedItem:selectedItem];
					
					if (returnItem)
					{
							itemToSelect = returnItem;
					}
				}
				else if (refChild == selectedItem)
				{
						itemToSelect = nodeChild;
				}
			}
		}
	}

	return itemToSelect;
}


- (void)refresh
{
	NutronCachedObject* oldRoot = [_rootObject retain];
	NutronCachedObject* selectedItem = [_outlineView itemAtRow:[_outlineView selectedRow]];

	[self refreshNoExpand];
	
	// Restore the expansion state of the outline view
	NutronCachedObject* itemToSelect = [self expandNode:_rootObject 
									  withReferenceNode:oldRoot 
										   selectedItem:selectedItem];

	if (itemToSelect)
	{
		[_outlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:[_outlineView rowForItem:itemToSelect]]
				  byExtendingSelection:NO];
	}

	[oldRoot release];
}

- (id)rootObject
{
	return _rootObject;
}

- (void)setRootObject:(id)newRoot withKey:(id)newKey
{
	if (newRoot == [_rootObject object])
		return;
	
	[_rootObject setObject:newRoot];
	[_rootObject setKey:newKey];
	
	[self refreshNoExpand];

	[_outlineView expandItem:_rootObject];
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
		//object = _rootObject;
		return 1;
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

	if ([columnIdentifier compare:@"Key"] == NSOrderedSame)
	{
		return [object name];
	}
	else if ([columnIdentifier compare:@"Type"] == NSOrderedSame)
	{
		return [object type];
	}
	else
	{
		id value = [object value];
			
		if ([value respondsToSelector:@selector(description)])
			return [value description];
		else if ([value respondsToSelector:@selector(stringValue)])
			return [value stringValue];
		else
			return @"Unknown CachedObject Value";
	}
}


#pragma mark -
#pragma mark NSOutlineViewDelegate methods

- (void)outlineViewItemDidExpand:(NSNotification *)notification
{
	NutronCachedObject* item = [[notification userInfo] valueForKey:@"NSObject"];
	[item setIsExpanded:YES];
}


- (void)outlineViewItemDidCollapse:(NSNotification *)notification
{
	NutronCachedObject* item = [[notification userInfo] valueForKey:@"NSObject"];
	[item setIsExpanded:NO];
}


- (void)selectionDidChange:(NSNotification*)notification
{
	NutronCachedObject* item = [_outlineView itemAtRow:[_outlineView selectedRow]];

	if (_delegate)
	{
		[_delegate itemSelectedWithKey:[item key] type:[item type] value:[item value]];
	}
}

- (BOOL)outlineView:(NSOutlineView*)ov shouldSelectItem:(id)item
{
	return YES;
}

- (BOOL)outlineView:(NSOutlineView*)ov shouldEditTableColumn:(NSTableColumn*)tc item:(id)item
{
	return NO;
}


@end
