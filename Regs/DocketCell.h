//
//  DocketCell.h
//  Regs
//
//  Created by Matthew Zorn on 11/24/14.
//  Copyright (c) 2014 Matthew Zorn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DocketCell : UITableViewCell

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UILabel *idLabel;
@property (nonatomic, strong) UILabel *summaryLabel;
@property (nonatomic, strong) UIImageView *iconView;

-(id) initWithReuseIdentifier:(NSString *)reuseIdentifier;

@end
