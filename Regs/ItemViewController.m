//
//  ItemViewController.m
//  Regs
//
//  Created by Matthew Zorn on 11/12/14.
//  Copyright (c) 2014 Matthew Zorn. All rights reserved.
//

#import "ItemViewController.h"
#import "UIColor+Custom.h"
#import "RegsStyle.h"

@interface ItemViewController ()

@property (nonatomic, copy) NSString *cache_title;

@end

@implementation ItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.containerView];
    // Do any additional setup after loading the view.
}

@end
