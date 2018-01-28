//
//  MainViewController.m
//  pinaoforce
//
//  Created by andy on 2018/1/10.
//  Copyright © 2018年 boyun. All rights reserved.
//

#import "MainViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import<CoreBluetooth/CBService.h>
#import "JXTAlertManagerHeader.h"
@interface MainViewController (){
    NSTimer *_linkTimer;
    UILabel *alertLabel1;
    NSInteger _sum;
    UIImageView *linkImgV ;
}

@property(weak, nonatomic) IBOutlet UIView *menu;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [NSThread sleepForTimeInterval:3.0];
    //
    jxt_showLoadingHUDTitleMessage(@"自动演奏系统检测", @"正在检测...");
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        jxt_dismissHUD();
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
