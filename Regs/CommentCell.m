//
//  DocketCell.m
//  Regs
//
//  Created by Matthew Zorn on 11/24/14.
//  Copyright (c) 2014 Matthew Zorn. All rights reserved.
//

#import "CommentCell.h"
#import "UIColor+Custom.h"

@implementation CommentCell

-(id) initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if(self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.dateLabel];
        [self.contentView addSubview:self.iconView];
        [self updateConstraints];
    }
    return self;
}
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

-(void)layoutSubviews {
    [super layoutSubviews];
    self.iconView.frame = CGRectMake(5, 8, 16, 16);
    CGFloat rightEdge = self.contentView.frame.size.width - 40;
    CGFloat leftEdge = 30;
    self.titleLabel.frame = CGRectMake(leftEdge, 5, rightEdge, self.titleLabel.frame.size.height);
    [self.titleLabel sizeToFit];
    [self.dateLabel sizeToFit];
    self.dateLabel.frame = CGRectMake(leftEdge, CGRectGetMaxY(self.titleLabel.frame), self.titleLabel.frame.size.width/2.-10, 15);
}

-(UILabel *)titleLabel {
    if(!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont fontWithName:@"Lato-Regular" size:12];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _titleLabel.numberOfLines = 2;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _titleLabel.preferredMaxLayoutWidth = self.contentView.frame.size.width - self.imageView.frame.size.width - 10;
    }
    return _titleLabel;
}

-(UILabel *)dateLabel {
    if(!_dateLabel) {
        _dateLabel = [[UILabel alloc] init];
        _dateLabel.font = [UIFont fontWithName:@"Lato-Thin" size:11];
        _dateLabel.backgroundColor = [UIColor clearColor];
        _dateLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _dateLabel.numberOfLines = 1;
        _dateLabel.textColor = [UIColor colorWithHex:@"#507786"];
    }
    return _dateLabel;
    
}

-(UIImageView *)iconView {
    if(!_iconView) {
        _iconView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _iconView.translatesAutoresizingMaskIntoConstraints = NO;
        _iconView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _iconView;
}

@end
