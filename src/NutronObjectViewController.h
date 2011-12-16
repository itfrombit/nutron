//
//  NutronObjectViewController.h
//  Nutron
//
//  Created by Jeff Buck on 9/24/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NutronCachedObject.h"

@protocol NutronObjectViewControllerDelegate

- (void)itemSelectedWithKey:(NSString*)key type:(NSString*)type value:(id)value;

@end

@interface NutronObjectViewController : NSObject <NSOutlineViewDelegate,
												  NSOutlineViewDataSource>
{
	NSOutlineView*							_outlineView;
	NSScrollView*							_scrollView;

	id										_rootObject;

	id<NutronObjectViewControllerDelegate>	_delegate;
}

@property (nonatomic, retain) NSOutlineView* outlineView;
@property (nonatomic, retain) NSScrollView* scrollView;
@property (nonatomic, retain) id<NutronObjectViewControllerDelegate> delegate;
@property (nonatomic, retain, readonly) id rootObject;

- (id)initWithFrame:(NSRect)frame rootObject:(id)object name:(NSString*)name;
- (void)setRootObject:(id)newRoot withKey:(id)newKey;
- (void)refresh;

@end
