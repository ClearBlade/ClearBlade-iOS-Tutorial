//
//  ClearIO.h
//  ClearIO
//
//  Created by Michael on 6/16/14.
//  Copyright (c) 2014 ClearBlade. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ClearIO : NSObject

@property (strong, atomic) NSString * systemKey;
@property (strong, atomic) NSString * systemSecret;
@property (strong, atomic) NSString * groupColID;
@property (strong, atomic) NSString * userGroupsColID;
@property (strong, atomic) NSString * userColID;

typedef void (^ClearIOSuccessCallback)(NSArray *);
typedef void (^ClearIOEditGroupSuccessCallback)(NSDictionary * newGroupInfo);

typedef void (^ClearIOErrorCallback)(NSError * error);

+(instancetype)settings;

+(void)initWithSystemKey:(NSString *)systemKey withSystemSecret:(NSString *)systemSecret withGroupCollectionID:(NSString *)groupColID withUserGroupsCollectionID:(NSString *)userGroupsColID withUserCollectionID:(NSString *)userColID;

//user stuff
-(void)ioLoginWithUser:(NSString *)username withPassword:(NSString *)password withError:(NSError **)error;
-(NSDictionary*)ioGetUserInfoWithError:(NSError **)error;
-(void)ioRegisterUser:(NSString *)username withPassword:(NSString *)password withFirstName:(NSString *)firstName withLastName: (NSString *)lastName withError:(NSError **)error;
-(void)ioGetAllUsers:(ClearIOSuccessCallback)ioSuccessCallback withErrorCallback:(ClearIOErrorCallback)ioErrorCallback;

//group list stuff
-(void)ioGetPublicGroupsWithSuccessCallback:(ClearIOSuccessCallback)ioSuccessCallback withErrorCallback:(ClearIOErrorCallback)ioErrorCallback;
-(void)ioGetPrivateGroupsWithSuccessCallback:(ClearIOSuccessCallback)ioSuccessCallback withErrorCallback:(ClearIOErrorCallback)ioErrorCallback;

//editing group stuff
-(void)ioCreateGroup:(NSString *)groupName withIsPublic:(bool)isPublic withUsers:(NSArray *)users withSuccessCallback:(ClearIOEditGroupSuccessCallback)ioCreateGroupSuccessCallback withErrorCallback:(ClearIOErrorCallback)ioErrorCallback;
-(void)ioUpdateGroup:(NSString *)groupID withNewName:(NSString *)newGroupName withOldIsPublic:(bool)oldIsPublic withNewIsPublic:(bool)newIsPublic withAddedUsers:(NSArray *)addedUsers withRemovedUsers:(NSArray *)removedUsers withSuccessCallback:(ClearIOEditGroupSuccessCallback)ioEditGroupSuccessCallback withErrorCallback:(ClearIOErrorCallback)ioErrorCallback;
@end
