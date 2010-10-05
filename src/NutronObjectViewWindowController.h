//
//  NutronObjectViewWindowController.h
//  Nutron
//
//  Created by Jeff Buck on 9/24/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Nutron.h"
#import "NutronObjectViewController.h"


@interface NutronObjectViewWindowController : NSWindowController <NSWindowDelegate>
{
	NutronObjectViewController*		_objectViewer;
}

@property (nonatomic, retain) NutronObjectViewController* objectViewer;

- (id)initWithRootObject:(id)object name:(NSString*)name;
- (void)refresh;
@end
