//
//  GroupInfoViewController.m
//  ClearIO
//
//  Created by Michael on 6/12/14.
//  Copyright (c) 2014 ClearBlade. All rights reserved.
//

#import "GroupInfoViewController.h"
#import "CBAPI.h"
#import "ClearIOConstants.h"
#import "ChatViewController.h"

@interface GroupInfoViewController ()
@property (strong, nonatomic) IBOutlet UITableView *usersInGroupTableView;
@property (strong, nonatomic) IBOutlet UITableView *allUsersTableView;
@property (strong, nonatomic) IBOutlet UISwitch *publicSwitch;
@property (strong, nonatomic) IBOutlet UITextField *groupName;
@end

@implementation GroupInfoViewController

@synthesize userInfo = _userInfo;
@synthesize isNewGroup = _isNewGroup;
@synthesize groupInfo = _groupInfo;
@synthesize allUsers = _allUsers;
@synthesize usersInGroup = _usersInGroup;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.]
    self.allUsersTableView.delegate = self;
    self.allUsersTableView.dataSource = self;
    self.usersInGroupTableView.delegate = self;
    self.usersInGroupTableView.dataSource = self;
    if(!self.isNewGroup){
        //get users in group and group name
        [self getUsersInGroup];
        self.groupName.text = [self.userInfo valueForKey:@"name"];
        if ([self.userInfo valueForKey:@"public"]) {
            [self.publicSwitch setOn:YES animated:NO];
        }
    }
    [self getAllUsers];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSMutableArray *)allUsers {
    if(!_allUsers) {
        _allUsers = [NSMutableArray array];
    }
    return _allUsers;
}

-(NSMutableArray *)usersInGroup {
    if(!_usersInGroup) {
        _usersInGroup = [NSMutableArray array];
    }
    return _usersInGroup;
}

- (void)getAllUsers {
    CBCollection *allUsersCol = [CBCollection collectionWithID:CHAT_USERS_COLLECTION];
    [allUsersCol fetchWithSuccessCallback:^(CBQueryResponse *successfulResponse) {
        NSMutableArray *returnedGroups = successfulResponse.dataItems;
        if ([returnedGroups count] > 0){
            [self.allUsers addObjectsFromArray:successfulResponse.dataItems];
            [self.allUsersTableView reloadData];
        }
    } withErrorCallback:^(NSError *error, id JSON) {
        
    }];
}

- (void)getUsersInGroup {
    
}

- (IBAction)doneClicked:(id)sender {
    if (self.isNewGroup) {
        CBQuery *addNewGroupQuery = [CBQuery queryWithCollectionID:CHAT_GROUPS_COLLECTION];
        NSString *public;
        if ([self.publicSwitch isOn]) {
            public = @"true";
        }else{
            public = @"false";
        }
        NSString *users = @"filler";
        CBItem *newItem = [CBItem itemWithData:@{@"groupname":self.groupName.text,@"public":public,@"users":users} withCollectionID:CHAT_GROUPS_COLLECTION];
        /*
        [addNewGroupQuery insertItem:newItem intoCollectionWithID:CHAT_GROUPS_COLLECTION withSuccessCallback:^(NSMutableArray *items) {
            NSDictionary *newGroupInfo = @{@"group_id":[[items objectAtIndex:0] itemID]};
            self.groupInfo = newGroupInfo;
            [self performSegueWithIdentifier:@"newGroupAddedSegue" sender:self];
        } withErrorCallback:^(NSError *error, id JSON) {
            
        }];
        */
        [newItem saveWithSuccessCallback:^(CBItem *item) {
            NSDictionary *newGroupInfo = @{@"group_id":item.itemID};
            self.groupInfo = newGroupInfo;
            [self performSegueWithIdentifier:@"newGroupAddedSegue" sender:self];
        } withErrorCallback:^(CBItem *item, NSError *error, id JSON) {
            
        }];
         
        
    } else {
        
    }
}

- (IBAction)cancelClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if([tableView isEqual:self.usersInGroupTableView]){
        return [self.usersInGroup count];
    }else if([tableView isEqual:self.allUsersTableView]){
        return [self.allUsers count];
    }else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if([tableView isEqual:self.usersInGroupTableView]){
        static NSString *CellIdentifier = @"userInGroup";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
        NSString *firstName = [[[self.usersInGroup objectAtIndex:indexPath.row] data]valueForKey:@"first_name"];
        NSString *lastName = [[[self.usersInGroup objectAtIndex:indexPath.row] data]valueForKey:@"last_name"];
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@",firstName,lastName];
        
        return cell;

    }else{
        static NSString *CellIdentifier = @"allUsers";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
        NSString *firstName = [[[self.allUsers objectAtIndex:indexPath.row] data]valueForKey:@"first_name"];
        NSString *lastName = [[[self.allUsers objectAtIndex:indexPath.row] data]valueForKey:@"last_name"];
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@",firstName,lastName];
        
        return cell;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [self flipCellAccessory:cell];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [self flipCellAccessory:cell];
}

- (void)flipCellAccessory:(UITableViewCell *)cell {
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark){
        cell.accessoryType = UITableViewCellAccessoryNone;
    }else{
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"newGroupAddedSegue"]){
        ChatViewController *chatController = (ChatViewController *)segue.destinationViewController;
        NSString *group_id = [self.groupInfo valueForKey:@"group_id"];
        if (![chatController isKindOfClass:[ChatViewController class]]){
            NSLog(@"Unexpected type of view controller");
            return;
        } else {
            chatController.group = (NSString *)group_id;
            chatController.userInfo = self.userInfo;
        }
    }
}


@end
