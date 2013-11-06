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

@end

@implementation GroupListViewController

@synthesize groups;
@synthesize username;

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

    self.groups = [[NSMutableArray alloc] init];
    //Add logic here to get all the group names and add them to the groups list
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
    return [self.groups count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"GroupCell";
    NSString *group = [self.groups objectAtIndex:indexPath.row];
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
