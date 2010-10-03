//
//  NutronClassOutlineViewWindowController.h
//  Nutron
//
//  Created by Jeff Buck on 10/2/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Nutron.h"
#import "NutronClassOutlineViewController.h"

@interface NutronClassOutlineViewWindowController : NSWindowController <NSWindowDelegate>
{
	NutronClassOutlineViewController*	_classViewer;
	NSString*							_className;
}

@property (nonatomic, retain) NutronClassOutlineViewController* classViewer;
@property (nonatomic, copy) NSString* className;

- (id)initWithClassName:(NSString*)className;

@end
