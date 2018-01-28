//
//  MenuViewController.h
//  pinaoforce
//
//  Created by andy on 2018/1/13.
//  Copyright © 2018年 boyun. All rights reserved.
//

#import "BaseViewController.h"

@interface MenuViewController : BaseViewController
@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnClose;
@property (strong, nonatomic) IBOutlet UIImageView *logo;
@property (strong, nonatomic) IBOutlet UIView *menu;

@end
