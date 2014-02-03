//
//  AppDelegate.m
//  Chat
//
//  Created by Charlie Andrews on 11/5/13.
//  Copyright (c) 2013 example. All rights reserved.
//

#import "AppDelegate.h"
#import <CBAPI.h>

@implementation AppDelegate
@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSError * error;
#warning Replace with your own app key and app secret
    [ClearBlade initSettingsSyncWithSystemKey:@"eac9d0aa0ae0dcd7b1e496f4ddde01"
                             withSystemSecret:@"EAC9D0AA0AAAA886B5B4BBAFC6E701"
                                  withOptions:@{}
                                    withError:&error];
    if (error) {
        NSLog(@"Failed to connect with error %@", error);
        return NO;
    }
    return YES;
}
							
@end
