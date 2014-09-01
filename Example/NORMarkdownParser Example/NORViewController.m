//
//  NORViewController.m
//  NORMarkdownParser Example
//
//  Created by Henri Normak on 30/08/2014.
//  Copyright (c) 2014 Henri Normak. All rights reserved.
//

#import "NORViewController.h"
#import "NORMarkdownParser.h"
#import "NORMarkdownStyle.h"

@interface NORViewController () <UITextViewDelegate>

@end

@implementation NORViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    NORMarkdownParser *parser = [[NORMarkdownParser alloc] initWithExtensions:NORMarkdownAutolink | NORMarkdownHighlight | NORMarkdownStrikethrough | NORMarkdownUnderline];
    NORMarkdownStyle *style = [[NORMarkdownStyle alloc] init];
    style.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    parser.style = style;
    
    NSString *markdown = @"This is a *markdown* string, _boom!_ -> [GitHub](https://github.com/henrinormak/NORMarkdownParser)";
    NSString *stripped = nil;
    
    NSDate *date = [NSDate date];
    NSAttributedString *parsed = [parser attributedStringFromMarkdown:markdown strippedString:&stripped];
    NSTimeInterval interval = [date timeIntervalSinceNow];
    
    NSLog(@"Parsing took %fms", -interval * 1000);
    NSLog(@"Result \"%@\"", markdown);
    NSLog(@"Raw \"%@\"", stripped);
    
    UITextView *textView = [[UITextView alloc] init];
    textView.editable = NO;
    textView.attributedText = parsed;
    textView.delegate = self;
    CGRect frame = textView.frame;
    frame.origin = CGPointMake(40.f, 40.f);
    frame.size = [textView sizeThatFits:CGSizeMake(CGRectGetWidth(self.view.bounds) - 80.f, CGFLOAT_MAX)];
    textView.frame = frame;
    [self.view addSubview:textView];
}

#pragma mark -
#pragma mark UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange {
    return NO;
}

@end
