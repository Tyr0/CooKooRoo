//
//  CKRBluetoothManager.h
//  CooKooRoo
//
//  Created by Tyler Calderone on 1/14/13.
//  Copyright (c) 2013 Tyler Calderone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@class CBCentralManager;
@class CBPeripheral;

@interface CKRBluetoothManager : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate> {
    CBCentralManager *theCentralManager;
    NSMutableArray *thePeripheralArray;
    CBPeripheral *thePeripheral;
    CBCharacteristic *theCharacteristic;
    
    NSData *aShortHold;
    NSData *aMediumHold;
    NSData *aLongHold;
}

@property (nonatomic, retain) CBCentralManager *centralManager;
@property (nonatomic, retain) NSMutableArray *peripheralArray;
@property (nonatomic, retain) CBPeripheral *selectedPeripheral;

+ (id)sharedManager;

- (void)scanForPeripherals;
- (void)connectToPeripheral:(CBPeripheral *)aPeripheral;
- (void)findServices;
- (void)sendMessage:(NSString *)aString;

+ (NSData *)dataFromHexString:(NSString *)string;

@end
