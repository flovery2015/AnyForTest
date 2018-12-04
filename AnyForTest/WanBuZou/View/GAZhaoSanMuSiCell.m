//
//  GAZhaoSanMuSiCell.m
//  GuanAiJiaJia
//
//  Created by wxf on 16/10/31.
//  Copyright © 2016年 srgroup. All rights reserved.
//

#import "GAZhaoSanMuSiCell.h"
#import "GAStepDisplayView.h"

CGFloat const kGAZhaoSanMuSiCellHeight = 155;

@implementation GAZhaoSanMuSiCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _stepDisplayView = [[GAStepDisplayView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kGAZhaoSanMuSiCellHeight)];
        [self.contentView addSubview:_stepDisplayView];
    }
    return self;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
//    self.stepDisplayView.frame = CGRectMake(0, 0, self.frame.size.height, self.frame.size.width);
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
