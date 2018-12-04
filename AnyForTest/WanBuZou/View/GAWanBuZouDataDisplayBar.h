//
//  GAWanBuZouDataDisplayBar.h
//  GuanAiJiaJia
//
//  Created by wxf on 16/10/18.
//  Copyright © 2016年 srgroup. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GAWanBuZouDataDisplayBar : UIView

@property(nonatomic,copy)NSString *distance;

@property(nonatomic,copy)NSString *calorie;

@property(nonatomic,copy)NSString *fat;

@end

@interface GAWanBuZouDataDisplayBarItem : UIView

@property(nonatomic,strong)UILabel *contentLabel;
@property(nonatomic,strong)UILabel *titleLabel;

@end
