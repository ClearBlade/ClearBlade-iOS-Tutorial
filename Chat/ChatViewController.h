//
//  ChatViewController.h
//  Chat
//
//  Created by Charlie Andrews on 11/5/13.
//  Copyright (c) 2013 example. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CBMessageClient.h>
#define PLATFORM_URL @"tcp://platform.clearblade.com:1883"

@interface ChatViewController : UIViewController

@property (nonatomic, strong) NSString *group;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UIView *bottomBar;
@property (nonatomic, strong) IBOutlet UITextField *messageField;
@property (strong, nonatomic) NSMutableArray * messages;

@end
