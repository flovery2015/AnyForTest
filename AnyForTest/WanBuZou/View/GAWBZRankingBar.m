//
//  GAWBZRankingBar.m
//  GuanAiJiaJia
//
//  Created by wxf on 16/10/20.
//  Copyright © 2016年 srgroup. All rights reserved.
//

#import "GAWBZRankingBar.h"

@implementation GAWBZRankingBar

- (GAWBZRankingitem *)personalRanking
{
    if (!_personalRanking) {
        _personalRanking = [[GAWBZRankingitem alloc] initWithFrame:CGRectMake(0, 1, self.frame.size.width/2, self.frame.size.height-1)];
        _personalRanking.backgroundColor = [UIColor whiteColor];
        _personalRanking.isDisplayLine = YES;
        _personalRanking.titleLabel.text = @"个人排名：";
        [self addSubview:_personalRanking];
    }
    return _personalRanking;
}

- (GAWBZRankingitem *)fenduiRanking
{
    if (!_fenduiRanking) {
        _fenduiRanking = [[GAWBZRankingitem alloc] initWithFrame:CGRectMake(self.frame.size.width/4, 1, self.frame.size.width/2, self.frame.size.height-1)];
        _fenduiRanking.backgroundColor = [UIColor whiteColor];
        _fenduiRanking.isDisplayLine = YES;
        _fenduiRanking.titleLabel.text = @"分队排名：";
        [self addSubview:_fenduiRanking];
    }
    return _fenduiRanking;
}

- (GAWBZRankingitem *)wanbulvRanking
{
    if (!_wanbulvRanking) {
        _wanbulvRanking = [[GAWBZRankingitem alloc] initWithFrame:CGRectMake(self.frame.size.width/2,1, self.frame.size.width/2, self.frame.size.height-1)];
         _wanbulvRanking.backgroundColor = [UIColor whiteColor];
        _wanbulvRanking.isDisplayLine = NO;
        _wanbulvRanking.titleLabel.text = @"万步率排名：";
        [self addSubview:_wanbulvRanking];
    }
    return _wanbulvRanking;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextMoveToPoint(context, 0, 0.5);
    CGContextAddLineToPoint(context, rect.size.width, 0.5);
    CGContextSetLineWidth(context, 1);
    [kCOLOR_Line setStroke];
    CGContextDrawPath(context, kCGPathFillStroke);
    
}

@end

@implementation GAWBZRankingitem


- (void)setIsDisplayLine:(BOOL)isDisplayLine
{
    _isDisplayLine = isDisplayLine;
    [self setNeedsDisplay];
}


- (UILabel *)contentLabel
{
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width*0.5, 0, self.frame.size.width*0.5, self.frame.size.height)];
        _contentLabel.textColor = kCOLOR_333333;
        _contentLabel.font = [UIFont boldSystemFontOfSize:18.0];
        _contentLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_contentLabel];
    }
    return _contentLabel;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width*0.5, self.frame.size.height)];
        _titleLabel.textColor = kCOLOR_999999;
        _titleLabel.font = [UIFont systemFontOfSize:13.0];
        _titleLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:_titleLabel];
    }
    return _titleLabel;
}


 - (void)drawRect:(CGRect)rect {
     if (_isDisplayLine) {
         CGFloat lineWidth = 1;
         CGContextRef context = UIGraphicsGetCurrentContext();
         CGContextMoveToPoint(context, rect.size.width-lineWidth*0.5, 0);
         CGContextAddLineToPoint(context, rect.size.width-lineWidth*0.5, rect.size.height);
         CGContextSetLineWidth(context, lineWidth);
         [kCOLOR_Line setStroke];
         CGContextDrawPath(context, kCGPathFillStroke);
     }
 }
 

@end
