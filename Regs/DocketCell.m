//
//  DocketCell.m
//  Regs
//
//  Created by Matthew Zorn on 11/24/14.
//  Copyright (c) 2014 Matthew Zorn. All rights reserved.
//

#import "DocketCell.h"
#import "UIColor+Custom.h"

@interface DocketCell ()

@property (nonatomic) BOOL constraintsDidSet;


@end

@implementation DocketCell

-(id) initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if(self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.dateLabel];
        [self.contentView addSubview:self.idLabel];
        [self.contentView addSubview:self.summaryLabel];
        [self.contentView addSubview:self.iconView];
        [self layoutSubviews];
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
    CGFloat leftEdge = 25;
    self.titleLabel.frame = CGRectMake(leftEdge, 5, rightEdge, self.titleLabel.frame.size.height);
    [self.titleLabel sizeToFit];
    [self.idLabel sizeToFit];
    self.idLabel.frame = CGRectMake(leftEdge, CGRectGetMaxY(self.titleLabel.frame), self.titleLabel.frame.size.width/2.-10, 15);
    self.dateLabel.frame = CGRectMake(rightEdge - self.titleLabel.frame.size.width/2., CGRectGetMaxY(self.titleLabel.frame), self.titleLabel.frame.size.width/2.-10, 15);
    self.summaryLabel.frame = CGRectMake(leftEdge, CGRectGetMaxY(self.idLabel.frame), rightEdge, 40);
}

-(UILabel *)titleLabel {
    if(!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont fontWithName:@"Lato-Regular" size:12];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _titleLabel.numberOfLines = 3;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
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
        _dateLabel.textAlignment = NSTextAlignmentRight;
        _dateLabel.textColor = [UIColor colorWithHex:@"#507786"];
    }
    return _dateLabel;
}

-(UILabel *)idLabel {
    if(!_idLabel) {
        _idLabel = [[UILabel alloc] init];
        _idLabel.font = [UIFont fontWithName:@"Lato-Thin" size:11];
        _idLabel.backgroundColor = [UIColor clearColor];
        _idLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _idLabel.numberOfLines = 1;
        _idLabel.textColor = [UIColor colorWithHex:@"#507786"];
    }
    return _idLabel;
}

-(UILabel *)summaryLabel {
    if(!_summaryLabel) {
        _summaryLabel = [[UILabel alloc] init];
        _summaryLabel.font = [UIFont fontWithName:@"Lato-Thin" size:10];
        _summaryLabel.backgroundColor = [UIColor clearColor];
        _summaryLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _summaryLabel.numberOfLines = 3;
        _summaryLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _summaryLabel.preferredMaxLayoutWidth = self.contentView.frame.size.width - self.imageView.frame.size.width - 10;
    }
    return _summaryLabel;
}

-(UIImageView *)iconView {
    if(!_iconView) {
        _iconView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _iconView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _iconView;
}

@end
