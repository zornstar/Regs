//
//  EncapsulatedTableView.m
//  Regs
//
//  Created by Matthew Zorn on 1/13/15.
//  Copyright (c) 2015 Matthew Zorn. All rights reserved.
//

#import "EncapsulatedTableView.h"

@implementation EncapsulatedTableView

-(id) init {
    if(self = [super init]) {
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.tableView];
    }
    return self;
}


- (void) layoutSubviews {
    
    [self.tableView setNeedsLayout];
    [self.tableView layoutIfNeeded];
    
    CGRect fr = self.tableView.frame;
    fr.size.height = MIN(self.tableView.contentSize.height, self.frame.size.height);
    self.tableView.frame = fr;
    
}
-(UITableView *) tableView {
    if(!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.frame style:UITableViewStylePlain];
        _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _tableView.bounces = NO;
        _tableView.layer.borderWidth = 1;
        _tableView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _tableView.sectionIndexColor = [UIColor darkGrayColor];
        _tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    }
    return _tableView;
}


@end
