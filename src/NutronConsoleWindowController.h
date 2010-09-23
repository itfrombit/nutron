//
//  NutronWindowController.h
//  Nutron
//
//  Created by Jeff Buck on 9/22/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NutronConsoleViewController.h"

@interface NutronConsoleWindowController : NSWindowController <NSWindowDelegate>
{
	NutronConsoleViewController*	_console;
}

@property (nonatomic, retain) NutronConsoleViewController* console;

@end
