//
//  THSocketConnection.h
//  TaiheSocketTest
//
//  Created by admin on 16/5/19.
//  Copyright © 2016年 admin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    SocketConnectStateOnline = 1,
    SocketConnectStateOffline = 2,
    SocketConnectStateNormal = 3,
    SocketConnectStateAlarm = 4,
}SocketConnectState;


@interface ECSocketConnection : NSObject

@property (nonatomic, assign) BOOL isConnected;

+(instancetype)defaultSocketConnection;

/**
 *  连接服务器socket
 *
 *  @param callBackBlock
 */
- (void)startConnectSocket:(void(^)(BOOL connectState))callBackBlock;

/**
 *  socket登陆server
 *
 */
- (void) loginServer:(void(^)(BOOL loginState))loginBlock;
/**
 *  socket心跳包
 *
 *  @param heartBlock 返回是否需要从新连接
 */
- (void)heart:(void(^)(BOOL reconnect))heartBlock;

/**
 *  socket更新设备，客户端状态
 *
 *  @param status 状态
 */
- (void)mqdeviceStatusUpdate:(NSString *)status;
/**
 *  断开socket连接
 *
 *  @return 返回是否成功
 */
- (BOOL)disconnectSocket;

@end
