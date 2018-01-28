//
//  LinkGuideViewController.h
//  pinaoplayer
//
//  Created by andy on 2018/1/15.
//  Copyright © 2018年 boyun. All rights reserved.
//

#import "BaseViewController.h"
#import "GuideView1.h"
@interface LinkGuideViewController : BaseViewController

@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnClose;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@end
