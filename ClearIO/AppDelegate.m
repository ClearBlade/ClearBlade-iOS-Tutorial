//
//  AppDelegate.m
//  ClearIO
//
//  Created by Michael on 6/8/14.
//  Copyright (c) 2014 ClearBlade. All rights reserved.
//

#import "AppDelegate.h"
#import "ClearIOConstants.h"
#import "CBAPI.h"
#import "ClearIO.h"

@implementation AppDelegate

- (void)initClearBladePlatformWithUser:(NSString *)username withPassword:(NSString *)password withNewUser:(bool)newUser withError:(NSError **)error
{
   // [options setValue:@"http://localhost:8080" forKey:CBSettingsOptionServerAddress];
   // [options setValue:@"tcp://localhost:1883" forKey:CBSettingsOptionMessagingAddress];
   // [options setValue:username forKey:CBSettingsOptionEmail];
   // [options setValue:password forKey:CBSettingsOptionPassword];
   // [options setValue:[NSNumber numberWithBool:newUser] forKey:CBSettingsOptionRegisterUser];
   // [options setValue:[NSNumber numberWithInt:CB_LOG_EXTRA] forKey:CBSettingsOptionLoggingLevel];
    [ClearBlade initSettingsSyncWithSystemKey:CHAT_SYSTEM_KEY withSystemSecret:CHAT_SYSTEM_SECRET withOptions:@{CBSettingsOptionLoggingLevel:@(CB_LOG_EXTRA),CBSettingsOptionServerAddress:@"https://rtp.clearblade.com",CBSettingsOptionMessagingAddress:@"tcp://rtp.clearblade.com:1883",CBSettingsOptionEmail:username,CBSettingsOptionPassword:password,CBSettingsOptionRegisterUser:@(newUser)}  withError:error];
}

- (void)logoutClearBladePlatformWithError:(NSError **)error
{
    [[[ClearBlade settings] mainUser] logOutWithError:error];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [ClearIO initWithSystemKey:CHAT_SYSTEM_KEY withSystemSecret:CHAT_SYSTEM_SECRET withGroupCollectionID:CHAT_GROUPS_COLLECTION withUserGroupsCollectionID:CHAT_USERGROUPS_COLLECTION withUserCollectionID:CHAT_USER_COLLECTION];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

//temp way to accept unsigned certs
@implementation NSURLRequest (NSURLRequestWithIgnoreSSL)

+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString *)host
{
    return YES;
}

@end