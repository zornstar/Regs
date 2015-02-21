//
//  SearchBar.h
//  Regs
//
//  Created by Matthew Zorn on 12/9/14.
//  Copyright (c) 2014 Matthew Zorn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchBar : UIView

@property (nonatomic, strong, readonly) UITextField *searchField;
@property (nonatomic, strong, readonly) UIButton *clearButton;

@end
