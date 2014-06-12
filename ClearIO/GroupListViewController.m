//
//  GroupListViewController.m
//  Chat
//
//  Created by Charlie Andrews on 11/5/13.
//  Copyright (c) 2013 example. All rights reserved.
//

#import "GroupListViewController.h"
#import "ChatViewController.h"
#import "CBAPI.h"
#import "ClearIOConstants.h"
#import "AppDelegate.h"
#import "LoginViewController.h"
#import "GroupInfoViewController.h"

@interface GroupListViewController ()
@property (strong, nonatomic) CBCollection *groupCol;
@property NSIndexPath *selectedIndexPath;
@end

@implementation GroupListViewController

@synthesize groups = _groups;
@synthesize userInfo = _userInfo;

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addGroupPressed:)];
    self.navigationItem.rightBarButtonItem = addButton;
    [self getPublicGroups];
}

-(void) getPublicGroups {
    
    CBQuery *publicGroupsQuery = [CBQuery queryWithCollectionID:[self.groupCol collectionID]];
    [publicGroupsQuery equalTo:@"true" for:@"public"];
    [publicGroupsQuery fetchWithSuccessCallback:^(CBQueryResponse *successfulResponse) {
        NSMutableArray *returnedGroups = successfulResponse.dataItems;
        if ([returnedGroups count] > 0){
            NSDictionary *dict = [NSDictionary dictionaryWithObject:returnedGroups forKey:@"data"];
            [self.groups addObject:dict];
            [self getPrivateGroups];
        }
    } withErrorCallback:^(NSError *error, id JSON) {
        
    }];
    //temp removed until code handles getting user info of who called function
     /*
    CBCode *code = [[CBCode alloc] init];
    [code executeFunction:@"getPublicGroups" withParams:nil withSuccessCallback:^(NSString *result) {
        NSError *jsonError;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&jsonError];
        NSArray *jsonArray = [json objectForKey:@"results"];
        
        NSDictionary *dict = [NSDictionary dictionaryWithObject:jsonArray forKey:@"data"];
        if(jsonError){
          return;
        }
        [self.groups addObject:dict];
        [self getPrivateGroups];
    } withErrorCallback:^(NSError *error) {
        
    }];
      */
}

-(void) getPrivateGroups {
    
    CBQuery *privateGroupsQuery = [CBQuery queryWithCollectionID:[self.groupCol collectionID]];
    [privateGroupsQuery equalTo:@"false" for:@"public"];
    [privateGroupsQuery fetchWithSuccessCallback:^(CBQueryResponse *successfulResponse) {
        NSMutableArray *returnedGroups = successfulResponse.dataItems;
        if ([returnedGroups count] > 0){
            NSDictionary *dict = [NSDictionary dictionaryWithObject:returnedGroups forKey:@"data"];
            [self.groups addObject:dict];
            [[self tableView] reloadData];
        }
    } withErrorCallback:^(NSError *error, id JSON) {
        
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
    
    if(section == 0){
        return @"Public Groups";
    }
    if(section == 1){
        return @"Private Groups";
    }
    else {
        return @"Other Groups";
    }
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
    //NSString *cellValue = [[array objectAtIndex:indexPath.row] valueForKey:@"name"];
    NSString *cellValue = [[[array objectAtIndex:indexPath.row] data] valueForKey:@"groupname"];
    cell.textLabel.text = cellValue;
    
    return cell;
}

- (IBAction)logoutClicked:(id)sender {
    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    NSError * error;
    [appDelegate logoutClearBladePlatformWithError:&error];
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
        NSString *group_id = [[[array objectAtIndex:[self.selectedIndexPath indexAtPosition:1]] data]valueForKey:@"item_id"];
        if (![chatController isKindOfClass:[ChatViewController class]]){
            NSLog(@"Unexpected type of view controller");
            return;
        } else {
            chatController.group = (NSString *)group_id;
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
