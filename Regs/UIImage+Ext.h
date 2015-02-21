//
//  UIImage.h
//  iBiller
//
//  Created by Matthew Zorn on 9/12/14.
//  Copyright (c) 2014 Matthew Zorn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Ext)

- (UIImage *)imageWithColor:(UIColor *)color;
+ (UIImage *) imageWithView:(UIView *)view;
+ (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;

@end
