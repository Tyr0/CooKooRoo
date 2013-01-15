//
//  CKRBluetoothManager.m
//  CooKooRoo
//
//  Created by Tyler Calderone on 1/14/13.
//  Copyright (c) 2013 Tyler Calderone. All rights reserved.
//

#import "CKRBluetoothManager.h"

static CKRBluetoothManager *theSharedManager = nil;

@implementation CKRBluetoothManager

@synthesize centralManager = theCentralManager;
@synthesize peripheralArray = thePeripheralArray;
@synthesize selectedPeripheral = thePeripheral;

- (id)init {
    if (self = [super init]) {
        theCentralManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
        thePeripheralArray = [[NSMutableArray alloc] init];
        aShortHold = [CKRBluetoothManager dataFromHexString:@"c001000000000000000000000000000000000000"];
        aMediumHold = [CKRBluetoothManager dataFromHexString:@"c002000000000000000000000000000000000000"];
        aLongHold = [CKRBluetoothManager dataFromHexString:@"c003000000000000000000000000000000000000"];
    }
    return self;
}

- (void)scanForPeripherals {
    NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:CBCentralManagerScanOptionAllowDuplicatesKey];
    [theCentralManager scanForPeripheralsWithServices:nil options:options];
}

- (void)stopScan {
    NSLog(@"%s", __FUNCTION__);
    [theCentralManager stopScan];
}

- (void)connectToPeripheral:(CBPeripheral *)aPeripheral {
    [self setSelectedPeripheral:aPeripheral];
    [aPeripheral setDelegate:self];
    [theCentralManager connectPeripheral:aPeripheral options:nil];
}

- (void)findServices {
    NSLog(@"FINDING SERVICES");
    [thePeripheral discoverServices:nil];
}

- (void)sendMessage:(NSString *)aString {
    if (!theCentralManager) {
        NSLog(@"NO CENTRAL MANAGER FOUND");
        return;
    }
    if (!thePeripheral) {
        NSLog(@"NO PERIPHERAL FOUND");
        return;
    }
    if (!theCharacteristic) {
        NSLog(@"NO CHARACTERISTIC FOUND");
        return;
    }
    
    NSData *aData = [CKRBluetoothManager dataFromHexString:aString];
    
    [thePeripheral writeValue:aData forCharacteristic:theCharacteristic type:1];
    NSLog(@"MESSAGE %@ SENT: %@", aString, [aData description]);
}

+ (NSData *)dataFromHexString:(NSString *)string {
    string = [string lowercaseString];
    NSMutableData *data= [NSMutableData new];
    unsigned char whole_byte;
    char byte_chars[3] = {'\0','\0','\0'};
    int i = 0;
    int length = string.length;
    while (i < length-1) {
        char c = [string characterAtIndex:i++];
        if (c < '0' || (c > '9' && c < 'a') || c > 'f')
            continue;
        byte_chars[0] = c;
        byte_chars[1] = [string characterAtIndex:i++];
        whole_byte = strtol(byte_chars, NULL, 16);
        [data appendBytes:&whole_byte length:1];
        
    }
    
    return data;
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSLog(@"%s", __FUNCTION__);
}

#pragma mark - CBCentralManger Methods
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    NSLog(@"%s %d", __FUNCTION__, central.state);
    
    switch ([central state]) {
        case CBCentralManagerStateResetting:
            NSLog(@"CENTRAL MANAGER RESETTING");
            break;
        case CBCentralManagerStateUnsupported:
            NSLog(@"CENTRAL MANAGER UNSUPPORTED");
            break;
        case CBCentralManagerStateUnauthorized:
            NSLog(@"CENTRAL MANAGER UNAUTHORIZED");
            break;
        case CBCentralManagerStatePoweredOff:
            NSLog(@"CENTRAL MANAGER POWERED OFF");
            break;
        case CBCentralManagerStatePoweredOn:
            NSLog(@"CENTRAL MANAGER POWERED ON");
            break;
        case CBCentralManagerStateUnknown:
        default:
            NSLog(@"STATE UNKNOWN");
            break;
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    if (![thePeripheralArray containsObject:peripheral]) {
        [thePeripheralArray addObject:[peripheral retain]];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CKRPeripheralFoundNotification" object:nil];
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CKRPeripheralConnectedNotification" object:nil];
}

#pragma mark - CBPeripheral Methods
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    NSLog(@"%s %@", __FUNCTION__, error);
    for (CBService *aService in peripheral.services) {
        [peripheral discoverCharacteristics:nil forService:aService];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    NSLog(@"%s", __FUNCTION__);
    CBCharacteristic *characteristic;
    
    for (characteristic in [service characteristics]) {
        if ([[characteristic UUID] isEqual:[CBUUID UUIDWithString:@"4b455254-7472-11e1-a575-0002a5d54001"]]) {
            theCharacteristic = characteristic;
            // listen for notifications from the device (holding command button)
            [thePeripheral setNotifyValue:YES forCharacteristic:theCharacteristic];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"CKRCharacteristicFoundNotification" object:nil];
        }
    }
}

// user sent command
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSLog(@"%s %@", __FUNCTION__, characteristic.value);
    
    /*
     short/tap - c0010000 00000000 00000000 00000000 00000000
     medium - c0020000 00000000 00000000 00000000 00000000
     long - c0030000 00000000 00000000 00000000 00000000
     */
    NSData *aData = characteristic.value;
    NSString *aString;
    if ([aData isEqualToData:aShortHold]) {
        aString = @"short";
    }
    else if ([aData isEqualToData:aMediumHold]) {
        aString = @"medium";
    }
    else if ([aData isEqualToData:aLongHold]) {
        aString = @"long";
    }
    else {
        aString = @"unknown";
    }
    
    UIAlertView *aAlertView = [[UIAlertView alloc] initWithTitle:@"Command Recieved" message:[NSString stringWithFormat:@"You held the button for a %@ amount of time", aString] delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    [aAlertView show];
    [aAlertView release];
}

#pragma mark - Singleton Methods
+ (id)sharedManager {
    @synchronized(self) {
        if (theSharedManager == nil) {
            theSharedManager = [[super allocWithZone:NULL] init];
        }
    }
    
    return theSharedManager;
}

+ (id)allocWithZone:(NSZone *)zone {
    return [[self sharedManager] retain];
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id)retain {
    return self;
}

- (unsigned)retainCount {
    return UINT_MAX; //denotes an object that cannot be released
}

- (oneway void)release {
    // never release
}

- (id)autorelease {
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
    [super dealloc];
}

@end
