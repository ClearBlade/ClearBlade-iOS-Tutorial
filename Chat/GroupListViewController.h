//
//  GroupListViewController.h
//  Chat
//
//  Created by Charlie Andrews on 11/5/13.
//  Copyright (c) 2013 example. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupListViewController : UITableViewController

@property (nonatomic, strong) NSMutableArray *groups;
@property (nonatomic, strong) NSString *username;

@end
