//
//  RegisterViewController.h
//  ClearIO
//
//  Created by Michael on 6/8/14.
//  Copyright (c) 2014 ClearBlade. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegisterViewController : UIViewController <UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITextField *firstNameField;
@property (strong, nonatomic) IBOutlet UITextField *lastNameField;
@property (strong, nonatomic) IBOutlet UITextField *emailField;
@property (strong, nonatomic) IBOutlet UITextField *passwordField;
@property (strong, nonatomic) IBOutlet UITextField *confirmPassField;
@property (strong, nonatomic) IBOutlet UILabel *errorMessage;


@end
