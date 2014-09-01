//
//  NORMarkdownParser.h
//  NORMarkdownParser Example
//
//  The MIT License (MIT)
//
//  Copyright (c) 2014 Henri Normak
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

@import Foundation;

typedef NS_ENUM(NSUInteger, NORMarkdownParserExtensions) {
    NORMarkdownAutolink = (1 << 3),                 // Automatically detect URLs and turn them into NSLinkAttributeName
    NORMarkdownStrikethrough = (1 << 4),            // Enable strikethrough, ~STRIKETHROUGH~
    NORMarkdownUnderline = (1 << 5),                // Enable underline, instead of single '_' emphasis
    NORMarkdownHighlight = (1 << 6),                // Enable highlighting, =HIGHLIGHTED=
    
    NORMarkdownFencedCode = (1 << 1),               // Add support for code blocks fenced with ``` (three backticks)
    NORMarkdownNoInterWordEmphasis = (1 << 10),     // Disable emphasis in middle of words, i.e ex**amp**le will not trigger
};

@protocol NORMarkdownParserStyle;
@interface NORMarkdownParser : NSObject

/**
 *  Object that dictates the styling of the resulting
 *  attributed string, defaults to NORMarkdownStyle object
 */
@property (nonatomic, strong) id <NORMarkdownParserStyle> style;

/**
 *  Initialise a new parser with given extensionds
 *  Designated initialiser
 *
 *  @param extensions Extensions to enable
 *
 *  @return Configured parser
 */
- (instancetype)initWithExtensions:(NORMarkdownParserExtensions)extensions;


/**
 *  Parse a markdown string into an NSAttributedString
 *
 *  @param markdown String containing the raw markdown
 *
 *  @return Parsed attributed string
 */
- (NSAttributedString *)attributedStringFromMarkdown:(NSString *)markdown;

/**
 *  Parse a markdown string into an NSAttributedString, with the option
 *  of also getting the raw string back
 *
 *  @param markdown Markdown string to parse
 *  @param stripped Upon return contains a reference to a stripped version of 'markdown'
 *
 *  @return Parsed attributed string
 */
- (NSAttributedString *)attributedStringFromMarkdown:(NSString *)markdown strippedString:(NSString **)stripped;

/**
 *  Get a string by stripping any Markdown syntax
 *  same as getting -stringValue from the attributed string, but
 *  faster
 *
 *  @param markdown Markdown string to strip
 *
 *  @return Stripped string
 */
- (NSString *)strippedStringFromMarkdown:(NSString *)markdown;

@end

@protocol NORMarkdownParserStyle <NSObject>
@required

/**
 *  @param string Raw string (markdown is stripped)
 *
 *  @return Attributed string for base string
 */
- (NSAttributedString *)baseAttributedStringWithString:(NSString *)string;

/**
 *  All following methods should work similarly by adding
 *  the requested attributes to a given subrange of the attributed string
 *  The string may more than one set of pre-existing attributes in that range
 *  (nested elements), which the style may choose to overwrite or modify
 *
 *  @param range  Subrange that should receive the requested style
 *  @param string Attributed string to be modified
 */

// Core methods
- (void)addEmphasisToRange:(NSRange)range inAttributedString:(NSMutableAttributedString *)string;
- (void)addDoubleEmphasisToRange:(NSRange)range inAttributedString:(NSMutableAttributedString *)string;
- (void)addTripleEmphasisToRange:(NSRange)range inAttributedString:(NSMutableAttributedString *)string;
// Lang can be nil
- (void)addCodeWithLanguage:(NSString *)lang toRange:(NSRange)range inAttributedString:(NSMutableAttributedString *)string;
// Title can be the same as url -absoluteString
- (void)addLinkWithURL:(NSURL *)url title:(NSString *)title toRange:(NSRange)range inAttributedString:(NSMutableAttributedString *)string;

@optional

// Extensions
- (void)addStrikethroughToRange:(NSRange)range inAttributedString:(NSMutableAttributedString *)string;
- (void)addUnderlineToRange:(NSRange)range inAttributedString:(NSMutableAttributedString *)string;
- (void)addHighlightToRange:(NSRange)range inAttributedString:(NSMutableAttributedString *)string;

@end
