//
//  RegsNavigationController.m
//  Regs
//
//  Created by Matthew Zorn on 12/7/14.
//  Copyright (c) 2014 Matthew Zorn. All rights reserved.
//

#import "RegsNavigationController.h"

@implementation RegsNavigationController

-(void) pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    self.topViewController.title = @" ";
    [super pushViewController:viewController animated:animated];
}

@end
