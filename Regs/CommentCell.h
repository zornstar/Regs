//
//  CommentCell.h
//  Regs
//
//  Created by Matthew Zorn on 12/7/14.
//  Copyright (c) 2014 Matthew Zorn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentCell : UITableViewCell

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UIImageView *iconView;

-(id) initWithReuseIdentifier:(NSString *)reuseIdentifier;


@end
