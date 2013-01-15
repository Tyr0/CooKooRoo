//
//  CKRActionTableViewController.h
//  CooKooRoo
//
//  Created by Tyler Calderone on 1/14/13.
//  Copyright (c) 2013 Tyler Calderone. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKRBluetoothManager;
@class CBPeripheral;
@class MBProgressHUD;

@interface CKRActionTableViewController : UITableViewController {
    NSDictionary *theActionDictionary;
    CBPeripheral *thePeripheral;
}

@end
