//
//  NutronConsoleView.h
//  Nutron
//
//  Created by Jeff Buck on 9/22/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol NutronConsoleViewDelegate <NSTextViewDelegate>

- (void)moveToStartOfInput;
- (void)moveToEndOfInput;

@end


@interface NutronConsoleView : NSTextView
{
}

@end
