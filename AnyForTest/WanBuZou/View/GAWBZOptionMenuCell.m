//
//  GAWBZOptionMenuCell.m
//  GuanAiJiaJia
//
//  Created by wxf on 16/10/31.
//  Copyright © 2016年 srgroup. All rights reserved.
//

#import "GAWBZOptionMenuCell.h"
#import "GAWBZTodayBottomBar.h"

CGFloat const kGAWBZOptionMenuCellHeight = 85;

@implementation GAWBZOptionMenuCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.backgroundColor = GAJJ_RGBA(240, 240, 240, 1);
        self.optionMenuBar = [[GAWBZTodayBottomBar alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, GAFloat(kGAWBZOptionMenuCellHeight))];
        [self.contentView addSubview:self.optionMenuBar];
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

@end
