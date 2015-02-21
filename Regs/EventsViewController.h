//
//  EventsViewController.h
//  Regs
//
//  Created by Matthew Zorn on 12/25/14.
//  Copyright (c) 2014 Matthew Zorn. All rights reserved.
//

#import "BaseViewController.h"

@interface EventsViewController : BaseViewController

@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSMutableArray *events;

@end
