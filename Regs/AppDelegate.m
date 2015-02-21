//
//  AppDelegate.m
//  Regs
//
//  Created by Matthew Zorn on 11/9/14.
//  Copyright (c) 2014 Matthew Zorn. All rights reserved.
//

#import "AppDelegate.h"
#import "HomeViewController.h"
#import "GradientView.h"
#import "RegsClient.h"
#import "RegsStyle.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "UIColor+Custom.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [[RegsClient sharedClient] reachability];
    // Create content and menu controllers
    //
    HomeViewController *hvc = [[HomeViewController alloc] init];
    
    self.window.rootViewController = hvc;
    
    [[UINavigationBar appearance] setBarTintColor:[RegsStyle darkBackgroundColor]];
    //[[UINavigationBar appearance] setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    //[[UINavigationBar appearance] setOpaque:YES];
    
    if([[UINavigationBar appearance] respondsToSelector:@selector(setTranslucent:)]) {
         [[UINavigationBar appearance] setTranslucent:NO];
    }
    [[UINavigationBar appearance] setTintColor:[RegsStyle primaryBackgroundColor]];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"Lato-Regular" size:22], NSFontAttributeName, [RegsStyle primaryBackgroundColor], NSForegroundColorAttributeName, nil];
    
    [[UINavigationBar appearance] setTitleTextAttributes:attributes];
    [SVProgressHUD setForegroundColor:[UIColor darkGrayColor]];
    [SVProgressHUD setFont:[UIFont fontWithName:@"Lato-Regular" size:16]];
    [[UITableView appearance] setSeparatorColor:[RegsStyle secondaryLineColor]];
    
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(-1000, -1000) forBarMetrics:UIBarMetricsDefault];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
