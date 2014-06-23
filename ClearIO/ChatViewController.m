//
//  ChatViewController.m
//  Chat
//
//  Created by Charlie Andrews on 11/5/13.
//  Copyright (c) 2013 example. All rights reserved.
//

#import "ChatViewController.h"
#import "CBAPI.h"
#import "GroupInfoViewController.h"
#import "GroupListViewController.h"
#import "ClearIO.h"

@interface ChatViewController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chatBox;
@end

@implementation ChatViewController

@synthesize groupInfo = _groupInfo;
@synthesize userInfo = _userInfo;
@synthesize messageField =_messageField;
@synthesize scrollView = _scrollView;
@synthesize bottomBar = _bottomBar;
@synthesize messages = _messages;
@synthesize chatBox = _chatBox;

- (void)keyboardWillBeShown:(NSNotification*)notification {
    CGSize size = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    float duration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView animateWithDuration:duration animations:^{
        NSLayoutConstraint * constraint = self.chatBox;
        if (constraint) {
            constraint.constant = size.height;
            [self.view layoutIfNeeded];
        }
    }];
    
}

- (void)keyboardWillBeHidden:(NSNotification*)notification {
    float duration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView animateWithDuration:duration animations:^{
        NSLayoutConstraint * constraint = self.chatBox;
        if (constraint) {
            constraint.constant = 0.0f;
            [self.view layoutIfNeeded];
        }
    }];
}

-(NSMutableArray *)messages {
    if (!_messages) {
        _messages = [NSMutableArray arrayWithCapacity:50];
    }
    return _messages;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(handleBack:)];
    self.navigationItem.leftBarButtonItem = backButton;

    [[ClearIO settings] ioListenWithTopic:[self.groupInfo valueForKey:@"item_id"] withMessageArriveCallback:^(NSDictionary *message) {
        //and your message parsing logic for your view here
        [self addMessage:[NSString stringWithFormat:@"%@: %@",[message valueForKey:@"name"],[message valueForKey:@"payload"]]];
    } withErrorCallback:^(NSError *error) {
        NSLog(@"error callback in chat view controller");
    }];

	// Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeShown:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

-(void)addMessage:(NSString *)message {
    CGRect rect = self.view.frame;
    CGRect lastMessageRect = [[self.messages lastObject] frame];
    rect.origin.y = lastMessageRect.origin.y + lastMessageRect.size.height + 10;
    UITextView * label = [[UITextView alloc] init];
    rect.size.width -= (10 * 2);
    rect.origin.x += 10;
    rect.size.height = [message boundingRectWithSize:(CGSize){rect.size.width,CGFLOAT_MAX}
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                          attributes:@{NSFontAttributeName: self.messageField.font} //UITextView does not have a default font
                                             context:nil].size.height + 10;
    label.frame = rect;
    label.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
    label.text = message;
    label.scrollEnabled = NO;
    label.editable = NO;
    
    UIScrollView * scrollView = self.scrollView;
    [scrollView addSubview:label];
    scrollView.contentSize = CGSizeMake(rect.size.width, rect.origin.y + rect.size.height);
    CGPoint bottomOffset = CGPointMake(0, scrollView.contentSize.height - scrollView.bounds.size.height);
    if(scrollView.contentSize.height > scrollView.bounds.size.height - 40){
        [scrollView setContentOffset:bottomOffset animated:YES];
    }
    [self.messages addObject:label];
}

- (IBAction)sendClicked {
    [[ClearIO settings] ioSendWithTopic:[self.groupInfo valueForKey:@"item_id"] WithMessageString:self.messageField.text];
    self.messageField.text = @"";
}

- (IBAction)infoClicked:(id)sender {
    [self performSegueWithIdentifier:@"groupInfoSegue" sender:self];
}

- (void) handleBack:(id)sender{
    for (UIViewController *controller in self.navigationController.viewControllers) {
        
        //Do not forget to import AnOldViewController.h
        if ([controller isKindOfClass:[GroupListViewController class]]) {
            [controller loadView];
            [self.navigationController popToViewController:controller
                                                  animated:YES];
            break;
        }
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"groupInfoSegue"]){
        GroupInfoViewController *groupInfoController = (GroupInfoViewController *)segue.destinationViewController;
        if(![groupInfoController isKindOfClass:[GroupInfoViewController class]]){
            NSLog(@"Unexpected type of view controller");
            return;
        } else {
            groupInfoController.userInfo = self.userInfo;
            groupInfoController.isNewGroup = false;
            groupInfoController.groupInfo = self.groupInfo;
        }
    }
}

@end
