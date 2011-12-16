//
//  NutronClassTextViewController.h
//  Nutron
//
//  Created by Jeff Buck on 10/2/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NutronClassTextViewController : NSObject <NSTextViewDelegate>
{
	NSTextView*			_textView;
	NSScrollView*		_scrollView;

	NSString*			_className;
	NSString*			_format;
}

@property (nonatomic, retain) NSTextView* textView;
@property (nonatomic, retain) NSScrollView* scrollView;

@property (nonatomic, copy) NSString* className;
@property (nonatomic, copy) NSString* format;

- (id)initWithFrame:(NSRect)frame;
- (void)setFonts;
- (void)exportToFile:(NSString*)filename;

@end
