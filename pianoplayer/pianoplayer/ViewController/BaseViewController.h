//
//  BaseViewController.h
//  MQ
//
//  Created by admin on 16/7/18.
//  Copyright © 2016年 ech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "../Config.h"
@interface BaseViewController : UIViewController

- (void)initOrUpdateTitleView:(NSString *)title;

- (void)shake;

- (void)backClick;
@end
