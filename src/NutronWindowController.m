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

@interface NutronWindowController ()

- (void) addNutronMenu;

@end

@implementation NutronWindowController

- (id)initWithObject:(id)object andName:(NSString*)name;
{
	self = [super initWithWindow:[[NSPanel alloc] 
								  initWithContentRect:NSMakeRect(0, 0, 1000, 600)
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
	[self addNutronMenu];
	_isShowing = YES;

	// Add a magic $$nutron symbol.
	NuParser* parser = [[_viewController consoleViewer] parser];
	NuSymbolTable* symbolTable = [[parser context] objectForKey:SYMBOLS_KEY];
	[[symbolTable symbolWithString:@"$$nutron"] setValue:self];
	
	return self;
}


- (id)initWithParser:(id)parser
{
	[self initWithObject:[parser context] andName:@"parser context"];
	[_viewController setParser:parser];
	
	return self;
}


- (void)refresh
{
	[[_viewController objectViewer] refresh];
}


- (void)toggleNutronWindow:(id)sender
{
	if (_isShowing)
	{
		[_nutronMenuItem setTitle:@"Show Nutron Window"];
		[[self window] close];
		_isShowing = NO;
	}
	else
	{
		[_nutronMenuItem setTitle:@"Hide Nutron Window"];
		[[self window] makeKeyAndOrderFront:self];
		_isShowing = YES;
	}
}

- (void)addNutronMenu
{
	_nutronMenuItem = [[NSMenuItem alloc] initWithTitle:@"Toggle Nutron Window"
												 action:@selector(toggleNutronWindow:)
										  keyEquivalent:@"U"];
	[_nutronMenuItem setTarget:self];
	[_nutronMenuItem setTitle:@"Hide Nutron Window"];

	NSMenu* windowMenu = [NSApp windowsMenu];
	if (windowMenu)
	{
		[windowMenu insertItem:_nutronMenuItem atIndex:0];
	}

}

- (void)dealloc
{
	if (_nutronMenuItem)
	{
		NSMenu* windowMenu = [NSApp windowsMenu];
		if (windowMenu)
		{
			[windowMenu removeItem:_nutronMenuItem];
		}
		
		[_nutronMenuItem release];
	}
	
	[_viewController release];
	[[self window] setDelegate:nil];
	
	[super dealloc];
}


#pragma mark NSWindowDelegate methods

- (void)windowWillClose:(NSNotification *)notification
{
	[_nutronMenuItem setTitle:@"Show Nutron Window"];
	_isShowing = NO;
}

- (void)windowDidResize:(NSNotification *)notification
{

}

@end
