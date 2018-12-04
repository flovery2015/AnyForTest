//
//  GATodayBottomBar.h
//  GuanAiJiaJia
//
//  Created by wxf on 16/10/24.
//  Copyright © 2016年 srgroup. All rights reserved.
//

#import <UIKit/UIKit.h>


@class GATodayBottomViewItem;
@protocol GAWBZTodayBottomBarDelegate;
@interface GAWBZTodayBottomBar : UIView

@property(nonatomic,weak)id<GAWBZTodayBottomBarDelegate>delegate;


@end

@protocol GAWBZTodayBottomBarDelegate <NSObject>

- (void)didClickItemAtIndex:(NSInteger)index;

@end


@interface GATodayBottomViewItem : UIControl

@property(nonatomic,strong)UIImageView *icon;
@property(nonatomic,strong)UILabel *titleLabel;

@end
