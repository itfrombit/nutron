//
//  NutronClassTextViewWindowController.h
//  Nutron
//
//  Created by Jeff Buck on 10/2/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NutronClassTextViewController.h"

@interface NutronClassTextViewWindowController : NSWindowController <NSWindowDelegate>
{
	NutronClassTextViewController*	_textViewController;
	NSString*						_className;
}

@property (nonatomic, retain) NutronClassTextViewController* textViewController;
@property (nonatomic, copy) NSString* className;

- (id)initWithClassName:(NSString*)className;

@end
