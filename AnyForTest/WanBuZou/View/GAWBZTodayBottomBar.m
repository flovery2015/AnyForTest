//
//  GATodayBottomBar.m
//  GuanAiJiaJia
//
//  Created by wxf on 16/10/24.
//  Copyright © 2016年 srgroup. All rights reserved.
//

#import "GAWBZTodayBottomBar.h"


@implementation GAWBZTodayBottomBar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat magin = 5;
        CGFloat width = (frame.size.width - magin*2)/5;
        
        //我要PK
        GATodayBottomViewItem *itemPK = [[GATodayBottomViewItem alloc] initWithFrame:CGRectMake(0, 0, width*1.5, self.frame.size.height)];
        itemPK.icon.image = [UIImage imageNamed:@"wbz_btn_woyaopk"];
        itemPK.titleLabel.text = @"我要PK";
        itemPK.tag = 2016+0;
        [itemPK addTarget:self action:@selector(clickAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:itemPK];
        
        //荣誉榜
        GATodayBottomViewItem *itemRongyubang = [[GATodayBottomViewItem alloc] initWithFrame:CGRectMake(CGRectGetMaxX(itemPK.frame)+magin, 0, width*2, self.frame.size.height)];
        itemRongyubang.icon.image = [UIImage imageNamed:@"wbz_btn_rongyubang"];
        itemRongyubang.titleLabel.text = @"荣誉榜";
        [itemRongyubang addTarget:self action:@selector(clickAction:) forControlEvents:UIControlEventTouchUpInside];
         itemRongyubang.tag = 2016+1;
        [self addSubview:itemRongyubang];
        
        //约跑
        GATodayBottomViewItem *itemYuepao = [[GATodayBottomViewItem alloc] initWithFrame:CGRectMake(CGRectGetMaxX(itemRongyubang.frame)+5, 0, width*1.5, self.frame.size.height)];
        itemYuepao.icon.image = [UIImage imageNamed:@"wbz_btn_yuepao"];
        itemYuepao.titleLabel.text = @"约跑";
         itemYuepao.tag = 2016+2;
        [itemYuepao addTarget:self action:@selector(clickAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:itemYuepao];
        
    }
    return self;
}

- (void)clickAction:(GATodayBottomViewItem *)item
{
    if ([self.delegate respondsToSelector:@selector(didClickItemAtIndex:)]) {
        [self.delegate didClickItemAtIndex:item.tag-2016];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

@implementation GATodayBottomViewItem

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
    }
    return self;
}


- (UIImageView *)icon
{
    if (!_icon) {
        CGFloat iconHeight = 25;
        _icon = [[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width - iconHeight)*0.5, self.frame.size.height*0.5-iconHeight, iconHeight, iconHeight)];
        _icon.contentMode = UIViewContentModeCenter;
        [self addSubview:_icon];
    }
    return _icon;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.icon.frame)+GAFloat(10), self.frame.size.width, 17)];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _titleLabel.textColor = kCOLOR_999999;
        [self addSubview:_titleLabel];
    }
    return _titleLabel;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end




