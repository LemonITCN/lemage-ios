//
//  AppDelegate.m
//  lemage-example
//
//  Created by 1iURI on 2018/6/12.
//  Copyright © 2018年 LemonIT.CN. All rights reserved.
//

#import "AppDelegate.h"
#import "LemageURLProtocol.h"
#import "Lemage.h"
#import "NSUrlProtocol+Lemage.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
//    NSString *lemageUrl = @"lemage://album/local/AA39A4B6-8777-424F-963E-3E40583C8971/L0/001";
//    NSArray<NSString *> *strItems = [lemageUrl componentsSeparatedByString: @"/"];
//    NSInteger prefixLength = 0;
//    for (NSInteger index = 0; index < 4; index ++) {
//        prefixLength += (strItems[index].length + 1);
//    }
//    NSString *tag = [lemageUrl substringFromIndex: prefixLength];
//    NSLog(@"%@" , tag);
//    NSLog(@"%@" , [@"" componentsSeparatedByString: @"/"]);
//    NSDictionary<NSString *,NSString *> *dic = nil;
    [NSURLProtocol registerClass:[LemageURLProtocol class]];
    [NSURLProtocol registerToWKWebviewWithScheme:@"lemage"];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [Lemage expiredTmpTermUrl];
}


@end
