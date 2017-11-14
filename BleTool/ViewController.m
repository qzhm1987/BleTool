//
//  ViewController.m
//  BleTool
//
//  Created by Mac on 2017/11/14.
//  Copyright © 2017年 BeiJingXiaoMenTong. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    NSString *string = @"244F01000000000000816838F8A897495A";
//    NSData *data = [self convertHexStrToData:string];
//    NSLog(@"data = %@",data);
    _baby = [BabyBluetooth shareBabyBluetooth];
    [self babyBlock];
    _baby.scanForPeripherals().begin();
    
    
    
    
    
    // Do any additional setup after loading the view, typically from a nib.
}


-(void)babyBlock {
    __weak ViewController *weakSelf = self;
    
   [ _baby setFilterOnDiscoverPeripherals:^BOOL(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI) {
       if ([peripheralName hasPrefix:@"XMT"]) {
           return YES;
       }
       return NO;
    }];
    
    
    [_baby setBlockOnDiscoverToPeripherals:^(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
        NSLog(@"name = %@   ad = %@",peripheral.name,advertisementData);
        NSData *data =advertisementData[@"kCBAdvDataManufacturerData"];
        NSString *string = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"string = %@",string);
        
        if ([peripheral.name hasPrefix:@"XMT"]) {
            weakSelf.baby.having(peripheral).connectToPeripherals().discoverServices().discoverCharacteristics().begin();
        }
        
    }];
    
    [_baby setBlockOnConnected:^(CBCentralManager *central, CBPeripheral *peripheral) {
        NSLog(@"连接成功");
        
    }];
    
    
    [_baby setBlockOnDiscoverServices:^(CBPeripheral *peripheral, NSError *error) {
        NSLog(@"ser = %@",peripheral.services);
        
    }];
    
    [_baby setBlockOnDiscoverCharacteristics:^(CBPeripheral *peripheral, CBService *service, NSError *error) {
        NSLog(@"char = %@",service.characteristics);
    }];
    
    
}




- (NSData *)convertHexStrToData:(NSString *)str {
    if (!str || [str length] == 0) {
        return nil;
    }
    
    NSMutableData *hexData = [[NSMutableData alloc] initWithCapacity:8];
    NSRange range;
    if ([str length] % 2 == 0) {
        range = NSMakeRange(0, 2);
    } else {
        range = NSMakeRange(0, 1);
    }
    for (NSInteger i = range.location; i < [str length]; i += 2) {
        unsigned int anInt;
        NSString *hexCharStr = [str substringWithRange:range];
        NSScanner *scanner = [[NSScanner alloc] initWithString:hexCharStr];
        
        [scanner scanHexInt:&anInt];
        NSData *entity = [[NSData alloc] initWithBytes:&anInt length:1];
        [hexData appendData:entity];
        
        range.location += range.length;
        range.length = 2;
    }
    
    return hexData;
}

/**
 data转16进制字符串
 * @ param data data
 @ return
 */
+ (NSString *)convertDataToHexStr:(NSData *)data {
    if (!data || [data length] == 0) {
        return @"";
    }
    NSMutableString *string = [[NSMutableString alloc] initWithCapacity:[data length]];
    
    [data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange,BOOL *stop) {
        unsigned char *dataBytes = (unsigned char*)bytes;
        for (NSInteger i =0; i < byteRange.length; i++) {
            NSString *hexStr = [NSString stringWithFormat:@"%x", (dataBytes[i]) &0xff];
            if ([hexStr length] == 2) {
                [string appendString:hexStr];
            } else {
                [string appendFormat:@"0%@", hexStr];
            }
        }
    }];
    
    return string;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
