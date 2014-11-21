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
 Subscribe to a given topic
 @param topic item_id of the group you are subscribing to.
 @param ioMessageArriveCallback Callback used anytime a message is received on this topic.
 @param ioErrorCallback Callback used when an error occured.
 */
-(void)ioListenWithTopic:(NSString *)topic withMessageArriveCallback:(ClearIOMessageArriveCallback)ioMessageArriveCallback withErrorCallback:(ClearIOErrorCallback)ioErrorCallback;


/**
 Send an image to a specific topic
 @param image Image to send to topic.
 @param topic Topic to send image to.
 */
-(void)ioSendImage:(UIImage *)image toTopic:(NSString *)topic;

@end
