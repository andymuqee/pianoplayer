//
//  LinkGuideViewController.m
//  pinaoplayer
//
//  Created by andy on 2018/1/15.
//  Copyright © 2018年 boyun. All rights reserved.
//

#import "LinkGuideViewController.h"
@interface LinkGuideViewController ()
@property (strong, nonatomic) UIButton *btnNext;
@end

@implementation LinkGuideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.navigationBar setBackgroundImage:[[UIImage alloc]init] forBarMetrics:UIBarMetricsDefault];
    [self.navigationBar setShadowImage:[[UIImage alloc]init]];
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width * 3, self.scrollView.frame.size.height);
    
    UIImage *normal = [UIImage imageNamed:@"page_zz_btn_jx"];
    normal = [normal stretchableImageWithLeftCapWidth:normal.size.width*0.5 topCapHeight:normal.size.height*0.5];
    [self.btnNext setBackgroundImage:normal forState:UIControlStateNormal];
    
    GuideView1 *gv1 = [[GuideView1 alloc]initWithFrame:self.scrollView.frame];
    [gv1 setBackgroundColor:[UIColor redColor]];
    
    [self.btnNext initWithFrame:CGRectMake(10.0, 10.0, 100.0, 200.0)];
    [gv1 addSubview:(UIView*)self.btnNext];
//    [gv1 setBounds:self.scrollView.frame];
    
    [self.scrollView addSubview:gv1];
    //    [self.lg1.view setBounds:CGRectMake(-20, -20, 280, 250)];
//    [self.scrollView addSubview:self.lg1.view];
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
#pragma mark - ScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    NSLog(@"scroll");
}

- (IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"test");
    }];
}

@end
