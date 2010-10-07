//
//  NutronWindowController.h
//  Nutron
//
//  Created by Jeff Buck on 10/6/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NutronConsoleViewController.h"
#import "NutronObjectViewController.h"

@class NutronConsoleViewController;
@class NutronObjectViewController;
@class NutronClassOutlineViewController;

@interface NutronWindowController : NSWindowController <NSWindowDelegate,
														NSSplitViewDelegate,
														NutronConsoleViewControllerDelegate,
														NutronObjectViewControllerDelegate>
{
	id									_object;
	NSString*							_objectName;

	NSSplitView*						_lrSplitView;
	NSSplitView*						_tbSplitView;
	
	NutronConsoleViewController*		_consoleViewer;
	NutronObjectViewController*			_objectViewer;
	NutronClassOutlineViewController*	_classViewer;
}

- (id)initWithObject:(id)object andName:(NSString*)name;
- (id)initWithParser:(id)parser;

@end
