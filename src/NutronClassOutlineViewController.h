//
//  NutronClassOutlineViewController.h
//  Nutron
//
//  Created by Jeff Buck on 10/2/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NutronClassOutlineViewController : NSObject <NSOutlineViewDelegate,
														NSOutlineViewDataSource>
{
	NSOutlineView*			_outlineView;
	NSScrollView*			_scrollView;
	id						_rootObject;
	NSString*				_className;
}

@property (nonatomic, retain) NSOutlineView* outlineView;
@property (nonatomic, retain) NSScrollView* scrollView;
@property (nonatomic, retain) id rootObject;

@property (nonatomic, retain) NSString* className;

- (id)initWithFrame:(NSRect)frame className:(NSString*)aClassName;
- (void)refresh;
@end
