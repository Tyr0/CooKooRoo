//
//  CKRPeripheralTableViewController.h
//  CooKooRoo
//
//  Created by Tyler Calderone on 1/14/13.
//  Copyright (c) 2013 Tyler Calderone. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MBProgressHUD;
@class CKRBluetoothManager;
@class CKRActionTableViewController;

@interface CKRPeripheralTableViewController : UITableViewController {

}

- (void)peripheralFound:(id)sender;
- (void)peripheralConnected:(id)sender;

@end
