//
//  ChatViewController.h
//  Chat
//
//  Created by Charlie Andrews on 11/5/13.
//  Copyright (c) 2013 example. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatViewController : UIViewController

@property (nonatomic, strong) NSDictionary *groupInfo;
@property (nonatomic, strong) NSDictionary *userInfo;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UIView *bottomBar;
@property (nonatomic, strong) IBOutlet UITextField *messageField;
@property (strong, nonatomic) NSMutableArray * messages;

@end
