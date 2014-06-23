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

@interface ChatViewController () <CBMessageClientDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chatBox;
@property (strong, nonatomic) CBMessageClient *messageClient;
@end

@implementation ChatViewController

@synthesize groupInfo = _groupInfo;
@synthesize userInfo = _userInfo;
@synthesize messageField =_messageField;
@synthesize scrollView = _scrollView;
@synthesize bottomBar = _bottomBar;
@synthesize messages = _messages;
@synthesize chatBox = _chatBox;

-(CBMessageClient *)messageClient {
    if(!_messageClient) {
        _messageClient = [[CBMessageClient alloc] init];
        _messageClient.delegate = self;
    }
    return _messageClient;
}

-(void)messageClientDidConnect:(CBMessageClient *)client {
    CBLogDebug(@"client did connect called in app..");
    [client subscribeToTopic:[self.groupInfo valueForKey:@"item_id"]];
}

-(void)messageClientDidDisconnect:(CBMessageClient *)client {
    CBLogDebug(@"client disconnected called in app..");
}

-(void)messageClient:(CBMessageClient *)client didReceiveMessage:(CBMessage *)message {
    //this should be pulled out into ClearIO lib
    NSString *decodedMessage;
    NSError *error;
    NSDictionary *messageJson =
    [NSJSONSerialization JSONObjectWithData: [message payloadData]
                                    options: kNilOptions
                                      error: &error];
    if(!error){
        decodedMessage = [NSString stringWithFormat:@"%@: %@", [messageJson valueForKey:@"name"], [messageJson valueForKey:@"payload"]];
    }
    //all the way to here
    [self addMessage:decodedMessage];
}

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
    //self.messageClient.reconnectOnDisconnect = false;
    [self.messageClient connect];
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
    //should be in cleario lib (maybe a send image, send message methods?)
    //{"topic":currentGroup, "name":firstName, "type":"text", "payload":textVal};
    NSDictionary *messageObject = @{@"topic":[self.groupInfo valueForKey:@"item_id"],
                                    @"name":[self.userInfo valueForKey:@"firstname"],
                                    @"type":@"text",
                                    @"payload":self.messageField.text};
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:messageObject options:0 error:nil];
    NSString* jsonString = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
   // NSString *messageText = [NSString stringWithFormat:@"%@: %@", [self.userInfo objectForKey:@"firstname"], self.messageField.text];
    [self.messageClient publishMessage:jsonString toTopic:[self.groupInfo valueForKey:@"item_id"]];
    self.messageField.text = @"";
}
- (IBAction)infoClicked:(id)sender {
    [self performSegueWithIdentifier:@"groupInfoSegue" sender:self];
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
