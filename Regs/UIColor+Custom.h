//
//  UIColor+Custom.h
//  Patents
//
//  Created by Matthew Zorn on 9/21/14.
//  Copyright (c) 2014 Matthew Zorn. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIColor (Custom)

+ (UIColor *) colorWithRGBString:(NSString *)string;
+ (UIColor *) darkerColorForColor:(UIColor *)c;
+ (UIColor *) lighterColorForColor:(UIColor *)c;
+ (UIColor *) colorWithHex:(NSString *)hex;

@end
