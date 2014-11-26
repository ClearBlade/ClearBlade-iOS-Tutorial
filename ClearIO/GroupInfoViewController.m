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
//    self.allUsersTableView.delegate = self;
//    self.allUsersTableView.dataSource = self;
//    self.usersInGroupTableView.delegate = self;
//    self.usersInGroupTableView.dataSource = self;

    self.groupName.text = [self.groupInfo valueForKey:@"name"];

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

- (IBAction)doneClicked:(id)sender {
    if (self.isNewGroup) {
        [self createNewGroup];
    } else {
        [self updateGroup];
    }
}

- (void)createNewGroup {

    
}

- (void)updateGroup {

    CBItem *group = [[[CBItem alloc] init] initWithData:self.groupInfo withCollectionID:CHAT_GROUPS_COLLECTION];
    group.data[@"name"] = self.groupName.text;
    
    [group saveWithSuccessCallback:^(CBItem *item) {
        [self performSegueWithIdentifier:@"newGroupAddedSegue" sender:self];
    }withErrorCallback:^(CBItem *item, NSError *error, id JSON){
        NSLog(@"Error updating group: <%@>", error);
    }];

}

- (IBAction)cancelClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    if([tableView isEqual:self.usersInGroupTableView]){
//        return [self.usersInGroup count];
//    }else if([tableView isEqual:self.allUsersTableView]){
//        return [self.allUsers count];
//    }else {
//        return 0;
//    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
//    if([tableView isEqual:self.usersInGroupTableView]){
//        return @"Users in group";
//    }else{
//        return @"All users";
//    }
        return @"All users";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if([tableView isEqual:@"Users in group"]){
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
        if (![chatController isKindOfClass:[ChatViewController class]]){
            NSLog(@"Unexpected type of view controller");
            return;
        } else {
            chatController.groupInfo = self.groupInfo;
            chatController.userInfo = self.userInfo;
        }
    }
}


@end
