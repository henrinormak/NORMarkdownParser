//
//  NORAppDelegate.m
//  NORMarkdownParser Example
//
//  Created by Henri Normak on 30/08/2014.
//  Copyright (c) 2014 Henri Normak. All rights reserved.
//

#import "NORAppDelegate.h"
#import "NORViewController.h"

@implementation NORAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    NORViewController *controller = [[NORViewController alloc] init];
    self.window.rootViewController = controller;
    
    [self.window makeKeyAndVisible];
    return YES;
}

@end
