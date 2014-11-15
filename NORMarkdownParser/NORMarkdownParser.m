//
//  NORMarkdownParser.m
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

#import "NORMarkdownParser.h"
#import "NORMarkdownStyle.h"
#include "document.h"
#include "html.h"

#pragma mark -
#pragma mark State

@interface NORMarkdownParserState : NSObject

@property (nonatomic, strong) NSMutableAttributedString *currentString;
@property (nonatomic, strong) NSMutableString *currentRawString;

@property (nonatomic, copy) NSArray *attributedStrings;

@property (nonatomic, strong) id <NORMarkdownParserStyle> style;

- (void)push;
- (NSAttributedString *)pop;

@end

@implementation NORMarkdownParserState

- (instancetype)init {
    if ((self = [super init])) {
        self.currentRawString = [NSMutableString string];
        self.currentString = [[NSMutableAttributedString alloc] init];
        self.attributedStrings = @[];
    }
    
    return self;
}

- (void)push {
    if (!self.currentString)
        return;
    
    self.attributedStrings = [self.attributedStrings arrayByAddingObject:self.currentString];
    
    self.currentString = [[NSMutableAttributedString alloc] init];
    self.currentRawString = [NSMutableString string];
}

- (NSAttributedString *)pop {
    NSAttributedString *string = [self.attributedStrings lastObject];
    
    if ([self.attributedStrings count] > 1)
        self.attributedStrings = [self.attributedStrings subarrayWithRange:NSMakeRange(0, [self.attributedStrings count] - 1)];
    else
        self.attributedStrings = @[];
    
    self.currentString = [string mutableCopy];
    self.currentRawString = [[string string] mutableCopy];
    
    return string;
}

@end

#pragma mark -
#pragma mark Hoedown callbacks

void parser_passthrough(hoedown_buffer *ob, const hoedown_buffer *text, void *opaque);
void parser_text(hoedown_buffer *ob, const hoedown_buffer *text, void *opaque);
void parser_codeblock(hoedown_buffer *ob, const hoedown_buffer *text, const hoedown_buffer *lang, void *opaque);

int parser_autolink(hoedown_buffer *ob, const hoedown_buffer *link, enum hoedown_autolink type, void *opaque);
int parser_code(hoedown_buffer *ob, const hoedown_buffer *text, void *opaque);
int parser_double_emphasis(hoedown_buffer *ob, const hoedown_buffer *text, void *opaque);
int parser_emphasis(hoedown_buffer *ob, const hoedown_buffer *text, void *opaque);
int parser_underline(hoedown_buffer *ob, const hoedown_buffer *text, void *opaque);
int parser_highlight(hoedown_buffer *ob, const hoedown_buffer *text, void *opaque);
int parser_quote(hoedown_buffer *ob, const hoedown_buffer *text, void *opaque);
int parser_image(hoedown_buffer *ob, const hoedown_buffer *link, const hoedown_buffer *title, const hoedown_buffer *alt, void *opaque);
int parser_linebreak(hoedown_buffer *ob, void *opaque);
int parser_link(hoedown_buffer *ob, const hoedown_buffer *link, const hoedown_buffer *title, const hoedown_buffer *content, void *opaque);
int parser_triple_emphasis(hoedown_buffer *ob, const hoedown_buffer *text, void *opaque);
int parser_strikethrough(hoedown_buffer *ob, const hoedown_buffer *text, void *opaque);

#pragma mark -
#pragma mark Parser

@interface NORMarkdownParser ()
@property (nonatomic, readonly) NORMarkdownParserExtensions extensions;
@end

@implementation NORMarkdownParser

#pragma mark -
#pragma mark Lifecycle

- (instancetype)init {
    return [self initWithExtensions:0];
}

- (instancetype)initWithExtensions:(NORMarkdownParserExtensions)extensions {
    if ((self = [super init])) {
        _extensions = extensions;
        self.style = [[NORMarkdownStyle alloc] init];
    }
    
    return self;
}

#pragma mark -
#pragma mark Parsing

- (hoedown_renderer)configuredRenderer {
    return (hoedown_renderer){
        /* state object */
        NULL, //void *opaque;
        
        /* block level callbacks - NULL skips the block */
        parser_codeblock, // Code block
        NULL, // Blockquote
        NULL, // HTML block
        NULL, // Header
        NULL, // HRule
        NULL, // List
        NULL, // List item
        parser_passthrough, // Paragraph
        NULL, // Table
        NULL, // Table row
        NULL, // Table cell
        NULL, // Footnotes
        NULL, // Footnote definition
        
        /* span level callbacks - NULL or return 0 prints the span verbatim */
        parser_autolink,
        parser_code,
        parser_double_emphasis,
        parser_emphasis,
        parser_underline,
        parser_highlight,
        parser_quote,
        parser_image,
        parser_linebreak,
        parser_link,
        NULL, // Raw HTML
        parser_triple_emphasis,
        parser_strikethrough,
        NULL, // Superscript
        NULL, // Footnote Ref
        
        /* low level callbacks - NULL copies input directly into the output */
        NULL, // Entity
        parser_text, // Text
        
        /* header and footer */
        NULL, // Doc header
        NULL, // Doc footer
    };
}

- (NSAttributedString *)attributedStringFromMarkdown:(NSString *)markdown {
    return [self attributedStringFromMarkdown:markdown strippedString:NULL];
}

- (NSAttributedString *)attributedStringFromMarkdown:(NSString *)markdown strippedString:(NSString **)stripped {
    if ([markdown length] == 0)
        return nil;
    
    // Create the state that will be passed along
    NORMarkdownParserState *state = [[NORMarkdownParserState alloc] init];
    state.style = self.style;

    // Create necessary buffers
    const char * bytes = [markdown UTF8String];
    hoedown_buffer *input;
    hoedown_buffer *output;
    NSUInteger length = [markdown lengthOfBytesUsingEncoding:NSUTF8StringEncoding] + 1;
    
    input = hoedown_buffer_new(length);
    hoedown_buffer_grow(input, length);
    memcpy(input->data, bytes, length);
    input->size = length;
    
    output = hoedown_buffer_new(64);
    
    // Create and render the document
    hoedown_document *document;
    hoedown_renderer renderer = [self configuredRenderer];
    
    renderer.opaque = (__bridge void *)state;
    document = hoedown_document_new(&renderer, self.extensions, 16);
    
    hoedown_document_render(document, output, input->data, input->size);
    hoedown_document_free(document);
    
    NSString *raw = [[NSString alloc] initWithBytes:output->data length:output->size - 1 encoding:NSUTF8StringEncoding];

    if (stripped) {
        *stripped = raw;
    }
    
    hoedown_buffer_free(input);
    hoedown_buffer_free(output);
    
    NSMutableAttributedString *result = [[NSMutableAttributedString alloc] init];
    NSAttributedString *newline = [self.style baseAttributedStringWithString:@"\n"];
    
    for (NSAttributedString *attributedString in state.attributedStrings) {
        [result appendAttributedString:attributedString];
        [result appendAttributedString:newline];
    }
    
    if ([[result string] hasSuffix:@"\n"]) {
        return [result attributedSubstringFromRange:NSMakeRange(0, [result length] - 1)];
    }
    
    return [result copy];
}

- (NSString *)strippedStringFromMarkdown:(NSString *)markdown {
    if ([markdown length] == 0)
        return nil;
    
    // Create necessary buffers
    const char * bytes = [markdown UTF8String];
    hoedown_buffer *input;
    hoedown_buffer *output;
    NSUInteger length = [markdown lengthOfBytesUsingEncoding:NSUTF8StringEncoding] + 1;
    
    input = hoedown_buffer_new(length);
    hoedown_buffer_grow(input, length);
    memcpy(input->data, bytes, length);
    input->size = length;
    
    output = hoedown_buffer_new(64);
    
    // Create and render the document
    hoedown_document *document;
    hoedown_renderer renderer = [self configuredRenderer];
    document = hoedown_document_new(&renderer, self.extensions, 16);
    
    hoedown_document_render(document, output, input->data, input->size);
    hoedown_document_free(document);
    
    // Output is the raw string
    NSString *raw = [[NSString alloc] initWithBytes:output->data length:output->size - 1 encoding:NSUTF8StringEncoding];
    
    hoedown_buffer_free(input);
    hoedown_buffer_free(output);
    
    return raw;
}

@end

#pragma mark -
#pragma mark Hoedown callbacks

void parser_passthrough(hoedown_buffer *ob, const hoedown_buffer *tb, void *opaque) {
    if (!tb || !tb->size)
        return;
    
    NORMarkdownParserState *state = (__bridge NORMarkdownParserState *)opaque;
    [state push];
    
    // Get rid of the null at the end of the string, so that our end result is not a faulty NSString (one which has nulls in it)
    if (ob->size) HOEDOWN_BUFPUTSL(ob, "\n");
    hoedown_buffer_put(ob, tb->data, tb->size);
}

void parser_text(hoedown_buffer *ob, const hoedown_buffer *tb, void *opaque) {
    if (!tb || !tb->size)
        return;
    
    NORMarkdownParserState *state = (__bridge NORMarkdownParserState *)opaque;
    
    if (state) {
        NSString *text = [[NSString alloc] initWithBytes:tb->data length:tb->size encoding:NSUTF8StringEncoding];
        [state.currentRawString appendString:text];
        [state.currentString appendAttributedString:[state.style baseAttributedStringWithString:text]];
    }
    
    hoedown_buffer_put(ob, tb->data, tb->size);
}

void parser_codeblock(hoedown_buffer *ob, const hoedown_buffer *tb, const hoedown_buffer *lb, void *opaque) {
    if (!tb || !tb->size)
        return;
    
    NORMarkdownParserState *state = (__bridge NORMarkdownParserState *)opaque;
    
    if (state) {
        NSString *text = [[NSString alloc] initWithBytes:tb->data length:tb->size encoding:NSUTF8StringEncoding];
        NSString *lang;
        if (lb && lb->size)
            lang = [[NSString alloc] initWithBytes:lb->data length:lb->size encoding:NSUTF8StringEncoding];
        
        NSRange range = [state.currentRawString rangeOfString:text options:NSBackwardsSearch | NSAnchoredSearch];
        if (range.location != NSNotFound)
            [state.style addCodeWithLanguage:lang toRange:range inAttributedString:state.currentString];
    }
    
    hoedown_buffer_put(ob, tb->data, tb->size);
}

int parser_autolink(hoedown_buffer *ob, const hoedown_buffer *lb, enum hoedown_autolink type, void *opaque) {
    if (!lb || !lb->size)
        return 0;
    
    NORMarkdownParserState *state = (__bridge NORMarkdownParserState *)opaque;
    
    if (state) {
        NSString *link = [[NSString alloc] initWithBytes:lb->data length:lb->size encoding:NSUTF8StringEncoding];
        NSURL *url = [NSURL URLWithString:link];
        NSUInteger length = [state.currentRawString length];
                
        // Move the current state back to the last white space (if the last character is not already whitespace)
        NSUInteger idx = [state.currentRawString rangeOfCharacterFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] options:NSBackwardsSearch].location;
        if (idx == NSNotFound) {
            idx = 0;
        } else {
            idx++;
        }
        
        if (idx != length - 1) {
            state.currentRawString = [[state.currentRawString substringToIndex:idx] mutableCopy];
            state.currentString = [[state.currentString attributedSubstringFromRange:NSMakeRange(0, idx)] mutableCopy];
            length = [state.currentRawString length];
        }
        
        // Add the link to the strings
        [state.currentRawString appendString:link];
        [state.currentString appendAttributedString:[state.style baseAttributedStringWithString:link]];
        
        // Only pass in the URL adding if there is a URL to be added
        // (a precaution against potential links that hoedown detects, but NSURL can't resolve)
        if (url) {
            [state.style addLinkWithURL:url title:link toRange:NSMakeRange(length, [link length]) inAttributedString:state.currentString];
        }
    }
    
    hoedown_buffer_put(ob, lb->data, lb->size);
    return 1;
}

int parser_link(hoedown_buffer *ob, const hoedown_buffer *link, const hoedown_buffer *title, const hoedown_buffer *content, void *opaque) {
    if (!link || !link->size)
        return 0;
    
    NORMarkdownParserState *state = (__bridge NORMarkdownParserState *)opaque;
    
    if (state) {
        NSString *contentString, *titleString, *linkString;
        NSURL *url;
        contentString = [[NSString alloc] initWithBytes:content->data length:content->size encoding:NSUTF8StringEncoding];
        
        if (title && title->size)
            titleString = [[NSString alloc] initWithBytes:title->data length:title->size encoding:NSUTF8StringEncoding];
        
        if (link && link->size) {
            linkString = [[NSString alloc] initWithBytes:link->data length:link->size encoding:NSUTF8StringEncoding];
            url = [NSURL URLWithString:linkString];
        }
        
        NSRange range = [state.currentRawString rangeOfString:contentString options:NSBackwardsSearch | NSAnchoredSearch];
        if (range.location != NSNotFound)
            [state.style addLinkWithURL:url title:titleString toRange:range inAttributedString:state.currentString];
    }
    
    hoedown_buffer_put(ob, content->data, content->size);
    return 1;
}

int parser_code(hoedown_buffer *ob, const hoedown_buffer *tb, void *opaque) {
    if (!tb || !tb->size)
        return 0;
    
    NORMarkdownParserState *state = (__bridge NORMarkdownParserState *)opaque;
    
    if (state) {
        NSString *text = [[NSString alloc] initWithBytes:tb->data length:tb->size encoding:NSUTF8StringEncoding];
        NSUInteger length = [state.currentRawString length];
        
        [state.currentRawString appendString:text];
        [state.currentString appendAttributedString:[state.style baseAttributedStringWithString:text]];
        [state.style addCodeWithLanguage:nil toRange:NSMakeRange(length, [text length]) inAttributedString:state.currentString];
    }
    
    hoedown_buffer_put(ob, tb->data, tb->size);
    return 1;
}

int parser_triple_emphasis(hoedown_buffer *ob, const hoedown_buffer *tb, void *opaque) {
    if (!tb || !tb->size)
        return 0;
    
    NORMarkdownParserState *state = (__bridge NORMarkdownParserState *)opaque;
    
    if (state) {
        NSString *text = [[NSString alloc] initWithBytes:tb->data length:tb->size encoding:NSUTF8StringEncoding];
        NSRange range = [state.currentRawString rangeOfString:text options:NSBackwardsSearch | NSAnchoredSearch];
        if (range.location != NSNotFound)
            [state.style addTripleEmphasisToRange:range inAttributedString:state.currentString];
    }
    
    hoedown_buffer_put(ob, tb->data, tb->size);
    return 1;
}

int parser_double_emphasis(hoedown_buffer *ob, const hoedown_buffer *tb, void *opaque) {
    if (!tb || !tb->size)
        return 0;
    
    NORMarkdownParserState *state = (__bridge NORMarkdownParserState *)opaque;
    
    if (state) {
        NSString *text = [[NSString alloc] initWithBytes:tb->data length:tb->size encoding:NSUTF8StringEncoding];
        NSRange range = [state.currentRawString rangeOfString:text options:NSBackwardsSearch | NSAnchoredSearch];
        if (range.location != NSNotFound)
            [state.style addDoubleEmphasisToRange:range inAttributedString:state.currentString];
    }
    
    hoedown_buffer_put(ob, tb->data, tb->size);
    return 1;
}

int parser_emphasis(hoedown_buffer *ob, const hoedown_buffer *tb, void *opaque) {
    if (!tb || !tb->size)
        return 0;
    
    NORMarkdownParserState *state = (__bridge NORMarkdownParserState *)opaque;
    
    if (state) {
        NSString *text = [[NSString alloc] initWithBytes:tb->data length:tb->size encoding:NSUTF8StringEncoding];
        NSRange range = [state.currentRawString rangeOfString:text options:NSBackwardsSearch | NSAnchoredSearch];
        if (range.location != NSNotFound)
            [state.style addEmphasisToRange:range inAttributedString:state.currentString];
    }
    
    hoedown_buffer_put(ob, tb->data, tb->size);
    return 1;
}

int parser_underline(hoedown_buffer *ob, const hoedown_buffer *tb, void *opaque) {
    if (!tb || !tb->size)
        return 0;
    
    NORMarkdownParserState *state = (__bridge NORMarkdownParserState *)opaque;
    
    if ([state.style respondsToSelector:@selector(addUnderlineToRange:inAttributedString:)]) {
        NSString *text = [[NSString alloc] initWithBytes:tb->data length:tb->size encoding:NSUTF8StringEncoding];
        NSRange range = [state.currentRawString rangeOfString:text options:NSBackwardsSearch | NSAnchoredSearch];
        if (range.location != NSNotFound)
            [state.style addUnderlineToRange:range inAttributedString:state.currentString];
    }
    
    hoedown_buffer_put(ob, tb->data, tb->size);
    return 1;
}

int parser_highlight(hoedown_buffer *ob, const hoedown_buffer *tb, void *opaque) {
    if (!tb || !tb->size)
        return 0;
    
    NORMarkdownParserState *state = (__bridge NORMarkdownParserState *)opaque;
    
    if ([state.style respondsToSelector:@selector(addHighlightToRange:inAttributedString:)]) {
        NSString *text = [[NSString alloc] initWithBytes:tb->data length:tb->size encoding:NSUTF8StringEncoding];
        NSRange range = [state.currentRawString rangeOfString:text options:NSBackwardsSearch | NSAnchoredSearch];
        if (range.location != NSNotFound)
            [state.style addHighlightToRange:range inAttributedString:state.currentString];
    }
    
    hoedown_buffer_put(ob, tb->data, tb->size);
    return 1;
}

int parser_strikethrough(hoedown_buffer *ob, const hoedown_buffer *tb, void *opaque) {
    if (!tb || !tb->size)
        return 0;
    
    NORMarkdownParserState *state = (__bridge NORMarkdownParserState *)opaque;
    
    if ([state.style respondsToSelector:@selector(addStrikethroughToRange:inAttributedString:)]) {
        NSString *text = [[NSString alloc] initWithBytes:tb->data length:tb->size encoding:NSUTF8StringEncoding];
        NSRange range = [state.currentRawString rangeOfString:text options:NSBackwardsSearch | NSAnchoredSearch];
        if (range.location != NSNotFound)
            [state.style addStrikethroughToRange:range inAttributedString:state.currentString];
    }
    
    hoedown_buffer_put(ob, tb->data, tb->size);
    return 1;
}

int parser_quote(hoedown_buffer *ob, const hoedown_buffer *text, void *opaque) {
    // TODO: Add quote support
    return 0;
}

int parser_image(hoedown_buffer *ob, const hoedown_buffer *link, const hoedown_buffer *title, const hoedown_buffer *alt, void *opaque) {
    // TODO: Add image support
    return 0;
}

int parser_linebreak(hoedown_buffer *ob, void *opaque) {
    NORMarkdownParserState *state = (__bridge NORMarkdownParserState *)opaque;
    if (state) {
        [state.currentRawString appendString:@"\n"];
        [state.currentString appendAttributedString:[state.style baseAttributedStringWithString:@"\n"]];
    }
    
    HOEDOWN_BUFPUTSL(ob, "\n");
    return 0;
}
