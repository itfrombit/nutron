//
//  NutronViewController.h
//  Nutron
//
//  Created by Jeff Buck on 10/7/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Nutron.h"
#import "NutronConsoleViewController.h"
#import "NutronObjectViewController.h"
#import "NutronClassOutlineViewController.h"
#import "NutronView.h"

@interface NutronViewController : NSObject <NSSplitViewDelegate,
											NutronConsoleViewControllerDelegate,
											NutronObjectViewControllerDelegate>
{
	id									_object;
	NSString*							_objectName;

	NutronView*							_view;

	NSSplitView*						_lrSplitView;
	NSSplitView*						_tbSplitView;

	NutronConsoleViewController*		_consoleViewer;
	NutronObjectViewController*			_objectViewer;
	NutronClassOutlineViewController*	_classViewer;
}

@property(nonatomic, retain) NutronView* view;
@property(nonatomic, retain) NutronConsoleViewController* consoleViewer;
@property(nonatomic, retain) NutronObjectViewController* objectViewer;
@property(nonatomic, retain) NutronClassOutlineViewController* classViewer;

- (id)initWithFrame:(NSRect)frame object:(id)object name:(NSString *)name;
- (void)postInitSetup;
- (void)setParser:(id)parser;

@end
