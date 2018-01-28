//
//  MusicListViewController.m
//  pinaoplayer
//
//  Created by andy on 2018/1/15.
//  Copyright © 2018年 boyun. All rights reserved.
//

#import "MusicListViewController.h"

@interface MusicListViewController ()
@property (weak, nonatomic) IBOutlet UISearchBar *searchbar;

@end

@implementation MusicListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor whiteColor]];

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
