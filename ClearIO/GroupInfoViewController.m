//
//  GroupInfoViewController.m
//  ClearIO
//
//  Created by Michael on 6/12/14.
//  Copyright (c) 2014 ClearBlade. All rights reserved.
//

#import "GroupInfoViewController.h"
#import "ClearIOConstants.h"
#import "ChatViewController.h"
#import "ClearIO.h"

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

    self.groupName.text = [self.groupInfo valueForKey:@"group_name"];

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
    CBCollection *allUsersCol = [CBCollection collectionWithID:CHAT_USER_COLLECTION];
    [allUsersCol fetchWithSuccessCallback:^(CBQueryResponse *successfulResponse) {
        NSMutableArray *returnedGroups = successfulResponse.dataItems;
        if ([returnedGroups count] > 0){
            [self.allUsers addObjectsFromArray:successfulResponse.dataItems];
            [self.allUsersTableView reloadData];
            if (![[self.groupInfo valueForKey:@"is_public"] boolValue]){
               [self getUsersInGroup];
            }
        }
    } withErrorCallback:^(NSError *error, id JSON) {
        
    }];
}

- (void)getUsersInGroup {
    //pull users from self.groupInfo
    NSArray *userEmails = [self.groupInfo valueForKey:@"users"];
    NSMutableArray *usersInGroup = [[NSMutableArray alloc] init];
    //has to be a better way to do this.. but for now we need to populate self.usersInGroup with email/fname/lname using the array of emails in usersEmails
    //nested loop first loop through userEMails, then allUsers, and if emails match, push a NSDictionary with email/fname/lname to usersInGroup
    for (id email in userEmails){
        for(id user in self.allUsers){
            if ([email isEqualToString:[[user data] valueForKey:@"email"]]){
                [usersInGroup addObject:user];
            }
        }
    }
    
    [self.usersInGroup addObjectsFromArray:usersInGroup];
    [self.usersInGroupTableView reloadData];
}

- (IBAction)doneClicked:(id)sender {
    if (self.isNewGroup) {
        [self createNewGroup];
    } else {
        [self updateGroup];
    }
}

- (void)createNewGroup {

    NSMutableDictionary *newGroupInfo = [[NSMutableDictionary alloc] init];
    newGroupInfo[@"name"] = self.groupName.text;
    newGroupInfo[@"topic"] = @"defaultTopic";
    newGroupInfo[@"collectionID"] = CHAT_GROUPS_COLLECTION;
    [CBCode executeFunction:@"ioCreateGroup" withParams:@{@"group":newGroupInfo} withSuccessCallback:^(NSString *result) {

        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
        NSDictionary *serverResponse = [json objectForKey: @"results"];
        
        if (![serverResponse[@"code"] isEqual:@200]) {
            if([serverResponse[@"code"] isEqual:@409]) {
                // open an alert that lets users know that the group already exists
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"UIAlertView"
                                                                message:@"Group already exists" delegate:self cancelButtonTitle:@"Cancel"
                                                      otherButtonTitles:@"OK", nil];
                [alert show];
            } else {
                CBLogError(@"Error creating group: <%@>", serverResponse[@"message"]);
            }
        } else {
            self.groupInfo = serverResponse[@"message"];
            [self performSegueWithIdentifier:@"newGroupAddedSegue" sender:self];
        }

    } withErrorCallback:^(NSError *error) {
        CBLogError(@"Error creating group: <%@>", error);
    }];
    
}

- (void)updateGroup {
    bool newPublic;
    NSMutableArray *usersToAdd = [[NSMutableArray alloc] init];
    NSMutableArray *usersToRemove = [[NSMutableArray alloc] init];
    if ([self.publicSwitch isOn]) {
        newPublic = true;
        usersToAdd = nil;
        usersToRemove = nil;
    }else {
        newPublic = false;
        NSInteger count = 0;
        for (UITableViewCell *cell in [self.allUsersTableView visibleCells]){
            if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
                [usersToAdd addObject:[[[self.allUsers objectAtIndex:count] data] valueForKey:@"email"]];
            }
            count++;
        }
        count = 0;
        for (UITableViewCell *cell in [self.usersInGroupTableView visibleCells]){
            if (cell.accessoryType == UITableViewCellAccessoryNone) {
                [usersToRemove addObject:[[[self.usersInGroup objectAtIndex:count] data] valueForKey:@"email"]];
            }
            count++;
        }
    }
    [[ClearIO settings] ioUpdateGroup:[self.groupInfo valueForKey:@"item_id"] withNewName:self.groupName.text withOldIsPublic:[self.groupInfo valueForKey:@"is_public"] withNewIsPublic:newPublic withAddedUsers:usersToAdd withRemovedUsers:usersToRemove withSuccessCallback:^(NSDictionary *newGroupInfo) {
        self.groupInfo = newGroupInfo;
        [self performSegueWithIdentifier:@"newGroupAddedSegue" sender:self];
    } withErrorCallback:^(NSError *error) {
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
    if([tableView isEqual:self.usersInGroupTableView]){
        return [self.usersInGroup count];
    }else if([tableView isEqual:self.allUsersTableView]){
        return [self.allUsers count];
    }else {
        return 0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if([tableView isEqual:self.usersInGroupTableView]){
        return @"Users in group";
    }else{
        return @"All users";
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
