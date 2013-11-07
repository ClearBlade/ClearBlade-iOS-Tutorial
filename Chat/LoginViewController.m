//
//  LoginViewController.m
//  Chat
//
//  Created by Charlie Andrews on 11/5/13.
//  Copyright (c) 2013 example. All rights reserved.
//

#import "LoginViewController.h"
#import "GroupListViewController.h"


@interface LoginViewController ()

@end

@implementation LoginViewController {
    CBCollection *userCol;
}

@synthesize userNameField;
@synthesize errorMessage;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
#warning If you want to user your own version of the users collection make sure that you replace the following collectionID with your own. Also replace the appKey and appSecret in AppDelegate.m with yours.
	userCol = [[CBCollection alloc] initWithCollectionID:@"5277bd878ab3a37ce7f6f062"];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) checkUser: (NSString *) userString {
    CBQuery *userQuery = [[CBQuery alloc] initWithCollectionID:[userCol collectionID]];
    [userQuery equalTo:userString for:@"username"];
    [userQuery fetchWithSuccessCallback:^(NSMutableArray *stuff) {
        if ([stuff count] == 0) {
            NSMutableDictionary *newUser = [[NSMutableDictionary alloc] init];
            [newUser setObject:userString forKey:@"username"];
            [userCol createWithData:newUser WithSuccessCallback:^(CBItem *newUser) {
                NSLog(@"new user created");
            } ErrorCallback:^(NSError *err, id ret) {
                NSLog(@"ERROR: %@: %@", err, ret);
            }];
        } else {
            errorMessage.text = @"Welcome Back!";
        }
    } ErrorCallback:^(NSError *error, id returned) {
        NSLog(@"ERROR: %@: %@", error, returned);
    }];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *username = self.userNameField.text;
    GroupListViewController *groupView = (GroupListViewController *)segue.destinationViewController;
    if ([self.userNameField.text length] == 0) {
        self.errorMessage.text = @"No username was entered";
        return;
    } else {
        [self checkUser:username];
        groupView.username = username;
    }
}

@end
