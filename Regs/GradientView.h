//
//  GradientView.h
//  Patents
//
//  Created by Matthew Zorn on 10/15/14.
//  Copyright (c) 2014 Matthew Zorn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GradientView : UIView

@property (nonatomic, readonly) CAGradientLayer *gradientLayer;
@property (nonatomic, readwrite) NSArray *colors;
@property (nonatomic, getter = isHorizontal) BOOL horizontal;

@end
