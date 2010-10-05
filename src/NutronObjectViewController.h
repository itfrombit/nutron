//
//  NutronObjectViewController.h
//  Nutron
//
//  Created by Jeff Buck on 9/24/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NutronCachedObject.h"

@interface NutronObjectViewController : NSObject <NSOutlineViewDelegate,
												  NSOutlineViewDataSource>
{
	NSOutlineView*			_outlineView;
	NSScrollView*			_scrollView;

	id						_rootObject;
}

@property (nonatomic, retain) NSOutlineView* outlineView;
@property (nonatomic, retain) NSScrollView* scrollView;
@property (nonatomic, retain) id rootObject;

- (id)initWithFrame:(NSRect)frame rootObject:(id)object name:(NSString*)name;
- (void)refresh;

@end
