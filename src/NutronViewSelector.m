//
//  NutronViewSelector.m
//  Nutron
//
//  Created by Jeff Buck on 9/23/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//

//  The selectView method is adapted from F-Script:
//  FSObjectBrowserView.m Copyright (c) 2001-2009 Philippe Mougin.
//  See the F-Script license in the F-Script.license.txt file in
//  the Nutron distribution.


#import "Nutron.h"
#import "NutronViewSelector.h"

#define ESCAPE '\033'


@implementation NutronViewSelector

@synthesize selectedView = _selectedView;

- (id)init
{
	self = [super init];

	return self;
}

- (void)dealloc
{
	[_selectedView release];

	[super dealloc];
}


- (void)menuWillSendAction:(NSNotification*)notification
{
	NSMenuItem* item = [[notification userInfo] objectForKey:@"MenuItem"];
	self.selectedView = item;
}

- (id)selectView
{
	self.selectedView = nil;

	NSEvent  *event;
	id        view;
	NSCursor *cursor = [NSCursor crosshairCursor];
	NSDate   *distantFuture = [NSDate distantFuture];

	NSRect infoRect = NSMakeRect(0, 0, 290, 100);
	NSTextView *infoView = [[[NSTextView alloc] initWithFrame:NSZeroRect] autorelease];
	[infoView setEditable:NO];
	[infoView setSelectable:NO];
	[infoView setDrawsBackground:NO];
	[infoView setTextColor:[NSColor whiteColor]];
	[infoView setFont:[NSFont controlContentFontOfSize:12]];
	[infoView setTextContainerInset:NSMakeSize(4, 4)];
	/*jsb*///[infoView setAutoresizingMask:NSViewHeightSizable|NSViewMinYMargin];
	[infoView setVerticallyResizable:NO];

	NSMutableParagraphStyle *paragraphStyle = [[[NSParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
	[paragraphStyle setLineBreakMode:NSLineBreakByTruncatingTail];
	[infoView setDefaultParagraphStyle:paragraphStyle];

	NSPanel *infoWindow = [[[NSPanel alloc] initWithContentRect:infoRect
													  styleMask:NSHUDWindowMask | NSUtilityWindowMask /*| NSTitledWindowMask*/
														backing:NSBackingStoreBuffered
														  defer:NO] autorelease];
	[infoWindow setLevel:NSFloatingWindowLevel];
	[infoWindow setContentView:infoView];

	NSWindow *focusWindow = [[NSWindow alloc] initWithContentRect:NSZeroRect
														styleMask:NSBorderlessWindowMask
														  backing:NSBackingStoreBuffered
															defer:NO] ;

	[focusWindow setBackgroundColor:[NSColor redColor]]; // selectedTextBackgroundColor
	[focusWindow setAlphaValue:0.3]; // 0.7
	[focusWindow setIgnoresMouseEvents:YES];

	[cursor push];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(menuWillSendAction:)
												 name:NSMenuWillSendActionNotification
											   object:nil];
	do
	{
		[cursor push];
		event = [NSApp nextEventMatchingMask:~0 untilDate:distantFuture inMode:NSEventTrackingRunLoopMode dequeue:YES];
		[cursor pop];
		if ([event type] == NSMouseMoved)
		{
			NSInteger  windowCount;
			NSInteger *windows;

			view = nil;

			NSCountWindows(&windowCount);
			windows = malloc(windowCount*sizeof(NSInteger));
			NSWindowList(windowCount, windows);

			for (unsigned i = 0; i < windowCount; i++)
			{
				NSWindow *window = [NSApp windowWithWindowNumber:windows[i]];
				if (   window
					&& window != focusWindow
					&& window != infoWindow)
				{
					view = [[[window contentView] superview]
							hitTest:[window convertScreenToBase:[NSEvent mouseLocation]]];

					if (view)
						break;
				}
			}

			free(windows);

			if (view)
			{
				NSRect rectInWindowCoordinates = [view convertRect:[view visibleRect] toView:nil];
				NSRect rectInScreenCoordinates;
				rectInScreenCoordinates.size = rectInWindowCoordinates.size;
				rectInScreenCoordinates.origin = [[view window] convertBaseToScreen:rectInWindowCoordinates.origin];

				if ([focusWindow parentWindow] != [view window])
				{
					[[focusWindow parentWindow] removeChildWindow:focusWindow];
					[[view window] addChildWindow:focusWindow ordered:NSWindowAbove];
				}
				[focusWindow setFrame:rectInScreenCoordinates display:YES];

				NSMutableString *infoString = [NSMutableString string];

				[infoString appendFormat:@"%@: %p\n\n", [view class], view];
				[infoString appendFormat:@"Bounds:\t\t%@\n", [NSValue valueWithRect:[view bounds]]];
				[infoString appendFormat:@"Frame:\t\t%@\n", [NSValue valueWithRect:[view frame]]];
				[infoString appendFormat:@"Superview:\t%@\n", [[view superview] class]];
				[infoString appendString:@"Subviews:\n"];
				for (NSView *subview in [view subviews])
				{
					[infoString appendFormat:@"\t\t%@\n", [subview class]];
				}

				[infoView setString:infoString];

				NSSize size = [[infoView textStorage] size];
				size.width  += 15;
				size.height += 10;

				NSPoint origin = NSMakePoint([NSEvent mouseLocation].x + 12,
											 [NSEvent mouseLocation].y - size.height - 9);
				[infoWindow setFrame:NSMakeRect(origin.x, origin.y, size.width, size.height)
							 display:YES
							 animate:NO];
				[infoWindow setTitle:[NSString stringWithFormat:@"%@: %p", [view class], view]];
				[infoWindow orderFront:nil];
			}
			else
			{
				[[focusWindow parentWindow] removeChildWindow:focusWindow];
				[focusWindow orderOut:nil];
				[infoWindow orderOut:nil];
			}
		}
	} while (   ([event type] != NSLeftMouseDown)
		     && (_selectedView == nil)
		     && !(   [event type] == NSKeyDown
				  && [[event characters] characterAtIndex:0] == ESCAPE));

	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:NSMenuWillSendActionNotification
												  object:nil];
	[cursor pop];
	[[focusWindow parentWindow] removeChildWindow:focusWindow];
	[focusWindow close];
	[infoWindow close];

	if ( !([event type] == NSKeyDown && [[event characters] characterAtIndex:0] == ESCAPE) )
	{
		if (_selectedView == nil)
			view = [[[[event window] contentView] superview] hitTest:[event locationInWindow]];
		else
			view = _selectedView;

		self.selectedView = view;

		//[[self window] performSelector:@selector(makeKeyAndOrderFront:) withObject:nil afterDelay:0];

		[NSApp activateIgnoringOtherApps:YES];
	}

	return _selectedView;
}

@end
