//
//  LoginViewController.m
//  Chat
//
//  Created by Charlie Andrews on 11/5/13.
//  Copyright (c) 2013 example. All rights reserved.
//

#import "LoginViewController.h"
#import "AppDelegate.h"
#import "GroupListViewController.h"
#import "RegisterViewController.h"
#import "CBAPI.h"
#import "ClearIOConstants.h"

@interface LoginViewController ()
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) CBCollection *userCol;
@property UITextField *activeField;
@end

@implementation LoginViewController

@synthesize userNameField = _userNameField;
@synthesize passwordField = _passwordField;
@synthesize errorMessage = _errorMessage;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.userNameField.delegate = self;
    self.passwordField.delegate = self;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

-(CBCollection *)userCol {
    if(!_userCol) {
        _userCol = [CBCollection collectionWithID:CHAT_USERS_COLLECTION];
    }
    return _userCol;
}

-(void) loginWithUser:(NSString *) userString withPassword:(NSString *) passwordString{
    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    NSError * error;
    [appDelegate initClearBladePlatformWithUser:userString withPassword:passwordString withNewUser:false withError:&error];
    if(!error){
        [self performSegueWithIdentifier:@"loginSegue" sender:self];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"loginSegue"]) {
        __block NSString *username = self.userNameField.text;
        CBQuery *userInfoQuery = [CBQuery queryWithCollectionID:[self.userCol collectionID]];
        [userInfoQuery equalTo:username for:@"email"];
        [userInfoQuery fetchWithSuccessCallback:^(CBQueryResponse *successfulResponse) {
            if ([[successfulResponse dataItems] count] > 0){
                NSString *firstName = [[[[successfulResponse dataItems] objectAtIndex:0] data] valueForKey:@"first_name"];
                NSString *lastName = [[[[successfulResponse dataItems] objectAtIndex:0] data] valueForKey:@"last_name"];
                GroupListViewController *groupView = (GroupListViewController *)segue.destinationViewController;
                 NSDictionary *userInfo = @{@"username":username,@"first_name":firstName,@"last_name":lastName};
                groupView.userInfo = userInfo;
            }else{
                self.errorMessage.text = @"Error getting user's info";
            }
        } withErrorCallback:^(NSError *error, id JSON) {
            self.errorMessage.text = @"Error getting user's info";
        }];
    }
    
}
- (IBAction)loginClicked:(id)sender {
    [self dismissKeyboard];
    self.errorMessage.text = @"";
    NSString *username = self.userNameField.text;
    NSString *password = self.passwordField.text;
    self.passwordField.text = @"";
    if([username length] == 0) {
        self.errorMessage.text = @"No username was entered";
        return;
    } else if ([password length] == 0){
        self.errorMessage.text = @"No password was entered";
    }else {
        [self loginWithUser:username withPassword:password];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSInteger nextTag = textField.tag + 1;
    UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
    if (nextResponder) {
        [nextResponder becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.activeField = textField;
}

-(void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (void)keyboardWasShown:(NSNotification*)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your app might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, self.activeField.frame.origin) ) {
        [self.scrollView scrollRectToVisible:self.activeField.frame animated:YES];
    }
    
}
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}



@end
