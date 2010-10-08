//
//  NutronicAppDelegate.h
//  Nutronic
//
//  Created by Jeff Buck on 10/7/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class NutronViewController;

@interface NutronicAppDelegate : NSObject <NSApplicationDelegate>
{
    IBOutlet NSWindow*		_window;
	NutronViewController*	_nutronViewController;
}

@end
