//
//  RecentArticlesViewController.h
//  Regs
//
//  Created by Matthew Zorn on 12/31/14.
//  Copyright (c) 2014 Matthew Zorn. All rights reserved.
//

#import "ItemViewController.h"

@interface RecentArticlesViewController : ItemViewController

@property (nonatomic, strong) NSArray *entries;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *nextPage;

@end
