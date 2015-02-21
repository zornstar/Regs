//
//  ItemScrollViewController.m
//  Regs
//
//  Created by Matthew Zorn on 1/13/15.
//  Copyright (c) 2015 Matthew Zorn. All rights reserved.
//

#import "ItemScrollViewController.h"

@interface ItemScrollViewController ()

@end

@implementation ItemScrollViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.scrollView];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIScrollView *)scrollView {
    if(!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.containerView.frame];
        _scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _scrollView;
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
