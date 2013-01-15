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

- (void)switchAction:(UISwitch *)aSwitch {
    NSString *aString = [aSwitch isOn] ? @"On" : @"Off";
    NSDictionary *aDict = [theActionDictionary objectForKey:[[theActionDictionary allKeys] objectAtIndex:aSwitch.tag]];
    NSString *aCode = [aDict objectForKey:aString];
    
    [[CKRBluetoothManager sharedManager] sendMessage:aCode];
}

- (void)segmentAction:(UISegmentedControl *)aSegment {
    switch (aSegment.selectedSegmentIndex) {
        case 0:
            [[CKRBluetoothManager sharedManager] sendMessage:@"200A"];
            break;
        case 1:
            [[CKRBluetoothManager sharedManager] sendMessage:@"2014"];
            break;
        case 2:
            [[CKRBluetoothManager sharedManager] sendMessage:@"2063"];
            break;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return [theActionDictionary count];
        case 1:
            return 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    switch (indexPath.section) {
        case 0: {
            cell.textLabel.text = [[theActionDictionary allKeys] objectAtIndex:indexPath.row];
            
            UISwitch *aSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(220, 10, 0, 0)];
            aSwitch.tag = indexPath.row;
            [aSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
            [cell addSubview:aSwitch];
            [aSwitch release];
            break;
        }
        case 1: {
            UISegmentedControl *aSegment = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects: @"10%", @"20%", @"None", nil]];
            aSegment.frame =  CGRectMake(145, 5, 150, 35);
            aSegment.selectedSegmentIndex = 2;
            [aSegment addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
            aSegment.segmentedControlStyle = UISegmentedControlStyleBar;
            
            [cell addSubview:aSegment];
            cell.textLabel.text = @"Battery";
            [aSegment release];
            break;
        }
    }

    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

@end
