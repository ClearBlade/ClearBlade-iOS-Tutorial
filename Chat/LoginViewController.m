//
//  LoginViewController.m
//  Chat
//
//  Created by Charlie Andrews on 11/5/13.
//  Copyright (c) 2013 example. All rights reserved.
//

#import "LoginViewController.h"
#import "GroupListViewController.h"
#import <CBAPI.h>

@interface LoginViewController ()
@property (strong, nonatomic) CBCollection *userCol;
@end

@implementation LoginViewController

@synthesize userNameField = _userNameField;
@synthesize errorMessage = _errorMessage;
@synthesize userCol = _userCol;

-(CBCollection *)userCol {
    if (!_userCol) {
#warning Replace with your own user collection
        _userCol = [CBCollection collectionWithID:@"90cad0aa0ac8d8bf89ff8afea432"];
    }
    return _userCol;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
}

-(void)checkUser:(NSString *) userString {
    //Sets up the query to be on the same collection as userCol
    CBQuery *userQuery = [CBQuery queryWithCollectionID:[self.userCol collectionID]];
    [userQuery equalTo:userString for:@"username"]; //Adds the query parameter that username must be equal to the userString
    //Searches for all users with the same username
    [userQuery fetchWithSuccessCallback:^(NSMutableArray *foundUsers) {
        //If foundUsers count is zero, means no one else has logged in with that username before
        if (foundUsers.count == 0) {
            [self.userCol createWithData:@{@"username": userString} withSuccessCallback:^(CBItem *newUser) {
                NSLog(@"new user created");
            } withErrorCallback:^(CBItem * item, NSError *err, id ret) {
                NSLog(@"ERROR: %@: %@", err, ret);
            }];
        }  else {
            //foundUsers is greater than zero so someone has logged in with this username at least once.
            self.errorMessage.text = @"Welcome Back!";
        }
        [self performSegueWithIdentifier:@"loginSegue" sender:self];
    } withErrorCallback:^(NSError *error, id JSON) {
        NSLog(@"ERROR: %@: %@", error, JSON);
    }];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *username = self.userNameField.text;
    GroupListViewController *groupView = (GroupListViewController *)segue.destinationViewController;
    groupView.username = username;
}
-(IBAction)loginClicked:(id)sender {
    if ([self.userNameField.text length] == 0) {
        self.errorMessage.text = @"No username was entered";
    } else {
        [self checkUser:self.userNameField.text];
    }
}

@end
