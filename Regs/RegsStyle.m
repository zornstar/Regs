//
//  RegsStyle.m
//  Regs
//
//  Created by Matthew Zorn on 12/7/14.
//  Copyright (c) 2014 Matthew Zorn. All rights reserved.
//

#import "RegsStyle.h"
#import "UIColor+Custom.h"


@implementation RegsStyle

+ (UIColor *)defaultTintColor {
    return [UIColor colorWithRed:0.18f green:0.44f blue:0.51f alpha:1.00f];
}

+ (UIColor *) darkBackgroundColor {
    return [UIColor colorWithRed:3/255. green:45/255. blue:80/255. alpha:1];
}

+ (UIColor *) lineColor {
    return [UIColor colorWithRed:223/255. green:223/255. blue:216/255. alpha:1];;
}

+ (UIColor *)secondaryLineColor {
    return [UIColor colorWithRed:139/255. green:125/255. blue:107/255. alpha:1];
}

+ (UIColor *)primaryBackgroundColor {
    return [UIColor colorWithRed:247/255. green:248/255. blue:241/255. alpha:1];
}

+ (UIColor *)secondaryBackgroundColor {
    return [UIColor colorWithRed:238/255. green:238/255. blue:229/255. alpha:1];
}

+ (UIColor *)primaryTextColor {
    return [UIColor blackColor];
}

+ (UIColor *)secondaryTextColor {
    return [UIColor lightGrayColor];
}

+ (UIFont *)searchTextFont {
    return [UIFont fontWithName:@"Palatino-Roman" size:14];
}

+ (UIFont *) segmentedControlFont {
    return [UIFont fontWithName:@"Lato-Regular" size:12];
}

+ (UIFont *)navBarFont {
    return [UIFont fontWithName:@"Lato-Regular" size:22];
}

+ (UIFont *)defaultLabelFont {
    return [UIFont fontWithName:@"Lato-Regular" size:14];
}

+ (UIFont *)titleLabelFont {
    return [UIFont fontWithName:@"Lato-Regular" size:12];
}

+ (UIFont *)detailTextFont {
    return [UIFont fontWithName:@"Lato-Thin" size:11];
}

+ (UIFont *)summaryTextFont {
    return [UIFont fontWithName:@"Palatino-Roman" size:10];
}

@end
