//
//  GAWBZXianLuTuCell.m
//  GuanAiJiaJia
//
//  Created by wxf on 16/10/31.
//  Copyright © 2016年 srgroup. All rights reserved.
//

#import "GAWBZXianLuTuCell.h"

@implementation GAWBZXianLuTuCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 200, 17)];
        _titleLabel.textColor = kCOLOR_333333;
        _titleLabel.font = [UIFont systemFontOfSize:15];
        [self.contentView addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UIImageView *)coverImageView
{
    if (!_coverImageView) {
        CGFloat y = CGRectGetMaxY(self.titleLabel.frame)+7;
        CGFloat height = self.frame.size.height -  y;
        _coverImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, y, self.frame.size.width, height)];
        _coverImageView.contentMode = UIViewContentModeScaleAspectFill;
        _coverImageView.layer.masksToBounds = YES;
        [self.contentView addSubview:_coverImageView];
    }
    return _coverImageView;
}

- (UIButton *)activityRuleBtn
{
    if (!_activityRuleBtn) {
        CGFloat ruleBtnWidth = 100;
        _activityRuleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _activityRuleBtn.frame = CGRectMake(kScreenWidth - ruleBtnWidth-10, 10, ruleBtnWidth, 20);
        [_activityRuleBtn setTitle:@"活动规则" forState:UIControlStateNormal];
        _activityRuleBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        _activityRuleBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [_activityRuleBtn setTitleColor:kCOLOR_999999 forState:UIControlStateNormal];
        [self.contentView addSubview:_activityRuleBtn];

    }
    return _activityRuleBtn;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat y = CGRectGetMaxY(self.titleLabel.frame)+7;
    CGFloat height = self.frame.size.height -  y-0.5;
    self.coverImageView.frame = CGRectMake(0, y, kScreenWidth, height);
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context =  UIGraphicsGetCurrentContext();
    CGContextMoveToPoint(context, 0, rect.size.height-0.5);
    CGContextAddLineToPoint(context, rect.size.width, rect.size.height-0.5);
    CGContextSetLineWidth(context, 0.5);
    [kCOLOR_999999 setStroke];
    CGContextDrawPath(context, kCGPathStroke);
}

@end
