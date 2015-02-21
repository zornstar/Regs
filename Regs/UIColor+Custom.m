//
//  UIColor+Custom.m
//  Patents
//
//  Created by Matthew Zorn on 9/21/14.
//  Copyright (c) 2014 Matthew Zorn. All rights reserved.
//

#import "UIColor+Custom.h"

@implementation UIColor (Custom)


+(UIColor *)colorWithRGBString:(NSString *)string {
    NSArray *components = [string componentsSeparatedByString:@";"];
    return [UIColor colorWithRed:[components[0] intValue] / 255. green:[components[1] intValue] / 255. blue:[components[2] intValue] / 255. alpha:1];
}

+ (UIColor *)darkerColorForColor:(UIColor *)c
{
    CGFloat r, g, b, a;
    if ([c getRed:&r green:&g blue:&b alpha:&a])
        return [UIColor colorWithRed:MAX(r - 0.2, 0.0)
                               green:MAX(g - 0.2, 0.0)
                                blue:MAX(b - 0.2, 0.0)
                               alpha:a];
    return nil;
}

+ (UIColor *)lighterColorForColor:(UIColor *)c
{
    CGFloat r, g, b, a;
    if ([c getRed:&r green:&g blue:&b alpha:&a])
    return [UIColor colorWithRed:MIN(r + 0.33, 1.)
                           green:MIN(g + 0.33, 1.)
                            blue:MIN(b + 0.33, 1.)
                           alpha:a];
    return nil;
}


+ (UIColor *)colorWithHex:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1];
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

@end
