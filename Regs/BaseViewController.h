//
//  BaseViewController.h
//  Regs
//
//  Created by Matthew Zorn on 11/27/14.
//  Copyright (c) 2014 Matthew Zorn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GradientView.h"
#import <PureLayout/PureLayout.h>
#import "EncapsulatedTableView.h"

@interface BaseViewController : UIViewController

@property (nonatomic, strong) GradientView *containerView;
@property (nonatomic, assign) BOOL didSetupConstraints;

- (void) setTitleView:(NSString *)title subtitle:(NSString *)subtitle;

@end
