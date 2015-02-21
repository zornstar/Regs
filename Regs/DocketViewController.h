//
//  DocketViewController.h
//  Regs
//
//  Created by Matthew Zorn on 11/12/14.
//  Copyright (c) 2014 Matthew Zorn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ItemViewController.h"

@interface DocketViewController : ItemViewController  <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *entries;

@property (nonatomic, strong) EncapsulatedTableView *encapsulatedTableView;

@end
