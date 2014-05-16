//
//  NutronConsoleViewController.m
//  Nutron
//
//  Created by Jeff Buck on 9/22/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//
//  Ported from Nu's console.nu
//

#import "Nu/Nu.h"
#import "Nutron.h"
#import "NutronConsoleViewController.h"
#import "NutronConsoleView.h"


@interface NutronConsoleViewController (Private)
- (void)prompt;
@end

@implementation NutronConsoleViewController

@synthesize textView = _textView;
@synthesize scrollView = _scrollView;

@synthesize parser = _parser;
@synthesize history = _history;

@synthesize startOfInput = _startOfInput;
@synthesize insertionPoint = _insertionPoint;
@synthesize index = _index;
@synthesize count = _count;
@synthesize chunk = _chunk;
@synthesize delegate = _delegate;

- (id)initWithFrame:(NSRect)frame
{
	self = [super init];

	if (self)
	{
		_textView = [[NutronConsoleView alloc] initWithFrame:NSMakeRect(0,
																		0,
																		frame.size.width - [NSScrollView scrollerWidth],
																		frame.size.height)];
		[_textView setAutoresizingMask:(NSViewHeightSizable | NSViewWidthSizable)];
		[_textView setBackgroundColor:[NSColor colorWithDeviceRed:0.8 green:0.8 blue:1.0 alpha:0.9]];
		[_textView setTextColor:[NSColor blackColor]];
		[_textView setInsertionPointColor:[NSColor blackColor]];
		[_textView setDelegate:self];

		_scrollView = [[NSScrollView scrollViewWrappedAroundView:_textView withFrame:frame] retain];

		_startOfInput = 0;
		_insertionPoint = 0;
		_count = 0;
		_chunk = 10;
		_index = -1;

		_history = [[NSMutableArray alloc] init];
		_parser = [[Nu parser] retain];

		_promptCounter = 0;

		// Add the magic $$console symbole. print and puts depend on it being there
		NuSymbolTable* symbolTable = [[_parser context] objectForKey:SYMBOLS_KEY];
		[[symbolTable symbolWithString:@"$$console"] setValue:self];

		[self prompt];
	}

	return self;
}

- (void)dealloc
{
	[_parser release];
	[_history release];
	[_textView release];
	[_scrollView release];

	[super dealloc];
}

- (void)setParser:(NuParser*)newParser
{
	if (newParser == _parser)
		return;

	[_parser release];

	_parser = [newParser retain];

	// Add the magic $$console symbole. print and puts depend on it being there
	NuSymbolTable* symbolTable = [[_parser context] objectForKey:SYMBOLS_KEY];
	[[symbolTable symbolWithString:@"$$console"] setValue:self];
}

- (id)loadFile:(id)file
{
	return [[_parser parse:[NSString stringWithContentsOfFile:[file stringByResolvingSymlinksInPath]
											  encoding:NSUTF8StringEncoding
												 error:nil]]
			evalWithContext:[_parser context]];
}



- (int)lengthOfTextView
{
	return [[[_textView textStorage] mutableString] length];
}


- (void)write:(NSString*)string
{
	[[_textView textStorage] replaceCharactersInRange:NSMakeRange(_insertionPoint, 0)
										   withString:string];
	int length = [string length];
	_insertionPoint += length;
	_startOfInput += length;

	[_textView scrollRangeToVisible:NSMakeRange([self lengthOfTextView], 0)];

	++_count;

	if ((_count % _chunk) == 0)
	{
		[[NSRunLoop currentRunLoop] runUntilDate:[NSDate date]];
	}

	[self moveToEndOfInput];
}


- (void)moveAndScrollToIndex:(int)index
{
	NSRange range = NSMakeRange(index, 0);
	[_textView scrollRangeToVisible:range];
	[_textView setSelectedRange:range];
}


- (NSString*)currentLine
{
	NSString* text = [[_textView textStorage] mutableString];
	return [text substringWithRange:NSMakeRange(_startOfInput, [text length] - _startOfInput)];
}


- (void)replaceLineWithPrevious
{
	if (_index > 0)
	{
		--_index;
		int textLength = [self lengthOfTextView];

		[[_textView textStorage] replaceCharactersInRange:
										NSMakeRange(_startOfInput,
													textLength - _startOfInput)
											   withString:[_history objectAtIndex:_index]];
		[_textView scrollRangeToVisible:NSMakeRange(textLength, 0)];
	}
}


- (void)replaceLineWithNext
{
	int historyCount = [_history count];
	if (_index == historyCount)
	{
		return;
	}

	int textLength = [self lengthOfTextView];

	NSString* replacement;

	if (_index == (historyCount - 1))
	{
		replacement = @"";
	}
	else
	{
		replacement = [_history objectAtIndex:_index + 1];
	}

	++_index;

	[[_textView textStorage] replaceCharactersInRange:NSMakeRange(_startOfInput,
																  textLength - _startOfInput)
										   withString:replacement];
	[_textView scrollRangeToVisible:NSMakeRange([self lengthOfTextView], 0)];
}


- (BOOL)textView:(NSTextView*)textView shouldChangeTextInRange:(NSRange)range replacementString:(NSString*)replacement
{
	NSLayoutManager* layoutManager = [_textView layoutManager];
	int textLength = [self lengthOfTextView];
	int replacementLength = [replacement length];
	NSTextStorage* textStorage = [_textView textStorage];

	[layoutManager removeTemporaryAttribute:@"NSColor" forCharacterRange:NSMakeRange(0, textLength)];
	[layoutManager removeTemporaryAttribute:@"NSBackgroundColor" forCharacterRange:NSMakeRange(0, textLength)];
	[layoutManager removeTemporaryAttribute:@"NSFont" forCharacterRange:NSMakeRange(0, textLength)];

	if (range.location < _startOfInput)
		return NO;

	if (   (replacementLength > 0)
		&& ([replacement characterAtIndex:(replacementLength - 1)] == Nutron_RPAREN))
	{
		// Add the paren to the view
		[textStorage replaceCharactersInRange:range withString:replacement];

		// Look back for the opening paren to highlight the pair
		int match = [textStorage findOpeningParenForParenAt:range.location
													 backTo:[_parser incomplete] ? 0 : _startOfInput];

		NSDictionary* highlight = [NSDictionary dictionaryWithObjectsAndKeys:
								   [NSColor colorWithDeviceRed:0.0 green:0.0 blue:0.0 alpha:1.0],
								   @"NSColor",
								   [NSColor colorWithDeviceRed:0.9 green:0.9 blue:0.0 alpha:1.0],
								   @"NSBackgroundColor",
								   nil];

		if ((match == -1) && ([_parser incomplete] == 0))
		{
			// Try inserting a paren at the start of the line
			[textStorage replaceCharactersInRange:NSMakeRange(_startOfInput, 0)
									   withString:@"("];
			[layoutManager setTemporaryAttributes:highlight
								forCharacterRange:NSMakeRange(_startOfInput, 1)];
			[layoutManager setTemporaryAttributes:highlight
								forCharacterRange:NSMakeRange(range.location + 1, 1)];
		}
		else
		{
			[layoutManager setTemporaryAttributes:highlight
								forCharacterRange:NSMakeRange(range.location, 1)];
			[layoutManager setTemporaryAttributes:highlight
								forCharacterRange:NSMakeRange(match, 1)];
		}

		return NO;
	}
	else if (   (replacementLength > 0)
			 && ([replacement characterAtIndex:(replacementLength - 1)] == Nutron_LPAREN))
	{
		// Add the paren to the view
		[textStorage replaceCharactersInRange:range withString:replacement];

		// Look for the closing paren to highlight the pair
		int match = [textStorage findClosingParenForParenAt:range.location];

		if (match != -1)
		{
			NSDictionary* highlight = [NSDictionary dictionaryWithObjectsAndKeys:
									   [NSColor colorWithDeviceRed:0.0 green:0.0 blue:0.0 alpha:1.0],
									   @"NSColor",
									   [NSColor colorWithDeviceRed:0.9 green:0.9 blue:0.0 alpha:1.0],
									   @"NSBackgroundColor",
									   nil];
			[layoutManager setTemporaryAttributes:highlight
								forCharacterRange:NSMakeRange(range.location, 1)];
			[layoutManager setTemporaryAttributes:highlight
								forCharacterRange:NSMakeRange(match, 1)];
		}

		return NO;
	}
	else if (   (replacementLength > 0)
			 && ([replacement characterAtIndex:(replacementLength - 1)] == 10))
	{
		[textStorage replaceCharactersInRange:NSMakeRange(textLength, 0) withString:replacement];
		[_textView setNeedsDisplay:YES];

		NSString* stringToEvaluate = [self currentLine];
		_startOfInput = [self lengthOfTextView];

		int stringToEvaluateLength = [stringToEvaluate length];

		if (stringToEvaluateLength > 1)
		{
			[_history addObject:[stringToEvaluate substringToIndex:(stringToEvaluateLength - 1)]];
			_index = [_history count];

			NSString* displayString;

			@try
			{
				id code = [_parser parse:stringToEvaluate];

				if (![_parser incomplete])
				{
					_insertionPoint = _startOfInput;
					id result = [_parser eval:code];
					[[[_parser symbolTable] symbolWithString:@"!!"] setValue:result];

					if ([result respondsToSelector:@selector(escapedStringRepresentation)])
					{
						displayString = [result escapedStringRepresentation];
					}
					else
					{
						displayString = [result stringValue];
					}

					[self write:displayString];
					[self write:@"\n"];

					if (_delegate)
					{
						[_delegate commandProcessed:[stringToEvaluate substringToIndex:(stringToEvaluateLength - 1)]
										 withResult:result];
					}
				}
			}
			@catch (NSException* e)
			{
				if ([e isKindOfClass:[NuException class]])
				{
					displayString = [((NuException*)e) dumpExcludingTopLevelCount:4];
				}
				else
				{
					if ([e respondsToSelector:@selector(dump)])
					{
						displayString = [e performSelector:@selector(dump)];
					}
				}

				[self write:displayString];
				[_parser reset];
				_insertionPoint = _startOfInput;
			}
		}
		else
		{
			_insertionPoint = _startOfInput;
		}

		[self prompt];
		return NO;	// we already inserted replacement
	}

	return YES;
}


- (NSRange)textView:(NSTextView*)tv willChangeSelectionFromCharacterRange:(NSRange)oldRange
															toCharacterRange:(NSRange)newRange
{
	if ((newRange.length == 0) && (newRange.location < _startOfInput))
	{
		return oldRange;
	}
	else
	{
		return newRange;
	}
}

- (BOOL)textView:(NSTextView*)tv doCommandBySelector:(SEL)selector
{
	if (selector == @selector(moveUp:))
	{
		[self replaceLineWithPrevious];
		return YES;
	}
	else if (selector == @selector(moveDown:))
	{
		[self replaceLineWithNext];
		return YES;
	}
	else
	{
		return NO;
	}
}

- (void)prompt
{
	int savedInsertionPoint = _insertionPoint;

	if ([_parser incomplete])
	{
		_insertionPoint = _startOfInput;
		[self write:@"- "];
	}
	else
	{
		[self write:[NSString stringWithFormat:@"%d > ", ++_promptCounter]];
	}

	_insertionPoint = savedInsertionPoint;
}


#pragma mark -
#pragma mark NSTextView delegate methods

- (void)setFonts
{
	[_textView setFont:[NSFont fontWithName:@"Monaco" size:14]];
}

#pragma mark -
#pragma mark NutronConsoleViewDelegate methods

- (void)moveToStartOfInput
{
	[self moveAndScrollToIndex:_startOfInput];
}

- (void)moveToEndOfInput
{
	[self moveAndScrollToIndex:[self lengthOfTextView]];
}


@end
