//
//  NutronicAppDelegate.m
//  Nutronic
//
//  Created by Jeff Buck on 10/7/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//

#import "NutronicAppDelegate.h"
#import "Nutron/Nutron.h"
#import "Nutron/NutronViewController.h"

@implementation NutronicAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	NSRect frame = [_window frame];
	
	frame = [[_window contentView] frame];

	_nutronViewController = [[NutronViewController alloc]
							 initWithFrame:frame object:nil name:nil];
	[_nutronViewController postInitSetup];

	NSView* view = [_nutronViewController view];
	[_window setContentView:view];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
	return YES;
}

@end
