//
//  GroupListViewController.m
//  Chat
//
//  Created by Charlie Andrews on 11/5/13.
//  Copyright (c) 2013 example. All rights reserved.
//

#import "GroupListViewController.h"
#import "ChatViewController.h"
#import "ClearIOConstants.h"
#import "GroupInfoViewController.h"
#import "ClearIO.h"

@interface GroupListViewController ()
@property (strong, nonatomic) CBCollection *groupCol;
@property NSIndexPath *selectedIndexPath;
@end

@implementation GroupListViewController

@synthesize groups = _groups;
@synthesize userInfo = _userInfo;
@synthesize groupInfo = _groupInfo;

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addGroupPressed:)];
    self.navigationItem.rightBarButtonItem = addButton;
    
}

- (void)viewWillAppear:(BOOL)animated{
    if (sizeof self.groups != 0){
        [self.groups removeAllObjects];
    }
    [self getGroups];
}

-(void) getGroups {
    [[ClearIO settings] ioGetGroupsWithSuccessCallback:^(NSArray *groups) {
        NSDictionary *dict = [NSDictionary dictionaryWithObject:groups forKey:@"data"];
        [self.groups addObject:dict];
        [self.tableView reloadData];
    } withErrorCallback:^(NSError *error) {
        NSLog(@"error getting public groups");
    }];
}

-(CBCollection *)groupCol {
    if(!_groupCol) {
        _groupCol = [CBCollection collectionWithID:CHAT_GROUPS_COLLECTION];
    }
    return _groupCol;
}
-(NSMutableArray *)groups {
    if(!_groups) {
        _groups = [NSMutableArray array];
    }
    return _groups;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Groups";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.groups count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDictionary *dictionary =[self.groups objectAtIndex:section];
    NSArray *array = [dictionary objectForKey:@"data"];
    return [array count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"GroupCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    NSDictionary *dictionary = [self.groups objectAtIndex:indexPath.section];

    NSArray *array = [dictionary objectForKey:@"data"];
    CBItem *group = [array objectAtIndex:indexPath.row];

    NSString *cellValue = [group.data  valueForKey:@"name"];

    cell.textLabel.text = cellValue;
    
    return cell;
}

- (IBAction)logoutClicked:(id)sender {
    NSError * error;
    [[ClearIO settings] ioLogoutWithError:&error];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedIndexPath = indexPath;
    [self performSegueWithIdentifier:@"chatSegue" sender:self];
}

- (void)addGroupPressed:(UIButton*)sender {
    [self performSegueWithIdentifier:@"newGroupSegue" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"chatSegue"]) {
        ChatViewController *chatController = (ChatViewController *)segue.destinationViewController;
        NSDictionary *dictionary = [self.groups objectAtIndex:[self.selectedIndexPath indexAtPosition:0]];

        NSArray *array = [dictionary objectForKey:@"data"];
        CBItem *group = [array objectAtIndex:[self.selectedIndexPath indexAtPosition:1]];
        NSMutableDictionary *grpInfo = group.data;

        if ([self.selectedIndexPath indexAtPosition:0] == 0){
            [grpInfo setObject:[NSNumber numberWithBool:true] forKey:@"is_public"];
        }else{
            [grpInfo setObject:[NSNumber numberWithBool:false] forKey:@"is_public"];
        }
        self.groupInfo = [grpInfo copy];
        if (![chatController isKindOfClass:[ChatViewController class]]){
            NSLog(@"Unexpected type of view controller");
            return;
        } else {
            chatController.groupInfo = self.groupInfo;
            chatController.userInfo = self.userInfo;
        }
    }else if ([segue.identifier isEqualToString:@"newGroupSegue"]){
        GroupInfoViewController *groupInfoController = (GroupInfoViewController *)segue.destinationViewController;
        if(![groupInfoController isKindOfClass:[GroupInfoViewController class]]){
            NSLog(@"Unexpected type of view controller");
            return;
        } else {
            groupInfoController.userInfo = self.userInfo;
            groupInfoController.isNewGroup = true;
        }
    }
    
}

@end
