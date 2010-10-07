//
//  NutronConsoleViewController.h
//  Nutron
//
//  Created by Jeff Buck on 9/22/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Nu/Nu.h"
#import "NutronConsoleView.h"

@protocol NutronConsoleViewControllerDelegate

- (void)commandProcessed:(NSString*)commandString withResult:(id)value;

@end

@interface NutronConsoleViewController : NSObject <NutronConsoleViewDelegate,
												   NSTextViewDelegate>
{
	NSTextView*								_textView;
	NSScrollView*							_scrollView;

	NuParser*								_parser;
	NSMutableArray*							_history;

	int										_startOfInput;
	int										_insertionPoint;

	int										_index;
	int										_count;
	int										_chunk;
	
	int										_promptCounter;
	id<NutronConsoleViewControllerDelegate>	_delegate;
}

@property (nonatomic, retain) NSTextView* textView;
@property (nonatomic, retain) NSScrollView* scrollView;
@property (nonatomic, retain) NuParser* parser;
@property (nonatomic, retain) NSMutableArray* history;

@property (nonatomic, assign) int startOfInput;
@property (nonatomic, assign) int insertionPoint;
@property (nonatomic, assign) int index;
@property (nonatomic, assign) int count;
@property (nonatomic, assign) int chunk;

@property (nonatomic, retain) id<NutronConsoleViewControllerDelegate> delegate;

- (void)setFonts;
- (id)loadFile:(NSString*)file;

@end
