//
//  BaseViewController.m
//  MQ
//
//  Created by admin on 16/7/18.
//  Copyright © 2016年 ech. All rights reserved.
//

#import "BaseViewController.h"
#include <AudioToolbox/AudioToolbox.h>

@interface BaseViewController () {
    UILabel *titleLabel;

    SystemSoundID _sound;
}

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // 判断是否为跟视图 为1时为根视图
    if (self.navigationController.viewControllers.count > 1) {
        [self backButtonItem];
    }
    
    [self setNavUI];
    // Do any additional setup after loading the view.
}

- (void)backButtonItem {
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [backBtn addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
    [backBtn setBackgroundImage:[UIImage imageNamed:@"page_sale_nav_btn_rtn"] forState:UIControlStateNormal];


    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = item;
}

- (void)backClick {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)shake {
    _sound = kSystemSoundID_Vibrate;

    AudioServicesPlaySystemSound(_sound);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setNavUI {
    UIColor *bgColor;
    bgColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Navigation_BackgroundImage"]];
    self.view.backgroundColor = bgColor;

    UIImage *image = [[UIImage alloc] init];

    [self.navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];

    [self.navigationController.navigationBar setBarTintColor:bgColor];

//    self.navigationController.navigationBar.translucent = NO;

    self.navigationController.navigationBar.clipsToBounds = YES;


    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)initOrUpdateTitleView:(NSString *)title {
    if (!titleLabel) {
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 30)];
        [titleLabel setFont:[UIFont systemFontOfSize:18]];

        [titleLabel setTextAlignment:NSTextAlignmentCenter];
        [titleLabel setTextColor:[UIColor whiteColor]];
        self.navigationItem.titleView = titleLabel;


    }

    [titleLabel setText:title];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
