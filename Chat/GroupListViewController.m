//
//  GroupListViewController.m
//  Chat
//
//  Created by Charlie Andrews on 11/5/13.
//  Copyright (c) 2013 example. All rights reserved.
//

#import "GroupListViewController.h"
#import "ChatViewController.h"

@interface GroupListViewController ()
@property (strong, nonatomic) CBCollection *groupCol;
@end

@implementation GroupListViewController

@synthesize groups = _groups;
@synthesize username = _username;
@synthesize groupCol = _groupCol;

-(void) getAllGroups {
    [self.groupCol fetchWithSuccessCallback:^(NSMutableArray *returnedGroups) {
        for (CBItem * group in returnedGroups) {
            [self.groups addObject:[group objectForKey:@"groupname"]];
        }
        [self.tableView reloadData];
    } withErrorCallback:^(NSError *err, id ret) {
        NSLog(@"ERROR: %@: %@", err, ret);
    }];
}
-(CBCollection *)groupCol {
    if (!_groupCol) {
#warning Replace with your own collection id for groups
        _groupCol = [CBCollection collectionWithID:@"98cad0aa0ae8f3e4f888bcdeb29701"];
    }
    return _groupCol;
}
-(NSMutableArray *)groups {
    if (!_groups) {
        _groups = [NSMutableArray array];
    }
    return _groups;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self getAllGroups];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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
