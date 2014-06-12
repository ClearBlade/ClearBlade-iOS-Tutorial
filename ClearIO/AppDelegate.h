//
//  AppDelegate.h
//  ClearIO
//
//  Created by Michael on 6/8/14.
//  Copyright (c) 2014 ClearBlade. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
- (void)initClearBladePlatformWithUser:(NSString *)username withPassword:(NSString *)password withNewUser:(bool)newUser withError:(NSError **)error;
- (void)logoutClearBladePlatformWithError:(NSError **)error;
@end
