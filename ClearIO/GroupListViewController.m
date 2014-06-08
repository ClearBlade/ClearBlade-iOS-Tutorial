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
#import "CBChatConstants.h"

@interface GroupListViewController ()
@property (strong, nonatomic) CBCollection *groupCol;
@end

@implementation GroupListViewController

@synthesize groups = _groups;
@synthesize username = _username;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self getAllGroups];
    //Add logic here to get all the group names and add them to the groups list
}

-(void) getAllGroups {
    [self.groupCol fetchWithSuccessCallback:^(CBQueryResponse *successfulResponse) {
        NSMutableArray *returnedGroups = successfulResponse.dataItems;
        for (CBItem * group in returnedGroups) {
            [self.groups addObject:[group objectForKey:CHAT_GROUP_NAME_FIELD]];
        }
        [self.tableView reloadData];
    } withErrorCallback:^(NSError *err, id ret) {
        NSLog(@"Error getting groups: %@: %@", err, ret);
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (NSInteger)[self.groups count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"GroupCell";
    NSString *group = [self.groups objectAtIndex:(NSUInteger)indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.textLabel.text = group;
    return cell;
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    ChatViewController *chatController = (ChatViewController *)segue.destinationViewController;
    UITableViewCell *senderCell = (UITableViewCell * )sender;
    NSString *group = senderCell.textLabel.text;
    if (![chatController isKindOfClass:[ChatViewController class]]){
        NSLog(@"Unexpected type of view controller");
        return;
    } else {
        chatController.group = (NSString *)group;
        chatController.username = self.username;
    }
}

@end
