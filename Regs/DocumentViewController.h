//
//  DocumentViewController.h
//  Regs
//
//  Created by Matthew Zorn on 11/12/14.
//  Copyright (c) 2014 Matthew Zorn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ItemScrollViewController.h"

@interface DocumentViewController : ItemScrollViewController

@property (nonatomic, copy) NSString *summary;
@property (nonatomic) BOOL hideDocket;

@end
