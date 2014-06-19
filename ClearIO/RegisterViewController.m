//
//  RegisterViewController.m
//  ClearIO
//
//  Created by Michael on 6/8/14.
//  Copyright (c) 2014 ClearBlade. All rights reserved.
//

#import "RegisterViewController.h"
#import "GroupListViewController.h"
#import "AppDelegate.h"
#import "CBAPI.h"
#import "ClearIOConstants.h"
#import "ClearIO.h"

@interface RegisterViewController ()
@property UITextField *activeField;
@property CGSize kbSize;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) CBCollection *userCol;
@end

@implementation RegisterViewController

@synthesize firstNameField = _firstNameField;
@synthesize lastNameField = _lastNameField;
@synthesize emailField = _emailField;
@synthesize passwordField = _passwordField;
@synthesize confirmPassField = _confirmPassField;
@synthesize errorMessage = _errorMessage;

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
    self.firstNameField.delegate = self;
    self.lastNameField.delegate = self;
    self.emailField.delegate = self;
    self.passwordField.delegate = self;
    self.confirmPassField.delegate = self;
    
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
        _userCol = [CBCollection collectionWithID:CHAT_USER_COLLECTION];
    }
    return _userCol;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)registerClicked:(id)sender {
    NSString *firstName = self.firstNameField.text;
    NSString *lastName = self.lastNameField.text;
    NSString *email = self.emailField.text;
    NSString *password = self.passwordField.text;
    NSString *confirmPass = self.confirmPassField.text;
    if ( ![password isEqualToString:confirmPass] ){
        self.errorMessage.text = @"The passwords did not match";
        return;
    }
    //AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    NSError * error;
    //[appDelegate initClearBladePlatformWithUser:email withPassword:password withNewUser:true withError:&error];
    [[ClearIO settings] ioRegisterUser:email
                          withPassword:password
                         withFirstName:firstName
                          withLastName:lastName
                             withError:&error];
    if(!error){
        /*
        //user successfully registered, let's update user collection with their info
        [self.userCol createWithData:@{CHAT_USER_FIELD:email, @"first_name":firstName, @"last_name":lastName, @"groups":@"{}"} withSuccessCallback:^(CBItem *newUser) {
            [self performSegueWithIdentifier:@"successRegisterSegue" sender:self];
        }withErrorCallback:^(CBItem *item, NSError *error, id JSON) {
            self.errorMessage.text = [error localizedDescription];
        }];
         */
        [self performSegueWithIdentifier:@"successRegisterSegue" sender:self];
    }else {
        self.errorMessage.text = [error localizedDescription];
        return;
    }
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"successRegisterSegue"]) {
        NSString *username = self.emailField.text;
        NSString *firstName = self.firstNameField.text;
        NSString *lastName = self.lastNameField.text;
        NSDictionary *userInfo = @{@"username":username,@"first_name":firstName,@"last_name":lastName};
        GroupListViewController *groupView = (GroupListViewController *)segue.destinationViewController;
        if ([self.emailField.text length] == 0) {
            self.errorMessage.text = @"No username was entered";
            return;
        } else {
            groupView.userInfo = userInfo;
        }
    }}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSInteger nextTag = textField.tag + 1;
    UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
    if (nextResponder) {
        self.activeField = (UITextField*)[textField.superview viewWithTag:nextTag];
        [self scrollIfActiveFieldHidden];
        [nextResponder becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
        [self registerClicked:nil];
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
    self.kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, self.kbSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your app might not need or want this behavior.
    [self scrollIfActiveFieldHidden];
    
}
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

- (void)scrollIfActiveFieldHidden {
    CGRect aRect = self.view.frame;
    aRect.size.height -= self.kbSize.height;
    if (!CGRectContainsPoint(aRect, self.activeField.frame.origin) ) {
        [self.scrollView scrollRectToVisible:self.activeField.frame animated:YES];
    }
}

@end
