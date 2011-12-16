//
//  NutronClassTextViewController.m
//  Nutron
//
//  Created by Jeff Buck on 10/2/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//

#import <objc/runtime.h>
#import "Nu/Nu.h"
#import "Nutron.h"
#import "NutronRuntime.h"

#import "NutronClassTextView.h"
#import "NutronClassTextViewController.h"


@implementation NutronClassTextViewController

@synthesize textView = _textView;
@synthesize scrollView = _scrollView;
@dynamic className;
@dynamic format;

- (id)initWithFrame:(NSRect)frame
{
	self = [super init];

	if (self)
	{
		_textView = [[NutronClassTextView alloc] initWithFrame:NSMakeRect(0,
																		  0,
																		  frame.size.width - [NSScrollView scrollerWidth],
																		  frame.size.height)];
		[_textView setAutoresizingMask:(NSViewHeightSizable | NSViewWidthSizable)];
		[_textView setBackgroundColor:[NSColor colorWithDeviceRed:0.9 green:0.8 blue:0.8 alpha:0.9]];
		[_textView setTextColor:[NSColor blackColor]];
		[_textView setInsertionPointColor:[NSColor blackColor]];
		[_textView setDelegate:self];

		_scrollView = [[NSScrollView scrollViewWrappedAroundView:_textView withFrame:frame] retain];
	}

	return self;
}


- (void)dealloc
{
	[_textView release];
	[_scrollView release];

	[super dealloc];
}


- (void)dumpClass
{
	if ((_className == nil) || [_className isEqualToString:@""])
		return;

	NutronRuntimeClass* nrc = [[[NutronRuntimeClass alloc] initWithName:_className] autorelease];

	NSString* dump = [nrc objcDeclaration];
	NSLog(@"dumpClass: %@\n%@", _className, dump);

	[_textView setString:dump];
//	[[_textView textStorage] replaceCharactersInRange:NSMakeRange(0, [[_textView string] length])
//										   withString:dump];
}


- (NSString*)className
{
	return _className;
}


- (void)setClassName:(NSString*)newClassName
{
	if (_className == newClassName)
		return;

	[_className release];
	_className = [newClassName copy];

	// Re-generate the classdump
	[self dumpClass];
	[_textView setNeedsDisplay:YES];
}


- (NSString*)format
{
	return _format;
}


- (void)setFormat:(NSString*)newFormat
{
	if (_format == newFormat)
		return;

	[_format release];
	_format = [newFormat copy];

	// Different format, regenerate the classdump
}


- (void)exportToFile:(NSString*)filename
{
}


- (int)lengthOfTextView
{
	return [[[_textView textStorage] mutableString] length];
}


#pragma mark -
#pragma mark NSTextView delegate methods

- (void)setFonts
{
	[_textView setFont:[NSFont fontWithName:@"Monaco" size:14]];
}


@end
