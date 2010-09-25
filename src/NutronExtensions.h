//
//  NutronExtensions.h
//  Nutron
//
//  Created by Jeff Buck on 9/22/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSScrollView (NutronExtensions)

+ (NSScrollView*)scrollViewWrappedAroundView:(NSView*)view withFrame:(NSRect)frame;

@end


@interface NSTextStorage (NutronExtensions)

- (int)findOpeningParenForParenAt:(int)position backTo:(int)startOfInput;
- (int)findClosingParenForParenAt:(int)position;

@end
