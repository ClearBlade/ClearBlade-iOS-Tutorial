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
 Send an image to a specific topic
 @param image Image to send to topic.
 @param topic Topic to send image to.
 */
-(void)ioSendImage:(UIImage *)image toTopic:(NSString *)topic;

@end
