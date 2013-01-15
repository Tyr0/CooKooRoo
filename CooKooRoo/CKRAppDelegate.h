//
//  CKRAppDelegate.h
//  CooKooRoo
//
//  Created by Tyler Calderone on 1/14/13.
//  Copyright (c) 2013 Tyler Calderone. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKRPeripheralTableViewController;

@interface CKRAppDelegate : UIResponder <UIApplicationDelegate> {
    UINavigationController *theNavigationController;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) UINavigationController *theNavigationController;

@end
