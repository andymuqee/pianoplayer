//
//  THSocketConnection.m
//  TaiheSocketTest
//
//  Created by admin on 16/5/19.
//  Copyright © 2016年 admin. All rights reserved.
//

#import "ECSocketConnection.h"

#import "AppDelegate.h"


#define HOST @"60.205.126.163"
#define PORT 8286
//设置连接超时
#define TIME_OUT 20

#define DEVICE_GUID @"deviceGUID"
#define MQ_SID @"123456"
#define MQ_SID_INT 123456

#define STATE_SUCCESS 1
#define STATE_FAILED 0

typedef void(^HaertBlock)(BOOL reconnect);
typedef void(^ConnectStateBlock)(BOOL stateBlock);
typedef void(^LoginStateBlock)(BOOL stateBlock);

@interface ECSocketConnection ()<AsyncSocketDelegate>
{
    
}

@property (nonatomic, strong) AsyncSocket         *socket;
@property (nonatomic, copy)HaertBlock heartBlock;
@property (nonatomic, copy)ConnectStateBlock connectCallBackBlock;
@property (nonatomic, copy)LoginStateBlock loginCallBackBlock;

@property (nonatomic, strong)NSMutableArray *heartBeatStackArray;

@end


@implementation ECSocketConnection

+(instancetype)defaultSocketConnection
{
    static ECSocketConnection *_socketConnection=nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _socketConnection = [[self alloc] init];
    });
    return _socketConnection;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.socket = [[AsyncSocket alloc] initWithDelegate:self];
        self.heartBeatStackArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)startConnectSocket:(void(^)(BOOL connectState))connectBlock
{
    [self.socket disconnect];
    
    if (self.socket.isConnected) {
        connectBlock(YES);
        return;
    }
    self.connectCallBackBlock = connectBlock;
    [self.socket setRunLoopModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
    if (![self SocketOpen:HOST port:PORT] )
    {
        
    }
}

- (NSInteger)SocketOpen:(NSString*)addr port:(NSInteger)port
{
    if (![self.socket isConnected])
    {
        NSError *error = nil;
        [self.socket connectToHost:addr onPort:port withTimeout:TIME_OUT error:&error];
    }
    return 0;
}

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    NSLog(@"didConnectToHost");
    
    BOOL isConnected = YES;
    self.connectCallBackBlock(isConnected);
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock
{
    [self setIsConnected:NO];
    NSLog(@"onSocketDidDisconnect");
}


//{"requestEvent":"login","event":"response","sid":"123456"}
- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"didReadData %@",dataStr);
    
    [self analyzeWithResponceString:dataStr];

    [self.socket readDataWithTimeout:-1 tag:MQ_SID_INT];
}


- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    NSLog(@"didWriteDataWithTag");
}




- (void) loginServer:(void(^)(BOOL loginState))loginBlock
{
    self.loginCallBackBlock = loginBlock;
    
    
    NSString *deviceGUID = [self getDeviceID];
    
    
    //{"event":"login","deviceId":"设备唯一ID"（友盟ID）,"type":"mqc/mqlc/mqd/mqdg" ,"sid":"123456"} ＊＊
    NSDictionary *bodyDic = [[NSDictionary alloc] initWithObjectsAndKeys:@"login",@"event",deviceGUID,@"deviceId",@"mqc",@"type",MQ_SID,@"sid", nil];
    
    NSString *bodyString = [self dictionaryToJson:bodyDic];
    
    NSData   *data  = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    [self.socket writeData:data withTimeout:TIME_OUT tag:MQ_SID_INT];
    [self.socket readDataWithTimeout:TIME_OUT tag:MQ_SID_INT];
}


//{"event":"statusUpdate","deviceId":"设备唯一ID","status":"online/offline/alarm/normal","sid":"123456"} ＊＊
- (void)mqdeviceStatusUpdate:(NSString *)status
{
    
    NSString *deviceGUID = [self getDeviceID];

    NSDictionary *bodyDic = [[NSDictionary alloc] initWithObjectsAndKeys:@"statusUpdate",@"event",deviceGUID,@"deviceId",status,@"status",MQ_SID,@"sid", nil];
    
    NSString *bodyString = [self dictionaryToJson:bodyDic];
    
    NSData   *data  = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    [self.socket writeData:data withTimeout:TIME_OUT tag:MQ_SID_INT];
    [self.socket readDataWithTimeout:TIME_OUT tag:MQ_SID_INT];

}

- (void)heart:(void(^)(BOOL reconnect))heartBlock{
    NSString * stringforSend=@"heartBeat";
    [self.heartBeatStackArray addObject:@"heartBeat"];
//    NSLog(@"heartBeatStackArray count:%ld",self.heartBeatStackArray.count);
    if (self.heartBeatStackArray.count > 3 || self.isConnected == NO) {
        [self.heartBeatStackArray removeAllObjects];
        heartBlock(YES);
    }
    
    NSData  *data  = [stringforSend dataUsingEncoding:NSUTF8StringEncoding];
    [self.socket writeData:data withTimeout:TIME_OUT tag:MQ_SID_INT];
    [self.socket readDataWithTimeout:TIME_OUT tag:MQ_SID_INT];
}

- (BOOL)disconnectSocket
{
    NSString *stringforSend =@"";
    NSData   *data  = [stringforSend dataUsingEncoding:NSUTF8StringEncoding];
    [self.socket writeData:data withTimeout:TIME_OUT tag:MQ_SID_INT];
    [self.socket readDataWithTimeout:TIME_OUT tag:MQ_SID_INT];
    
    [self.socket disconnect];
    
    [self setIsConnected:NO];

    return !self.socket.isConnected;
}


- (NSString *)getDeviceID
{
    NSString * deviceGUID;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:DEVICE_GUID]) {
        deviceGUID = [[NSUserDefaults standardUserDefaults] objectForKey:DEVICE_GUID];
    }else{
        deviceGUID = [self getUniqueStrByUUID];
        [[NSUserDefaults standardUserDefaults] setObject:deviceGUID forKey:DEVICE_GUID];
    }
    
    return deviceGUID;
}

    
- (NSString *)getUniqueStrByUUID
{
    CFUUIDRef    uuidObj = CFUUIDCreate(nil);//create a new UUID
    //get the string representation of the UUID
    NSString    *uuidString = (__bridge_transfer NSString *)CFUUIDCreateString(nil, uuidObj);
    
    CFRelease(uuidObj);
    
    NSString *backStr = [uuidString stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
    return backStr;
}


- (NSString*)dictionaryToJson:(NSDictionary *)dic
{
    NSError *parseError = nil;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    
    NSString *postStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    postStr = [postStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    postStr = [postStr stringByAppendingString:@"\n"];
    
    return postStr;
}


- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    
    if (jsonString == nil) {
        
        return nil;
        
        
        
    }
    
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *err;
    
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                         
                                                        options:NSJSONReadingMutableContainers
                         
                                                          error:&err];
    
    if(err) {
        
        NSLog(@"json解析失败：%@",err);
        
        return nil;
        
    }
    
    return dic;
    
}

- (void)analyzeWithResponceString:(NSString *)responceStr
{
    NSDictionary *responceDic = [self dictionaryWithJsonString:responceStr];
    
    if (responceDic) {
        NSString *requestEvent = [responceDic objectForKey:@"requestEvent"];
        if ([requestEvent isEqualToString:@"login"]) {
            [self mqdeviceStatusUpdate:@"online"];
        }
    }
    

}


@end
