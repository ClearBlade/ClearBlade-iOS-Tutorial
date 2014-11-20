//
//  ClearIO.h
//  ClearIO
//
//  Created by Michael on 6/16/14.
//  Copyright (c) 2014 ClearBlade. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CBAPI.h"

@interface ClearIO : NSObject <CBMessageClientDelegate>

@property (strong, atomic) NSString * systemKey;
@property (strong, atomic) NSString * systemSecret;
@property (strong, atomic) NSString * groupColID;
@property (strong, atomic) NSString * userGroupsColID;
@property (strong, atomic) NSString * userColID;

@property (strong, nonatomic) CBMessageClient * messageClient;

/**
 Callback for handling successful get all users and get public/private groups.
 @param result NSArray object holding NSDictionaries containing user/group info respectively
 */
typedef void (^ClearIOSuccessCallback)(NSArray * result);

/**
 Callback for handling successful group creation or edit
 @param newGroupInfo NSDictionary containing the group's new info
 */
typedef void (^ClearIOEditGroupSuccessCallback)(NSDictionary * newGroupInfo);

/**
 Callback for handling successful receipt of a message
 @param message NSDictionary containing key/value pairs received in message
 */
typedef void (^ClearIOMessageArriveCallback)(NSDictionary * message);

/**
 Callback used for handling any errors in async requests in ClearIO library
 @param error NSError with the appropriate error message
 */
typedef void (^ClearIOErrorCallback)(NSError * error);

+(instancetype)settings;

/**
 Initialize a new ClearIO object
 @param systemKey The System Key.
 @param systemSecret The System Secret.
 @param groupColID The Group Collection ID.
 @param userGroupsColID The UserGroups Collection ID.
 @param userColID The Users Collection ID.
 @returns a newly initialized object
 */
+(void)initWithSystemKey:(NSString *)systemKey withSystemSecret:(NSString *)systemSecret withGroupCollectionID:(NSString *)groupColID withUserGroupsCollectionID:(NSString *)userGroupsColID withUserCollectionID:(NSString *)userColID;

/**
 Initializes ClearBlade Platform synchronously with default settings.
 Also initializes with the given user.
 @param username Username (email) of user to authenticate with.
 @param password The users password.
 @param error Is set if the ClearBlade platform fails to initialize.
 */
-(void)ioLoginWithUser:(NSString *)username withPassword:(NSString *)password withError:(NSError **)error;

/**
 Synchronously get current users info from the ClearBlade Auth table
 @param error Is set if an error occured getting info.
 @return NSDictionary containing key/value paisrs of all columns in the auth table for current user
 */
-(NSDictionary*)ioGetUserInfoWithError:(NSError **)error;

/**
 Synchronously register given user, and input user data into Auth table
 Also initializes ClearBlade platform with given user
 @param username Username (email) of the user to register.
 @param password Password to set for this new user.
 @param firstName First name of user.
 @param lastName Last name of user.
 @param error IS set if an error occured during user registration process.
 */
-(void)ioRegisterUser:(NSString *)username withPassword:(NSString *)password withFirstName:(NSString *)firstName withLastName: (NSString *)lastName withError:(NSError **)error;

/**
 Asynchronously get list of all users (this will eventually be added to the iOS SDK)
 @param ioSuccessCallback Callback used when all users are successfully received.
 @param ioErrorCallback Callback used when an error occured.
 */
-(void)ioGetAllUsers:(ClearIOSuccessCallback)ioSuccessCallback withErrorCallback:(ClearIOErrorCallback)ioErrorCallback;

/**
 Logout current user form the ClearBlade platform.
 @param error Is set if an error occured during logout.
 */
-(void)ioLogoutWithError:(NSError **)error;

/**
 Get a list of all public groups using a service in the platform
 @param ioSuccessCallback Callback used when public groups are successfully received.
 @param ioErrorCallback Callback used when an error occured.
 */
-(void)ioGetGroupsWithSuccessCallback:(ClearIOSuccessCallback)ioSuccessCallback withErrorCallback:(ClearIOErrorCallback)ioErrorCallback;

/**
 Get a list of all private groups the currently authenticated user has access to
 using a service in the platform
 @param ioSuccessCallback Callback used when private groups are successfully received.
 @param ioErrorCallback Callback used when an error occured.
 */
-(void)ioGetPrivateGroupsWithSuccessCallback:(ClearIOSuccessCallback)ioSuccessCallback withErrorCallback:(ClearIOErrorCallback)ioErrorCallback;

/**
 Create a new group with given settings usering a service in the platform
 @param groupName Display name for the group.
 @param isPublic Flag for if the group should be joinable by anyone, or have a set of allowed users.
 @param users Array of users (email addresses) that should have access to this group.
 @param ioCreateGroupSuccessCallback Callback used when group was successfully created.
 @param ioErrorCallback Callback used when an error occured.
 */
-(void)ioCreateGroup:(NSString *)groupName withIsPublic:(bool)isPublic withUsers:(NSArray *)users withSuccessCallback:(ClearIOEditGroupSuccessCallback)ioCreateGroupSuccessCallback withErrorCallback:(ClearIOErrorCallback)ioErrorCallback;

/**
 Edit a groups settings using a service in the platform
 @param groupID item_id for the group you are updating.
 @param newGroupName New group display name to set for the group.
 @param oldIsPublic Previous isPublic flag value.
 @param newIsPublic New isPublic flag value.
 @param addedUsers Array of users (emails) to add to this group.
 @param removedUsers Array of users (emails) to remove from this group.
 @param ioEditGroupSuccessCallback Callback used when group was successfully updated.
 @param ioErrorCallback Callback used when an error occured.
 */
-(void)ioUpdateGroup:(NSString *)groupID withNewName:(NSString *)newGroupName withOldIsPublic:(bool)oldIsPublic withNewIsPublic:(bool)newIsPublic withAddedUsers:(NSArray *)addedUsers withRemovedUsers:(NSArray *)removedUsers withSuccessCallback:(ClearIOEditGroupSuccessCallback)ioEditGroupSuccessCallback withErrorCallback:(ClearIOErrorCallback)ioErrorCallback;

/**
 Subscribe to a given topic
 @param topic item_id of the group you are subscribing to.
 @param ioMessageArriveCallback Callback used anytime a message is received on this topic.
 @param ioErrorCallback Callback used when an error occured.
 */
-(void)ioListenWithTopic:(NSString *)topic withMessageArriveCallback:(ClearIOMessageArriveCallback)ioMessageArriveCallback withErrorCallback:(ClearIOErrorCallback)ioErrorCallback;

-(void)ioMessageHistory:(NSString *)topic withHistoryArriveCallback:(ClearIOSuccessCallback)ioMessageHistoryCallback withErrorCallback:(ClearIOErrorCallback)ioErrorCallback;

/**
 Send a text message to a specific topic
 @param messageString Message text to send to topic.
 @param topic Topic to send message to.
 */
-(void)ioSendText:(NSString *)messageString toTopic:(NSString *)topic;

/**
 Send an image to a specific topic
 @param image Image to send to topic.
 @param topic Topic to send image to.
 */
-(void)ioSendImage:(UIImage *)image toTopic:(NSString *)topic;

@end
