//
//  NORMarkdownStyle.m
//  NORMarkdownParser
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

#import "NORMarkdownStyle.h"

@interface NORMarkdownStyle ()
@property (nonatomic, strong) UIFont *emphasisFont;
@property (nonatomic, strong) UIFont *doubleEmphasisFont;
@property (nonatomic, strong) UIFont *codeFont;
@end

@implementation NORMarkdownStyle

- (instancetype)init {
    if ((self = [super init])) {
        self.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        self.textColor = [UIColor blackColor];
        self.highlightedTextColor = [UIColor blackColor];
        self.highlightedBackgroundColor = [UIColor yellowColor];
        self.linkTextColor = nil;
    }
    
    return self;
}

#pragma mark -
#pragma mark Accessors

- (void)setFont:(UIFont *)font {
    _font = font;
    
    // Create the variations needed
    UIFontDescriptor *descriptor;
    
    // Emphasis
    descriptor = [[self.font fontDescriptor] fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitItalic];
    self.emphasisFont = [UIFont fontWithDescriptor:descriptor size:0.f];
    
    // Double emphasis
    descriptor = [[self.font fontDescriptor] fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold];
    self.doubleEmphasisFont = [UIFont fontWithDescriptor:descriptor size:0.f];
    
    // Code
    descriptor = [[self.font fontDescriptor] fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitMonoSpace];
    self.codeFont = [UIFont fontWithDescriptor:descriptor size:0.f];
}

#pragma mark -
#pragma mark NORMarkdownParserStyle

- (NSAttributedString *)baseAttributedStringWithString:(NSString *)string {
    return [[NSAttributedString alloc] initWithString:string attributes:@{NSFontAttributeName : self.font, NSForegroundColorAttributeName : self.textColor}];
}

- (void)addEmphasisToRange:(NSRange)range inAttributedString:(NSMutableAttributedString *)string {
    [string enumerateAttribute:NSFontAttributeName inRange:range options:0 usingBlock:^(id value, NSRange valueRange, BOOL *stop) {
        // Check if there is a pre-set font in the attrs, if so, then adjust that one
        if (value) {
            UIFont *font = value;
            UIFontDescriptor *descriptor = [font fontDescriptor];
            descriptor = [descriptor fontDescriptorWithSymbolicTraits:descriptor.symbolicTraits | UIFontDescriptorTraitItalic];
            font = [UIFont fontWithDescriptor:descriptor size:0.f];
            [string addAttribute:NSFontAttributeName value:font range:valueRange];
        } else {
            [string addAttribute:NSFontAttributeName value:self.emphasisFont range:valueRange];
        }
    }];
}

- (void)addDoubleEmphasisToRange:(NSRange)range inAttributedString:(NSMutableAttributedString *)string {
    [string enumerateAttribute:NSFontAttributeName inRange:range options:0 usingBlock:^(id value, NSRange valueRange, BOOL *stop) {
        // Check if there is a pre-set font in the attrs, if so, then adjust that one
        if (value) {
            UIFont *font = value;
            UIFontDescriptor *descriptor = [font fontDescriptor];
            descriptor = [descriptor fontDescriptorWithSymbolicTraits:descriptor.symbolicTraits | UIFontDescriptorTraitBold];
            font = [UIFont fontWithDescriptor:descriptor size:0.f];
            [string addAttribute:NSFontAttributeName value:font range:valueRange];
        } else {
            [string addAttribute:NSFontAttributeName value:self.emphasisFont range:valueRange];
        }
    }];
}

- (void)addTripleEmphasisToRange:(NSRange)range inAttributedString:(NSMutableAttributedString *)string {
    [string enumerateAttributesInRange:range options:0 usingBlock:^(NSDictionary *attrs, NSRange valueRange, BOOL *stop) {
        // Check if there is a pre-set font in the attrs, if so, then adjust that one
        if (attrs[NSFontAttributeName]) {
            UIFont *font = attrs[NSFontAttributeName];
            UIFontDescriptor *descriptor = [font fontDescriptor];
            descriptor = [descriptor fontDescriptorWithSymbolicTraits:descriptor.symbolicTraits | UIFontDescriptorTraitBold];
            font = [UIFont fontWithDescriptor:descriptor size:0.f];
            [string addAttribute:NSFontAttributeName value:font range:valueRange];
        } else {
            [string addAttribute:NSFontAttributeName value:self.doubleEmphasisFont range:valueRange];
        }
    }];
}

- (void)addCodeWithLanguage:(NSString *)lang toRange:(NSRange)range inAttributedString:(NSMutableAttributedString *)string {
    [string enumerateAttributesInRange:range options:0 usingBlock:^(NSDictionary *attrs, NSRange valueRange, BOOL *stop) {
        // Check if there is a pre-set font in the attrs, if so, then adjust that one
        if (attrs[NSFontAttributeName]) {
            UIFont *font = attrs[NSFontAttributeName];
            UIFontDescriptor *descriptor = [font fontDescriptor];
            descriptor = [descriptor fontDescriptorWithSymbolicTraits:descriptor.symbolicTraits | UIFontDescriptorTraitMonoSpace];
            font = [UIFont fontWithDescriptor:descriptor size:0.f];
            [string addAttribute:NSFontAttributeName value:font range:valueRange];
        } else {
            [string addAttribute:NSFontAttributeName value:self.codeFont range:valueRange];
        }
    }];
}

- (void)addLinkWithURL:(NSURL *)url title:(NSString *)title toRange:(NSRange)range inAttributedString:(NSMutableAttributedString *)string {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:@{NSLinkAttributeName : url}];
    if (self.linkTextColor)
        dictionary[NSForegroundColorAttributeName] = self.linkTextColor;
    
    [string addAttributes:dictionary range:range];
}

- (void)addStrikethroughToRange:(NSRange)range inAttributedString:(NSMutableAttributedString *)string {
    [string addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlineStyleSingle) range:range];
}

- (void)addUnderlineToRange:(NSRange)range inAttributedString:(NSMutableAttributedString *)string {
    [string addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:range];
}

- (void)addHighlightToRange:(NSRange)range inAttributedString:(NSMutableAttributedString *)string {
    if (self.highlightedTextColor)
        [string addAttribute:NSForegroundColorAttributeName value:self.highlightedTextColor range:range];
    
    if (self.highlightedBackgroundColor)
        [string addAttribute:NSBackgroundColorAttributeName value:self.highlightedBackgroundColor range:range];
}

@end
