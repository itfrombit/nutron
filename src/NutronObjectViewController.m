//
//  NutronObjectViewController.m
//  Nutron
//
//  Created by Jeff Buck on 9/24/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//

#import "Nutron.h"
#import "NutronObjectView.h"
#import "NutronObjectViewController.h"

@implementation NutronObjectViewController

@synthesize outlineView = _outlineView;
@synthesize scrollView = _scrollView;
@synthesize rootObject = _rootObject;

- (id)initWithFrame:(NSRect)frame rootObject:(id)object
{
	self = [super init];

	if (self)
	{
		_outlineView = [[NutronObjectView alloc] initWithFrame:NSMakeRect(0,
																		  0,
																		  frame.size.width,
																		  frame.size.height)];
		[_outlineView setAutoresizingMask:(NSViewHeightSizable | NSViewWidthSizable)];

		_scrollView = [[NSScrollView scrollViewWrappedAroundView:_outlineView withFrame:frame] retain];
		
		[_outlineView setDelegate:self];
		[_outlineView setDataSource:self];
		
		NSTableColumn* tc;
		
		tc = [[NSTableColumn alloc] initWithIdentifier:@"Key"];
		[[tc headerCell] setStringValue:@"Key"];
		[_outlineView addTableColumn:tc];
		[_outlineView setOutlineTableColumn:tc];
		[tc release];
		
		tc = [[NSTableColumn alloc] initWithIdentifier:@"Type"];
		[[tc headerCell] setStringValue:@"Type"];
		[_outlineView addTableColumn:tc];
		[tc release];
		
		tc = [[NSTableColumn alloc] initWithIdentifier:@"Value"];
		[[tc headerCell] setStringValue:@"Value"];
		[_outlineView addTableColumn:tc];
		[tc release];
		
		_rootObject = [object retain];
		[_outlineView reloadData];
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
#pragma mark Helper functions for NSOutlineView methods

- (BOOL)isExpandableObject:(id)item
{
	if (   [item isKindOfClass:[NSDictionary class]]
		|| [item isKindOfClass:[NSArray class]])
	{
		return YES;
	}
	
	return NO;
}


#pragma mark -
#pragma mark NSOutlineViewDataSource methods

- (id)outlineView:(NSOutlineView *)ov child:(NSInteger)index ofItem:(id)item
{
	if (item == nil)
	{
		item = _rootObject;
	}

	if ([item isKindOfClass:[NSArray class]]) 
	{
		return [item objectAtIndex:index];
	}
	else if ([item isKindOfClass:[NSDictionary class]]) 
	{
		return [item objectForKey:[[item allKeys] objectAtIndex:index]];
	}

	return nil;
}

- (BOOL)outlineView:(NSOutlineView*)ov isItemExpandable:(id)item
{
	NSLog(@"isItemExpandable %@", [item description]);
	
	if ([self isExpandableObject:item])
	{
		NSLog(@"  it'a an expandable object");
		if ([item count] > 0)
		{
			NSLog(@"    with a count of %d", [item count]);
			return YES;
		}
	}
	
	return NO;
}

- (NSInteger)outlineView:(NSOutlineView*)ov numberOfChildrenOfItem:(id)item
{
	// Number of items in root dictionary
	if (item == nil)
	{
		NSLog(@"# of children: _rootObject: %d", [_rootObject count]);
		return [_rootObject count];
	}
	
	if ([self isExpandableObject:item])
	{
		NSLog(@"# of children: expandable item %@: %d", [item className], [item count]);
		return [item count];
	}
	
	// No children otherwise
	NSLog(@"# of children: nonexpandable item %@: %d", [item className], 0);
    return 0; 
}

- (id)outlineView:(NSOutlineView *)ov objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
	//if ([[tableColumn identifier] compare:@"Key"] == NSOrderedSame)
	if ([[[tableColumn headerCell] stringValue] compare:@"Key"] == NSOrderedSame)
	{
        // Return the key for this item. First, get the parent array or dictionary.
        // If the parent is nil, then that must be root, so we'll get the root
        // dictionary.

		id parent;

		if ([ov parentForItem:item])
		{
			parent = [ov parentForItem:item];
		}
		else
		{
			parent = _rootObject;
		}

		if ([parent isKindOfClass:[NSDictionary class]])
		{
            // Dictionaries have keys, so we can return the key name. We'll assume
            // here that keys/objects have a one to one relationship.
			return [[parent allKeysForObject:item] objectAtIndex:0];
		}
		else if ([parent isKindOfClass:[NSArray class]])
		{
            // Arrays don't have keys (usually), so we have to use a name
            // based on the index of the object.

			return [NSString stringWithFormat:@"Item %d", [parent indexOfObject:item]];
		}
	}
	else if ([[[tableColumn headerCell] stringValue] compare:@"Type"] == NSOrderedSame)
	{
		return [item className];
	}
	else
	{
        // Return the value for the key
		if ([item isKindOfClass:[NSString class]])
		{
			return item;
		}
		else if ([item isKindOfClass:[NSDictionary class]])
		{
			return [NSString stringWithFormat:@"%d items", [item count]];
		}
		else if ([item isKindOfClass:[NSArray class]])
		{
			return [NSString stringWithFormat:@"%d items", [item count]];
		}
		else if ([item respondsToSelector:@selector(description)])
		{
			return [item description];
		}
		else if ([item respondsToSelector:@selector(stringValue)])
		{
			return [item stringValue];
		}
	}

	return nil;
}


#pragma mark -
#pragma mark NSOutlineViewDelegate methods

- (BOOL)outlineView:(NSOutlineView*)ov shouldSelectItem:(id)item
{
	// Disable selection of headers (ivars, global, etc.)
	return YES;
}



@end
