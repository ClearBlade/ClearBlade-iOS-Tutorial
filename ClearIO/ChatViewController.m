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
        //add your message parsing logic for your view here
        if ([[message valueForKey:@"type"] isEqualToString:@"text"]){
            [self addMessage:[NSString stringWithFormat:@"%@: %@",[message valueForKey:@"name"],[message valueForKey:@"payload"]]];
        } else if ([[message valueForKey:@"type"] isEqualToString:@"img"]){
            NSString *imageString = [message valueForKey:@"payload"];
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageString]];
            UIImage *image = [UIImage imageWithData:imageData];
            [self addImage:image fromUser:[message valueForKey:@"name"]];
        }
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

-(void)addImage:(UIImage *)image fromUser:(NSString *)name{
    UITextView *label = [[UITextView alloc] init];
    label.text = name;
    label.scrollEnabled = NO;
    label.editable = NO;
    label.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
    
    CGRect labelRect = self.view.frame;
    labelRect.origin.y = 0;
    labelRect.origin.x = 0;
    labelRect.size.height = [name boundingRectWithSize:(CGSize){labelRect.size.width,CGFLOAT_MAX}
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                          attributes:@{NSFontAttributeName: self.messageField.font}
                                             context:nil].size.height + 10;
    labelRect.size.width -= (10 * 2);
    
    label.frame = labelRect;
    
    UIImageView *imgView = [[UIImageView alloc] initWithImage:image];
    
    CGRect imgViewRect = self.view.frame;
    
    imgViewRect.origin.x = 10;
    imgViewRect.origin.y = labelRect.size.height;
    imgViewRect.size.width = imgView.image.size.width;
    imgViewRect.size.height = imgView.image.size.height;
    
    imgView.frame = imgViewRect;
    

    UIView *view = [[UIView alloc] init];
    
    [view addSubview:label];
    [view addSubview:imgView];
    
    CGRect rect = self.view.frame;
    CGRect lastMessageRect = [[self.messages lastObject] frame];
    rect.origin.y = lastMessageRect.origin.y + lastMessageRect.size.height + 10;
    rect.size.width -= (10 * 2);
    rect.origin.x += 10;
    rect.size.height = imgView.image.size.height + 30;
    
    view.frame = rect;
    view.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
    
    UIScrollView *scrollView = self.scrollView;
    [scrollView addSubview:view];
    scrollView.contentSize = CGSizeMake(rect.size.width, rect.origin.y + rect.size.height);
    CGPoint bottomOffset = CGPointMake(0, scrollView.contentSize.height - scrollView.bounds.size.height);
    if(scrollView.contentSize.height > scrollView.bounds.size.height - 40){
        [scrollView setContentOffset:bottomOffset animated:YES];
    }
    [self.messages addObject:view];
    
    
    
    /*
    CGRect rect = self.view.frame;
    CGRect lastMessageRect = [[self.messages lastObject] frame];
    rect.origin.y = lastMessageRect.origin.y + lastMessageRect.size.height + 10;
    UIView *view = [[UIView alloc] init];
    UIImageView * imgView = [[UIImageView alloc] initWithImage:image];
    //rect.size.width -= (10 * 2);
    rect.origin.x += 10;
    
    rect.size.height = imgView.image.size.height;
    rect.size.width = imgView.image.size.width;
    imgView.frame = rect;
    imgView.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
    
    UITextView * label = [[UITextView alloc] init];
    label.text = name;
    label.scrollEnabled = NO;
    label.editable = NO;
    
    [view addSubview:label];
    [view addSubview:imgView];
    
    UIScrollView * scrollView = self.scrollView;
    [scrollView addSubview:view];
    scrollView.contentSize = CGSizeMake(rect.size.width, rect.origin.y + rect.size.height);
    CGPoint bottomOffset = CGPointMake(0, scrollView.contentSize.height - scrollView.bounds.size.height);
    if(scrollView.contentSize.height > scrollView.bounds.size.height - 40){
        [scrollView setContentOffset:bottomOffset animated:YES];
    }
    [self.messages addObject:imgView];
     */
}

- (IBAction)sendClicked {
    [[ClearIO settings] ioSendText:self.messageField.text toTopic:[self.groupInfo valueForKey:@"item_id"]];
    self.messageField.text = @"";
}

- (IBAction)infoClicked:(id)sender {
    [self performSegueWithIdentifier:@"groupInfoSegue" sender:self];
}

- (void) handleBack:(id)sender{
    for (UIViewController *controller in self.navigationController.viewControllers) {
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
