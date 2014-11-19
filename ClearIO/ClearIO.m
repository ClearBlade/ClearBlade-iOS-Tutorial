//
//  ClearIO.m
//  ClearIO
//
//  Created by Michael on 6/16/14.
//  Copyright (c) 2014 ClearBlade. All rights reserved.
//

#import "ClearIO.h"
#import "ClearIOConstants.h"
#import "CBAPI.h"

static ClearIO * _settings = nil;

@implementation ClearIO

+(instancetype)settings {
    @synchronized (_settings) {
        if (!_settings) {
            NSLog(@"System Key and System Secret should be set before calling any ClearIO APIs");
        }
        return _settings;
    }
}

@synthesize systemSecret = _systemSecret;
@synthesize systemKey = _systemKey;
@synthesize groupColID = _groupColID;
@synthesize userGroupsColID = _userGroupsColID;
@synthesize userColID = _UserColID;

-(CBMessageClient *)messageClient {
    if(!_messageClient) {
        _messageClient = [[CBMessageClient alloc] init];
        _messageClient.delegate = self;
    }
    return _messageClient;
}

void(^messageArrivedCallback)(NSDictionary *message);
void(^messagingConnectCallback)(void);
void(^messagingErrorCallback)(NSError *error);

+(void)initWithSystemKey:(NSString *)systemKey withSystemSecret:(NSString *)systemSecret withGroupCollectionID:(NSString *)groupColID withUserGroupsCollectionID:(NSString *)userGroupsColID withUserCollectionID:(NSString *)userColID{
    ClearIO * settings = [[ClearIO alloc] init];
    settings.systemKey = systemKey;
    settings.systemSecret = systemSecret;
    settings.groupColID = groupColID;
    settings.userGroupsColID = userGroupsColID;
    settings.userColID = userColID;
    _settings = settings;
}

-(void)ioLoginWithUser:(NSString *)username withPassword:(NSString *)password withError:(NSError **)error{
    [ClearBlade initSettingsSyncWithSystemKey:self.systemKey
                             withSystemSecret:self.systemSecret
                                  withOptions:@{CBSettingsOptionEmail:username,
                                                CBSettingsOptionPassword:password,
                                                CBSettingsOptionLoggingLevel:@(CB_LOG_EXTRA),
                                                CBSettingsOptionMessagingDefaultQOS:@0}
                                    withError:error];
    if(!*error){
        [[[ClearIO settings] messageClient] connect];
    }
}

-(NSDictionary*)ioGetUserInfoWithError:(NSError **)error{
    NSDictionary * userInfo = [[[ClearBlade settings] mainUser] getCurrentUserInfoWithError:error];
    if (*error) {
        CBLogError(@"error getting user info: <%@>", error);
    }
    return userInfo;
}

-(void)ioRegisterUser:(NSString *)username withPassword:(NSString *)password withFirstName:(NSString *)firstName withLastName:(NSString *)lastName withError:(NSError **)error {
    [ClearBlade initSettingsSyncWithSystemKey:self.systemKey
                             withSystemSecret:self.systemSecret
                                  withOptions:@{CBSettingsOptionLoggingLevel:@(CB_LOG_EXTRA),
                                      CBSettingsOptionEmail:username,
                                      CBSettingsOptionPassword:password,
                                      CBSettingsOptionRegisterUser:@true}
                                    withError:error];
    if(!*error){
        //reg successful, now add fname/lname to user data
        [[[ClearBlade settings] mainUser] setCurrentUserInfoWithDict:@{@"firstname":firstName,
                                                                       @"lastname":lastName}
                                                           withError:error];
        if(*error){
            CBLogError(@"Error setting user info: <%@>", error);
            return;
        }else{
            //remove this else once we have a way to get all users
            //temp need to add user info to users collection..
            CBCollection *userCollection = [CBCollection collectionWithID:self.userColID];
            [userCollection createWithData:@{@"first_name":firstName,
                                             @"last_name":lastName,
                                             @"email":username}
                       withSuccessCallback:^(CBItem *item) {
                           [[[ClearIO settings] messageClient] connect];
                       } withErrorCallback:^(CBItem *item, NSError *error, id JSON) {
                           CBLogError(@"Error adding user to users collection: <%@>", error);
                           return;
                       }];
        }
    }else{
        CBLogError(@"Error registering user: <%@>", error);
        return;
    }
}

-(void)ioLogoutWithError:(NSError **)error {
    [[[ClearBlade settings] mainUser] logOutWithError:error];
    if(*error){
        CBLogError(@"Error logging out of ClearBlade Platform: <%@>", error);
        return;
    }else {
        [[[ClearIO settings] messageClient] disconnect];
    }
}

-(void)ioGetAllUsers:(ClearIOSuccessCallback)ioSuccessCallback withErrorCallback:(ClearIOErrorCallback)ioErrorCallback {
    
}

-(void)ioGetGroupsWithSuccessCallback:(ClearIOSuccessCallback)ioSuccessCallback withErrorCallback:(ClearIOErrorCallback)ioErrorCallback {
    CBQuery *groupsQuery = [CBQuery queryWithCollectionID: CHAT_GROUPS_COLLECTION ];
    [groupsQuery setPageNum: [NSNumber numberWithInt:0]];
    [groupsQuery setPageSize: [NSNumber numberWithInt:0]];
    [groupsQuery fetchWithSuccessCallback:^(CBQueryResponse *successfulResponse) {
        ioSuccessCallback(successfulResponse.dataItems);
//        [self parseGroupListResponse:successfulResponse.dataItems withSuccessCallback:ioSuccessCallback withErrorCallback:ioErrorCallback];
    } withErrorCallback:^(NSError *error, id JSON) {
        CBLogError(@"Error retrieving groups: <%@>", error);
        if(ioErrorCallback) {
            ioErrorCallback(error);
        }
    }];
}
//    [CBCode executeFunction:@"ioGetPublicGroups" withParams:nil withSuccessCallback:^(NSString *result) {
//        [self parseGroupListResponse:result withSuccessCallback:ioSuccessCallback withErrorCallback:ioErrorCallback];
//    } withErrorCallback:^(NSError *error) {
//        CBLogError(@"Error getting public groups: <%@>", error);
//        if(ioErrorCallback) {
//            ioErrorCallback(error);
//        }
//    }];
    
     

-(void)ioGetPrivateGroupsWithSuccessCallback:(ClearIOSuccessCallback)ioSuccessCallback withErrorCallback:(ClearIOErrorCallback)ioErrorCallback {
    [CBCode executeFunction:@"ioGetPrivateGroups" withParams:nil withSuccessCallback:^(NSString *result) {
        [self parseGroupListResponse:result withSuccessCallback:ioSuccessCallback withErrorCallback:ioErrorCallback];
    } withErrorCallback:^(NSError *error) {
        CBLogError(@"Error getting private groups: <%@>", error);
        if(ioErrorCallback) {
            ioErrorCallback(error);
        }
    }];
}

-(void)parseGroupListResponse:(NSString *)resp withSuccessCallback:(ClearIOSuccessCallback)ioSuccessCallback withErrorCallback:(ClearIOErrorCallback)ioErrorCallback {
    NSError *jsonError;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[resp dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&jsonError];
    NSArray *groupArray = [[json objectForKey:@"results"] objectForKey:@"groups"];
    if(jsonError){
        CBLogError(@"error parsing public/private groups list response json: <%@>", jsonError);
        if(ioErrorCallback){
            ioErrorCallback(jsonError);
        }
    }else{
        if (ioSuccessCallback) {
            ioSuccessCallback(groupArray);
        }
    }
}

-(void)ioCreateGroup:(NSString *)groupName withIsPublic:(bool)isPublic withUsers:(NSArray *)users withSuccessCallback:(ClearIOEditGroupSuccessCallback)ioCreateGroupSuccessCallback withErrorCallback:(ClearIOErrorCallback)ioErrorCallback {
    
    //should add some param checks here soon
    //mainly users array should be nil if ispublic is true
    
    [CBCode executeFunction:@"ioCreateGroup" withParams:@{@"isPublic":[NSNumber numberWithBool:isPublic],@"users":users,@"name":groupName} withSuccessCallback:^(NSString *result) {
        [self parseGroupCreateOrEditResponse:result withSuccessCallback:ioCreateGroupSuccessCallback withErrorCallback:ioErrorCallback];
        } withErrorCallback:^(NSError *error) {
        CBLogError(@"Error creating group: <%@>", error);
        if(ioErrorCallback) {
            ioErrorCallback(error);
        }
    }];
}

-(void)ioUpdateGroup:(NSString *)groupID withNewName:(NSString *)newGroupName withOldIsPublic:(bool)oldIsPublic withNewIsPublic:(bool)newIsPublic withAddedUsers:(NSArray *)addedUsers withRemovedUsers:(NSArray *)removedUsers withSuccessCallback:(ClearIOEditGroupSuccessCallback)ioEditGroupSuccessCallback withErrorCallback:(ClearIOErrorCallback)ioErrorCallback {
    
    //verify params at some point
    //should fail if trying to change public from true to false
    //if new is public is true, user arrays should be nil
    
    if (!removedUsers) {
        removedUsers = [[NSArray alloc] init];
    }
    if (!addedUsers) {
        addedUsers = [[NSArray alloc] init];
    }

    [CBCode executeFunction:@"ioUpdateGroup"
                 withParams:@{@"group_id":groupID,
                              @"newName":newGroupName,
                              @"newIsPublic":[NSNumber numberWithBool:newIsPublic],
                              @"usersToAdd":addedUsers,
                              @"usersToRemove":removedUsers}
        withSuccessCallback:^(NSString *result) {
            [self parseGroupCreateOrEditResponse:result withSuccessCallback:ioEditGroupSuccessCallback withErrorCallback:ioErrorCallback];
        }
          withErrorCallback:^(NSError *error) {
              CBLogError(@"Error updating group: <%@>", error);
              if(ioErrorCallback) {
                  ioErrorCallback(error);
              }
    }];
    
}

-(void)parseGroupCreateOrEditResponse:(NSString *)resp withSuccessCallback:(ClearIOEditGroupSuccessCallback)ioSuccessCallback withErrorCallback:(ClearIOErrorCallback)ioErrorCallback{
    NSError *jsonError;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[resp dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&jsonError];
    
    //instead of returning a string, let's return a dictrionary representing the new group info
    //include item_id, group_name, is_public, and array of users
    NSDictionary *newGroupInfo = [json objectForKey:@"results"];
    if(jsonError){
        CBLogError(@"error parsing create/edits group response json: <%@>", jsonError);
        if(ioErrorCallback){
            ioErrorCallback(jsonError);
        }
    }else{
        if (ioSuccessCallback) {
            ioSuccessCallback(newGroupInfo);
        }
    }
}

-(void)ioListenWithTopic:(NSString *)topic withMessageArriveCallback:(ClearIOMessageArriveCallback)ioMessageArriveCallback withErrorCallback:(ClearIOErrorCallback)ioErrorCallback{
    //set our callback methods
    messageArrivedCallback = ioMessageArriveCallback;
    messagingErrorCallback = ioErrorCallback;
    
    [[[ClearIO settings] messageClient] subscribeToTopic:topic];
}

-(void)ioSendText:(NSString *)messageString toTopic:(NSString *)topic{
    NSError *error;
    NSDictionary *tempUserInfo = [[[ClearBlade settings] mainUser] getCurrentUserInfoWithError:&error];
    if(!error){
        NSDictionary *messageObject = @{@"topic":topic,
                                        @"name":[tempUserInfo valueForKey:@"firstname"],
                                        @"type":@"text",
                                        @"payload":messageString,
                                        @"user_id":[tempUserInfo valueForKey:@"email"]};
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:messageObject options:0 error:nil];
        NSString* messageString = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
        [[[ClearIO settings] messageClient] publishMessage:messageString toTopic:topic];
    }
}

-(void)ioSendImage:(UIImage *)image toTopic:(NSString *)topic{
    NSData *imageData = UIImagePNGRepresentation(image);
    NSString *imageString = [NSString stringWithFormat:@"data:image/png;base64,%@",[imageData base64EncodedStringWithOptions:kNilOptions]];
    NSError *error;
    NSDictionary *tempUserInfo = [[[ClearBlade settings] mainUser] getCurrentUserInfoWithError:&error];
    if(!error){
        NSDictionary *messageObject = @{@"topic":topic,
                                        @"name":[tempUserInfo valueForKey:@"firstname"],
                                        @"type":@"img",
                                        @"payload":imageString,
                                        @"user_id":[tempUserInfo valueForKey:@"email"]};
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:messageObject options:0 error:nil];
        NSString* messageString = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
        NSString *tempMsgString = [messageString stringByReplacingOccurrencesOfString:@"\\" withString:@""];
        [[[ClearIO settings] messageClient] publishMessage:tempMsgString toTopic:topic];
    }

}

//CBMessageClient delegate methods
-(void)messageClientDidConnect:(CBMessageClient *)client {
    CBLogDebug(@"client did connect called in cleario..");
}

-(void)messageClientDidDisconnect:(CBMessageClient *)client {
    CBLogDebug(@"client disconnected called in cleario..");
}

-(void)messageClient:(CBMessageClient *)client didReceiveMessage:(CBMessage *)message {
    NSError *error;
    NSDictionary *messageJson =
    [NSJSONSerialization JSONObjectWithData: [message payloadData]
                                    options: kNilOptions
                                      error: &error];
    if(!error){
        messageArrivedCallback(messageJson);
    }
}

-(void)messageClient:(CBMessageClient *)client didUnsubscribe:(NSString *)topic {
    
}
//end CBMessageClient delegate methods

@end
