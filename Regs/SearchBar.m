//
//  SearchBar.m
//  Regs
//
//  Created by Matthew Zorn on 12/9/14.
//  Copyright (c) 2014 Matthew Zorn. All rights reserved.
//

#import "SearchBar.h"
#import "RegsStyle.h"
#import "UIImage+Ext.h"

@implementation SearchBar

@synthesize searchField = _searchField;
@synthesize clearButton = _clearButton;

- (id) initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
       self.layer.borderWidth = 1;
       self.layer.borderColor = [UIColor lightGrayColor].CGColor;
        [self addSubview:self.searchField];
        self.searchField.rightView = self.clearButton;
    }
    return self;
}

-(void)layoutSubviews {
    self.searchField.frame = CGRectInset(self.frame, 5, 0);
}

-(UITextField *) searchField {
    if(!_searchField) {
        _searchField = [[UITextField alloc] initWithFrame:CGRectZero];
        _searchField.backgroundColor = [UIColor whiteColor];
        _searchField.font = [RegsStyle defaultLabelFont];
        _searchField.translatesAutoresizingMaskIntoConstraints = NO;
        _searchField.keyboardAppearance = UIKeyboardAppearanceLight;
        _searchField.returnKeyType = UIReturnKeySearch;
        _searchField.rightViewMode = UITextFieldViewModeAlways;
        _searchField.rightView = [self clearButton];
        _searchField.font = [RegsStyle searchTextFont];
    }
    
    return _searchField;
}

-(UIButton *)clearButton {
    if(!_clearButton) {
        _clearButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
        _clearButton.backgroundColor = [UIColor clearColor];
        [_clearButton setImage:[[UIImage imageNamed:@"multiply-symbol-mini"] imageWithColor:[UIColor lightGrayColor]] forState:UIControlStateNormal];
    }
    
    return _clearButton;
}
@end