//
//  NutronWindowController.h
//  Nutron
//
//  Created by Jeff Buck on 10/6/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Nutron.h"
#import "NutronViewController.h"

@interface NutronWindowController : NSWindowController <NSWindowDelegate>
{
	NSMenuItem*				_nutronMenuItem;
	NutronViewController*	_viewController;
	BOOL					_isShowing;
}

- (id)initWithObject:(id)object andName:(NSString*)name;
- (id)initWithParser:(id)parser;

- (void)refresh;

@end
