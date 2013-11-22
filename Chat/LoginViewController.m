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

@implementation LoginViewController

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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
}

@end
