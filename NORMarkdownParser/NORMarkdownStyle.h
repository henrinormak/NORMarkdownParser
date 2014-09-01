//
//  NORMarkdownStyle.h
//  NORMarkdownParser
//
//  A simple expamle "renderer" for the parser, you can subclass for simpler
//  changes or create your own object that conforms to NORMarkdownParserStyle
//  protocol to supply the styles needed to the resulting attributed string
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

#import "NORMarkdownParser.h"

@interface NORMarkdownStyle : NSObject <NORMarkdownParserStyle>

/**
 *  Base font, uses variations for specific styles, such as emphasis or code
 */
@property (nonatomic, strong) UIFont *font;

/**
 *  Text color, highlighted color is used only if NORMarkdownHighlight
 *  is set and suitable element is encountered
 */
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIColor *highlightedTextColor;
@property (nonatomic, strong) UIColor *linkTextColor;   // set to nil if same as textColor should be used

/**
 *  Highlighted text can also have a background color
 */
@property (nonatomic, strong) UIColor *highlightedBackgroundColor;

@end
