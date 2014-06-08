//
//  LoginViewController.m
//  Chat
//
//  Created by Charlie Andrews on 11/5/13.
//  Copyright (c) 2013 example. All rights reserved.
//

#import "LoginViewController.h"
#import "GroupListViewController.h"
#import "CBAPI.h"
#import "CBChatConstants.h"

@interface LoginViewController ()
@property (strong, nonatomic) CBCollection *userCol;
@end

@implementation LoginViewController

@synthesize userNameField = _userNameField;
@synthesize errorMessage = _errorMessage;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

-(CBCollection *)userCol {
    if(!_userCol) {
        _userCol = [CBCollection collectionWithID:CHAT_USERS_COLLECTION];
    }
    return _userCol;
}

-(void) checkUser: (NSString *) userString {
    CBQuery *userQuery = [CBQuery queryWithCollectionID:[self.userCol collectionID]];
    [userQuery equalTo:userString for:CHAT_USER_FIELD];
    [userQuery fetchWithSuccessCallback:^(CBQueryResponse *successfulResponse) {
        NSMutableArray *foundUsers = successfulResponse.dataItems;
        if (foundUsers.count == 0) {
            [self.userCol createWithData:@{CHAT_USER_FIELD: userString} withSuccessCallback:^(CBItem *newUser) {
                NSLog(@"new user created");
                [self performSegueWithIdentifier:@"loginSegue" sender:self];
            } withErrorCallback:^(CBItem * item, NSError *err, id ret) {
                NSLog(@"ERROR creating new user: %@: %@", err, ret);
            }];
        }else {
            self.errorMessage.text = @"Welcome Back!";
            [self performSegueWithIdentifier:@"loginSegue" sender:self];
        }
    }withErrorCallback:^(NSError *error, id JSON) {
        NSLog(@"Error verifying username: %@: %@", error, JSON);
    }];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *username = self.userNameField.text;
    GroupListViewController *groupView = (GroupListViewController *)segue.destinationViewController;
    if ([self.userNameField.text length] == 0) {
        self.errorMessage.text = @"No username was entered";
        return;
    } else {
        groupView.username = username;
    }
}
- (IBAction)loginClicked:(id)sender {
    NSString *username = self.userNameField.text;
    if([username length] == 0) {
        self.errorMessage.text = @"No username was entered";
        return;
    } else {
        [self checkUser:username];
    }
}

@end
