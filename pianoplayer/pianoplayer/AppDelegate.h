//
//  AppDelegate.h
//  pianoplayer
//
//  Created by 迪吴 on 2018/1/28.
//  Copyright © 2018年 muqee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

