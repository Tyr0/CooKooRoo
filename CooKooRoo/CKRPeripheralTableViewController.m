//
//  CKRPeripheralTableViewController.m
//  CooKooRoo
//
//  Created by Tyler Calderone on 1/14/13.
//  Copyright (c) 2013 Tyler Calderone. All rights reserved.
//

#import "CKRPeripheralTableViewController.h"
#import "MBProgressHUD.h"
#import "CKRBluetoothManager.h"
#import "CKRActionTableViewController.h"

@implementation CKRPeripheralTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.title = @"Peripherals";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(peripheralFound:) name:@"CKRPeripheralFoundNotification" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(peripheralConnected:) name:@"CKRPeripheralConnectedNotification" object:nil];
        [[CKRBluetoothManager sharedManager] scanForPeripherals];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
    });
}

- (void)viewWillDisappear:(BOOL)animated {
    [[CKRBluetoothManager sharedManager] stopScan];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)peripheralFound:(id)sender {
    [self.tableView reloadData];
}

- (void)peripheralConnected:(id)sender {
    CKRActionTableViewController *aActionTableViewController = [[CKRActionTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [self.navigationController pushViewController:aActionTableViewController animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[CKRBluetoothManager sharedManager] peripheralArray] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"PeripheralCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }

    CBPeripheral *aPeripheral = (CBPeripheral *)[[[CKRBluetoothManager sharedManager] peripheralArray] objectAtIndex:indexPath.row];
    cell.textLabel.text = aPeripheral.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", aPeripheral.UUID];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [[CKRBluetoothManager sharedManager] connectToPeripheral:(CBPeripheral *)[[[CKRBluetoothManager sharedManager] peripheralArray] objectAtIndex:indexPath.row]];
    
}

@end
