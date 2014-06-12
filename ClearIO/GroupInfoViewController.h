//
//  GroupInfoViewController.h
//  ClearIO
//
//  Created by Michael on 6/12/14.
//  Copyright (c) 2014 ClearBlade. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupInfoViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSDictionary *userInfo;
@property (nonatomic, strong) NSDictionary *groupInfo;
@property (nonatomic) bool isNewGroup;
@property (nonatomic, strong) NSMutableArray *allUsers;
@property (nonatomic, strong) NSMutableArray *usersInGroup;
@end
