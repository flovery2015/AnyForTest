//
//  GAWanBuZouVC.m
//  GuanAiJiaJia
//
//  Created by wxf on 16/10/13.
//  Copyright © 2016年 srgroup. All rights reserved.
//

#import "GAWanBuZouVC.h"
#import "GAWanbuZouTodayDataVC.h"
#import "GAWanbuzouStatisticsCenterVC.h"
@interface GAWanBuZouVC ()<UIScrollViewDelegate>
{
    UIImageView *_uploadImgView;
    UIView *_windowView;
}
@property(nonatomic,strong)UIPageControl *pageControl;

@end

@implementation GAWanBuZouVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addSubViews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setBackgroundImage:nil
                                                 forBarPosition:UIBarPositionAny
                                                     barMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:nil];
}

- (void)addSubViews
{
     self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"今日数据";

    UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, kNavBarHeight, kScreenWidth, kScreenHeight-kNavBarHeight)];
    scroll.bounces = NO;
    scroll.delegate = self;
    scroll.showsVerticalScrollIndicator = NO;
    scroll.showsHorizontalScrollIndicator = NO;
    scroll.pagingEnabled = YES;
    [self.view addSubview:scroll];
    scroll.contentSize = CGSizeMake(kScreenWidth*2, kScreenHeight-kNavBarHeight);
    
    GAWanbuZouTodayDataVC *todayDataVC = [[GAWanbuZouTodayDataVC alloc] init];//今天的数据
    GAWanbuzouStatisticsCenterVC *statisticsCenterVC = [[GAWanbuzouStatisticsCenterVC alloc] init];//统计中心
    [self addChildViewController:todayDataVC];
    [self addChildViewController:statisticsCenterVC];
    
    CGSize viewSize = scroll.bounds.size;
    todayDataVC.view.frame = (CGRect){{0,0},viewSize};
    [scroll addSubview:todayDataVC.view];
    
    CGFloat pageControlBgHeight = GAFloat(45);
    UIView *pageControlBg = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight-pageControlBgHeight, CGRectGetWidth(scroll.frame), pageControlBgHeight)];
    [pageControlBg setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:pageControlBg];
    _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake((kScreenWidth-100)*0.5, 0, 100, pageControlBgHeight)];
    _pageControl.numberOfPages = 2;
    _pageControl.currentPageIndicatorTintColor = [UIColor colorWithHex:0x00aaff];
    _pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    [pageControlBg addSubview:self.pageControl];
    
    BOOL show = [NSUD boolForKey:@"showWindowUI"];
    if (!show) {
        [self configWindowUI];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger index = scrollView.contentOffset.x/scrollView.frame.size.width;
    self.pageControl.currentPage = index;
    
    if (index == 0) {
            self.title = @"今日数据";
    }else{
        self.title = @"统计中心";
    }

    UIViewController *vc = self.childViewControllers[index];
    if (vc.view.superview) {
        return;
    }
    
    CGSize viewSize = scrollView.bounds.size;
    vc.view.frame = (CGRect){{viewSize.width*index,0},viewSize};
    [scrollView addSubview:vc.view];
    
}


-(void)configWindowUI
{
    [NSUD setBool:YES forKey:@"showWindowUI"];
    [NSUD synchronize];
    
    _windowView = [[UIView alloc] init];
    _windowView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    _windowView.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    [[UIApplication sharedApplication].keyWindow addSubview:_windowView];
    
    UIImage *image = [UIImage imageNamed:@"walk_update"];
    UIButton *imgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    imgBtn.frame = CGRectMake(20, 80, image.size.width+20, image.size.height+20);
    imgBtn.layer.cornerRadius = (image.size.width+20)/2;
    [imgBtn setBackgroundColor:[UIColor whiteColor]];
    [imgBtn setImage:image forState:UIControlStateNormal];
    [imgBtn setImageEdgeInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
    [_windowView addSubview:imgBtn];
    
    
    UIImage *fImg = [UIImage imageNamed:@"run_figner_01"];
    UIImageView *figImgView = [[UIImageView alloc] init];
    figImgView.frame = CGRectMake(15, imgBtn.frame.size.height + imgBtn.frame.origin.y + 5, fImg.size.width, fImg.size.height);
    figImgView.image = fImg;
    [_windowView addSubview:figImgView];
    

    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(kScreenWidth / 2 - 80, kScreenHeight - 180, 160, 40);
    [btn setBackgroundColor:[UIColor themeColor]];
    [btn setTitle:@"知道了" forState:UIControlStateNormal];
    [btn setTintColor:[UIColor whiteColor]];
    btn.layer.cornerRadius = 6;
    [btn addTarget:self action:@selector(knowBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [_windowView addSubview:btn];
    
    
    UILabel *label = [[UILabel alloc ]init];
    label.frame = CGRectMake(CGRectGetMinX(btn.frame) - 20, CGRectGetMinY(btn.frame) - 50, 200, 40);
    label.text = @"点击可一键同步数据";
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:20];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = 1;
    [_windowView addSubview:label];

}

-(void)knowBtnClick
{
//    TCPOPT_WINDOW
    [_windowView removeFromSuperview];
}

@end
