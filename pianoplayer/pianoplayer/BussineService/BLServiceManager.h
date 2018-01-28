//
//  BLServiceManager.h
//  MQ
//
//  Created by admin on 16/7/18.
//  Copyright © 2016年 ech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Config.h"

typedef enum {
    ConnectStateConnecting = 1,//
    ConnectStateRecognition = 2,//
    ConnectStateConnected = 3,//设备正常 , 有水状态
    ConnectStateDisconnect = 4,//
    ConnectStateAlert = 5,// 设备报警 , 无水状态
}ConnectState ;


typedef enum {
    LinkTypeBackground = 1,
    LinkTypeFromGuide = 2,
}LinkType ;

@interface BLServiceManager : NSObject


@property(nonatomic, assign)ConnectState state;
@property(nonatomic, assign)LinkType linkType;

+ (instancetype)defaultManager;

- (void)start:(void(^)(ConnectState state,NSString *message))stateBlock;

- (void)stopScan;

- (void)begainScan;

- (void)disconnect;
@end
