//
//  AboutViewController.m
//  Regs
//
//  Created by Matthew Zorn on 11/12/14.
//  Copyright (c) 2014 Matthew Zorn. All rights reserved.
//

#import "AboutViewController.h"
#import "RegsStyle.h"


@interface AboutViewController () <UITextViewDelegate>

@property (nonatomic, strong) UITextView *textView;
@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"About";
    [self.view addSubview:self.containerView];
    [self.containerView addSubview:self.textView];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITextView *)textView {
    if(!_textView) {
        _textView = [[UITextView alloc] initWithFrame:CGRectInset(self.containerView.frame, 10, 10)];
        _textView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _textView.center = self.containerView.center;
        _textView.editable = NO;
        _textView.dataDetectorTypes = UIDataDetectorTypeLink;
        _textView.attributedText = [self text];
        _textView.selectable = YES;
        _textView.allowsEditingTextAttributes = NO;
        _textView.backgroundColor = [UIColor clearColor];
    }
    return _textView;
}

- (NSAttributedString *)text {
    NSMutableAttributedString *mutStr = [[NSMutableAttributedString alloc] initWithString:@"Regs is an a free and open-source application published under the Mozilla Public License.\n\nRegs uses the Regulations.gov API and the Docket Wrench API from www.sunlightfoundation.com.\n\n\n\n\n© 2015 M.C. Zorn"];
    [mutStr setAttributes:@{NSFontAttributeName:[RegsStyle titleLabelFont]} range:NSMakeRange(0, mutStr.length)];
    return mutStr;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)url inRange:(NSRange)characterRange {
    return YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
