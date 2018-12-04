//
//  GAWanBuZouDataDisplayBar.m
//  GuanAiJiaJia
//
//  Created by wxf on 16/10/18.
//  Copyright © 2016年 srgroup. All rights reserved.
//

#import "GAWanBuZouDataDisplayBar.h"

@implementation GAWanBuZouDataDisplayBar
{
    NSMutableArray *_items;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _items = [NSMutableArray array];
        CGFloat width = frame.size.width/3;
        CGFloat height = frame.size.height;
        
        NSArray *titles = @[@"行进里程·公里",@"热量大卡·大卡",@"历史步数·步"];
        for (int i=0; i<3; i++) {
            GAWanBuZouDataDisplayBarItem *item = [[GAWanBuZouDataDisplayBarItem alloc] initWithFrame:CGRectMake(width*i, 0, width, height)];
            item.titleLabel.text = titles[i];;
            [self addSubview:item];
            [_items addObject:item];
        }
    }
    return self;
}


- (void)setDistance:(NSString *)distance
{
    _distance = distance;
    GAWanBuZouDataDisplayBarItem *item = _items[0];
    item.contentLabel.text = distance;
}

- (void)setCalorie:(NSString *)calorie
{
    _calorie = calorie;
    GAWanBuZouDataDisplayBarItem *item = _items[1];
    item.contentLabel.text = calorie;
}

- (void)setFat:(NSString *)fat
{
    _fat = fat;
    GAWanBuZouDataDisplayBarItem *item = _items[2];
    item.contentLabel.text = fat;
}

@end

@implementation GAWanBuZouDataDisplayBarItem

- (UILabel *)contentLabel
{
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 25)];
        _contentLabel.textAlignment = NSTextAlignmentCenter;
        _contentLabel.font = [UIFont boldSystemFontOfSize:18];
        _contentLabel.textColor = kCOLOR_333333;
        [self addSubview:_contentLabel];
    }
    return _contentLabel;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 25+5, self.frame.size.width, 15)];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont systemFontOfSize:13];
        _titleLabel.textColor = kCOLOR_999999;
        [self addSubview:_titleLabel];
    }
    return _titleLabel;
}

@end
