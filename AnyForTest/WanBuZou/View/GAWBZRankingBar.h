//
//  GAWBZRankingBar.h
//  GuanAiJiaJia
//
//  Created by wxf on 16/10/20.
//  Copyright © 2016年 srgroup. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GAWBZRankingitem;
@interface GAWBZRankingBar : UIView

@property(nonatomic,strong)GAWBZRankingitem *personalRanking;

@property(nonatomic,strong)GAWBZRankingitem *fenduiRanking;

@property(nonatomic,strong)GAWBZRankingitem *wanbulvRanking;
@end


@interface GAWBZRankingitem : UIControl

@property(nonatomic,strong)UILabel *contentLabel;

@property(nonatomic,strong)UILabel *titleLabel;

@property(nonatomic,assign)BOOL isDisplayLine;

@end
