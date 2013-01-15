//
//  CKRActionTableViewController.m
//  CooKooRoo
//
//  Created by Tyler Calderone on 1/14/13.
//  Copyright (c) 2013 Tyler Calderone. All rights reserved.
//

#import "CKRActionTableViewController.h"
#import "CKRBluetoothManager.h"
#import "MBProgressHUD.h"

@implementation CKRActionTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        theActionDictionary = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"CooKooCommands" ofType:@"plist"]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(characteristicFound:) name:@"CKRCharacteristicFoundNotification" object:nil];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[CKRBluetoothManager sharedManager] findServices];
}

- (void)characteristicFound:(id)sender {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)switchAction:(id)sender {
    UISwitch *aSwitch = (UISwitch *)sender;
    NSString *aString = [aSwitch isOn] ? @"On" : @"Off";
    NSDictionary *aDict = [theActionDictionary objectForKey:[[theActionDictionary allKeys] objectAtIndex:aSwitch.tag]];
    NSString *aCode = [aDict objectForKey:aString];
    
    [[CKRBluetoothManager sharedManager] sendMessage:aCode];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [theActionDictionary count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = [[theActionDictionary allKeys] objectAtIndex:indexPath.row];
    
    UISwitch *aSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(220, 10, 0, 0)];
    aSwitch.tag = indexPath.row;
    [aSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    [cell addSubview:aSwitch];
    [aSwitch release];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

@end
