//
//  ChatViewController.m
//  Chat
//
//  Created by Charlie Andrews on 11/5/13.
//  Copyright (c) 2013 example. All rights reserved.
//

#import "ChatViewController.h"
#import <CBAPI.h>

@interface ChatViewController () <CBMessageClientDelegate>
@property (strong, nonatomic) CBMessageClient * messageClient;
@end

@implementation ChatViewController

@synthesize group = _group;
@synthesize username = _username;
@synthesize messageField =_messageField;
@synthesize scrollView = _scrollView;
@synthesize bottomBar = _bottomBar;
@synthesize messages = _messages;

-(CBMessageClient *)messageClient {
    if (!_messageClient) {
        _messageClient = [[CBMessageClient alloc] init];
        _messageClient.delegate = self;
    }
    return _messageClient;
}

-(void)messageClientDidConnect:(CBMessageClient *)client {
    [client subscribeToTopic:self.group];
}
-(void)messageClient:(CBMessageClient *)client didReceiveMessage:(CBMessage *)message {
    [self addMessage:[message payloadText]];
}
-(void)messageClient:(CBMessageClient *)client didPublishToTopic:(NSString *)topic withMessage:(CBMessage *)message {
    [self addMessage:[message payloadText]];
}
-(void)messageClient:(CBMessageClient *)client didFailToConnect:(CBMessageClientConnectStatus)reason {
    
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
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
    [self.messageClient connect];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    [self.messages addObject:label];
}

- (IBAction)sendClicked {
    NSString *messageText = [NSString stringWithFormat:@"%@: %@", self.username, self.messageField.text];
    [self.messageClient publishMessage:messageText toTopic:self.group];
    self.messageField.text = @"";
}

@end
