//
//  NutronViewSelector.h
//  Nutron
//
//  Created by Jeff Buck on 9/23/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NutronViewSelector : NSObject
{
	id				_selectedView;
}

@property (nonatomic, retain) id selectedView;

- (id)selectView;

@end
