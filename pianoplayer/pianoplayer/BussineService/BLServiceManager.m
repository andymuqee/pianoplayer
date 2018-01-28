//
//  BLServiceManager.m
//  MQ
//
//  Created by admin on 16/7/18.
//  Copyright © 2016年 ech. All rights reserved.
//

#import "BLServiceManager.h"
#import <CoreBluetooth/CoreBluetooth.h>
#include <AudioToolbox/AudioToolbox.h>
#import <UIKit/UIKit.h>
#import "ECSocketConnection.h"

#define DEVICE_PREFIX @"MQ_"

static NSString * const kServiceUUID = @"0000fff0-0000-1000-8000-00805f9b34fb";
static NSString * const kCharacteristicUUID = @"0000fff4-0000-1000-8000-00805f9b34fb";
static NSString * const kDESCRIPTORID = @"00002902-0000-1000-8000-00805f9b34fb";


static SystemSoundID shake_sound_male_id = 0;



typedef void(^ConnectBlock)(ConnectState state,NSString *message);

@interface BLServiceManager ()<CBCentralManagerDelegate, CBPeripheralDelegate>
{
    SystemSoundID _sound;
    CBPeripheral *_currentConnectedPeripheral;
    
    
    
}


@property (nonatomic, strong) CBCentralManager *myCentralManager;
@property (nonatomic, strong) CBPeripheral *targetPeripheral;

@property (nonatomic,copy)ConnectBlock connectBlock;
@property (nonatomic, strong)NSTimer *alarmTimer;

@end

@implementation BLServiceManager

+ (instancetype)defaultManager
{
    static BLServiceManager * _manager;
    static dispatch_once_t oncePredicate;

    dispatch_once(&oncePredicate, ^{
        _manager = [[self alloc] init];
    });
    
    return _manager;
}


- (instancetype)init{
    self = [super init];
    if (self) {

    }
    
    return self;
}

- (void)start:(void (^)(ConnectState, NSString *))stateBlock
{
    _connectBlock = stateBlock ;
    [self begainScan];
}

//查询蓝牙状态，可用的话，开始扫描
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    NSDictionary *scanOptions = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO], CBCentralManagerScanOptionAllowDuplicatesKey, nil];
    switch (central.state) {
        case CBCentralManagerStatePoweredOn:
            
            self.state = ConnectStateConnecting;
            
            _connectBlock(ConnectStateConnecting,@"连接中");
            
            [self.myCentralManager scanForPeripheralsWithServices:nil options:scanOptions];
            break;
            
        default:
            NSLog(@"Bluetooth is not working on the right state");

            break;
    }
}

//发现Peripheral并连接
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSLog(@"Discovered %@", peripheral.name);

    
    if (peripheral.name.length > 3 && [RSSI integerValue] > -66) {
        NSString *prefixStr = [peripheral.name substringWithRange:NSMakeRange(0, 3)];
        
        if ([prefixStr isEqualToString:DEVICE_PREFIX]) {
            
            if (self.linkType == LinkTypeBackground) {
                if ([self hasLinkedDevice:peripheral.name]) {
                    [self linkPeripheral:peripheral];
                }
            }
            
            if (self.linkType == LinkTypeFromGuide) {
                [self linkPeripheral:peripheral];
            }
        }

    }
 }

- (void)linkPeripheral:(CBPeripheral *)peripheral
{
    self.state = ConnectStateRecognition;
    
    _connectBlock(ConnectStateRecognition,peripheral.name);
    
    
    NSLog(@"Found MyCBServer");
    [self.myCentralManager stopScan];
    self.targetPeripheral = peripheral;
    
    [self.myCentralManager connectPeripheral:peripheral options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBConnectPeripheralOptionNotifyOnDisconnectionKey]];
    peripheral.delegate = self; // 处理peripheral的事件

}


//连接上peripheral, 并查询服务
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"Connected to %@", peripheral.name);
    [peripheral discoverServices:nil]; //nil，查询所有服务
    //[peripheral discoverServices:@[[CBUUID UUIDWithString:kServiceUUID]]];//查询指定服务
}

/*
 service's uuid : Device Information
 service's uuid : Unknown (<c5ac0853 51224856 ac70a80e 990d1c15>)
 
 上面的数字是在Mac上用uuidgen命令生成的。
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error) {
        NSLog(@"error in discovering serviecs: %@", [error localizedDescription]);
        return;
    }
    
    
    for (CBService *service in peripheral.services) {
        NSLog(@"service's uuid : %@", service.UUID);//[CBUUID UUIDWithString: kServiceUUID]
        if ([service.UUID isEqual:[CBUUID UUIDWithString: kServiceUUID]]||[service.UUID isEqual:[CBUUID UUIDWithString: kDESCRIPTORID]]) {
            //下面需要针对特定的service，让peripheral去查它的characteristics。这里即是针对kServiceUUID，查它下面的特征。
            [peripheral discoverCharacteristics:[NSArray arrayWithObject:[CBUUID UUIDWithString:kCharacteristicUUID]] forService:service];
        }
    }
}

//peripheral查到特征 打印所有特征
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (error) {
        NSLog(@"error discovering characteristic : %@", [error localizedDescription]);
    }
    
    for (CBCharacteristic *characteristic in service.characteristics) {
        NSLog(@"characteristic uuid: %@", [characteristic UUID]);
        
        //智能血压计需要将某些数据即时更新给central。这里，可以给指定的特征设置Notifiy, 设置以后，peripheral的特征值更新会及时通过delegate反馈过来
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kCharacteristicUUID]]) {
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
        
    }
}

//peripheral说特征值有更新
//上面setNotifyValue:YES函数设置了notify。那么这个特征值有更新的话，就会通过下面的函数告诉central
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"error notifying : %@", [error localizedDescription]);
        return;
    }
}


//peripheral读到数据,通过下面的代理方法获取value：
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"error update value : %@", [error localizedDescription]);
        return;
    }
    _currentConnectedPeripheral = peripheral;

  
    NSString *feedBackvalue = [self convertDataToHexStr:characteristic.value];
    
    if (![feedBackvalue intValue]) {
        [self playSound];
        
        
        if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
            [self addLocalNotification];
        }else{
            [self removeLocalNotification];
        }
        
        if (self.state != ConnectStateAlert) {
            self.state = ConnectStateAlert;
            [[ECSocketConnection defaultSocketConnection] mqdeviceStatusUpdate:@"alarm"];
            
            [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFY_CONNECT_STATE object:[NSNumber numberWithInt:ConnectStateAlert]];
            
            _connectBlock(ConnectStateAlert,@"没水了");
            
           

        }
    }else{
        
        
        if (self.state != ConnectStateConnected) {
            self.state = ConnectStateConnected;

            [self removeLocalNotification];
            
            [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFY_CONNECT_STATE object:[NSNumber numberWithInt:ConnectStateConnected]];
            
            
            
            [[ECSocketConnection defaultSocketConnection] mqdeviceStatusUpdate:@"normal"];
            
            //如果没有这个设备 保存
            if (![self hasLinkedDevice:peripheral.name]) {
                [self saveLinkedDevice:peripheral.name];
            }
            _connectBlock(ConnectStateConnected,@"成功连接");
        }
    
        
       
    }
    
    
    
    
    NSLog(@"Value: %@", feedBackvalue);
}


- (NSString *)convertDataToHexStr:(NSData *)data {
    if (!data || [data length] == 0) {
        return @"";
    }
    NSMutableString *string = [[NSMutableString alloc] initWithCapacity:[data length]];
    
    [data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
        unsigned char *dataBytes = (unsigned char*)bytes;
        for (NSInteger i = 0; i < byteRange.length; i++) {
            NSString *hexStr = [NSString stringWithFormat:@"%x", (dataBytes[i]) & 0xff];
            if ([hexStr length] == 2) {
                [string appendString:hexStr];
            } else {
                [string appendFormat:@"0%@", hexStr];
            }
        }
    }];
    
    return string;
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    self.state = ConnectStateDisconnect;
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFY_CONNECT_STATE object:[NSNumber numberWithInt:ConnectStateDisconnect]];
    _connectBlock(ConnectStateDisconnect,@"断开连接");
    [self removeLocalNotification];
    NSLog(@"didDisconnectPeripheral被动失去与设备的连接");
}

- (void)writeData
{
//    [self.targetPeripheral writeValue:data forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
}


- (void)stopScan
{
    [self.myCentralManager stopScan];
}

- (void)begainScan
{
    self.myCentralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    self.myCentralManager.delegate =self;
}

- (void)disconnect
{
    if (_currentConnectedPeripheral) {
        [self.myCentralManager cancelPeripheralConnection:_currentConnectedPeripheral];
    }
}

- (void)playSound
{
    
    _sound = kSystemSoundID_Vibrate;
    
    AudioServicesPlaySystemSound(_sound);
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"alarmSound" ofType:@"mp3"];
    if (path) {
        //注册声音到系统
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path],&shake_sound_male_id);
        AudioServicesPlaySystemSound(shake_sound_male_id);
        //        AudioServicesPlaySystemSound(shake_sound_male_id);//如果无法再下面播放，可以尝试在此播放
    }
    
    AudioServicesPlaySystemSound(shake_sound_male_id);   //播放注册的声音，（此句代码，可以在本类中的任意位置调用，不限于本方法中）
    
    
}

- (BOOL)hasLinkedDevice:(NSString *)deviceName
{
    BOOL success = NO;
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:LINKED_DEVICE_ARRAY];
    NSMutableArray *tmpArray = [[NSMutableArray alloc] init];
    
    if (!data) {
        
    }else{
        tmpArray = (NSMutableArray *)[NSKeyedUnarchiver unarchiveObjectWithData:data];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF == %@",deviceName];
        NSArray *resultsArray = [tmpArray filteredArrayUsingPredicate:predicate];
        if (resultsArray.count > 0) {
            success = YES;
        }
    }
    
    return success;
}

- (BOOL)saveLinkedDevice:(NSString *)deviceName
{
    BOOL success = NO;
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:LINKED_DEVICE_ARRAY];
    NSMutableArray *tmpArray = [[NSMutableArray alloc] init];
    
    if (!data) {
        [tmpArray addObject:deviceName];
        
    }else{
        tmpArray = (NSMutableArray *)[NSKeyedUnarchiver unarchiveObjectWithData:data];
        [tmpArray addObject:deviceName];
        
    }
    
    NSData *saveArrayData = [NSKeyedArchiver archivedDataWithRootObject:tmpArray];
    if (saveArrayData) {
        [[NSUserDefaults standardUserDefaults]setObject:saveArrayData forKey:LINKED_DEVICE_ARRAY];
        success = YES;
    }
    
    return success;
    
}



- (void)addLocalNotification
{

    
    if (!self.alarmTimer.valid) {
        self.alarmTimer = [NSTimer timerWithTimeInterval:3 target:self selector:@selector(localNotification) userInfo:nil repeats:YES];
        
        [[NSRunLoop currentRunLoop]addTimer:self.alarmTimer forMode:NSRunLoopCommonModes];
        
        [self.alarmTimer fire];

    }
}


- (void)removeLocalNotification
{
    [self.alarmTimer invalidate];
    self.alarmTimer = nil;
}

- (void)localNotification
{
    UILocalNotification* localNotification=[[UILocalNotification alloc]init];
    
    NSDate *pushDate = [NSDate dateWithTimeIntervalSinceNow:0];
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    localNotification.fireDate = pushDate;
    //    localNotification.repeatInterval = kCFCalendarUnitDay; 设置重复频率，不设置则为不重复
    localNotification.applicationIconBadgeNumber = 1;
    localNotification.soundName=@"alarmSound.caf";
    localNotification.alertBody = @"请注意，点滴即将打完";
    //    localNotification.alertLaunchImage=[[NSBundle mainBundle]pathForResource:@"3" ofType:@"jpg"];
    
    
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationType type =  UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:type
                                                                                 categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        // 通知重复提示的单位，可以是天、周、月
        //        localNotification.repeatInterval = NSCalendarUnitDay;
    } else {
        // 通知重复提示的单位，可以是天、周、月
        //        localNotification.repeatInterval = NSDayCalendarUnit;
    }
    
    NSDictionary* infoDic=[NSDictionary dictionaryWithObject:@"moAppLocalNotification" forKey:@"NotifName"];
    localNotification.userInfo=infoDic;
    
    UIApplication* app=[UIApplication sharedApplication];
    
    //    BOOL status=YES;
    //    for (UILocalNotification* notification in app.scheduledLocalNotifications) {
    //
    //
    //        if ([[notification.userInfo objectForKey:@"NotifName"] isEqualToString:@"moAppLocalNotification"]) {
    //            status=NO;
    //        }
    //    }
    
    [app scheduleLocalNotification:localNotification];

}

@end




