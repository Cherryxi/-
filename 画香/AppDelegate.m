//
//  AppDelegate.m
//  画香
//
//  Created by 左细平 on 2016/12/1.
//  Copyright © 2016年 Maycici. All rights reserved.
//
//[4] 如果你的程序要发消息给微信，那么需要调用WXApi的sendReq函数：
//-(BOOL) sendReq:(BaseReq*)req
//其中req参数为SendMessageToWXReq类型。
//需要注意的是，SendMessageToWXReq的scene成员，如果scene填WXSceneSession，那么消息会发送至微信的会话内。如果scene填WXSceneTimeline，那么消息会发送至朋友圈。如果scene填WXSceneFavorite,那么消息会发送到“我的收藏”中。scene默认值为WXSceneSession。
////
//

#import "AppDelegate.h"
#import "WXApi.h"

#define MCWeixinAppID @"wx6c8f95a00bfa9512"
@interface AppDelegate ()<UIApplicationDelegate,WXApiDelegate>


@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [WXApi registerApp:MCWeixinAppID withDescription:@"come on ,showSweet"];
    return YES;
}

-(BOOL)application:(UIApplication *)application  handleOpenURL:(nonnull NSURL *)url{
    return [WXApi handleOpenURL:url delegate:self];
}

-(BOOL)application:(UIApplication *)application openURL:(nonnull NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(nonnull id)annotation{
    return [WXApi handleOpenURL:url delegate:self];
}


/**
 onReq是微信终端向第三方程序发起请求，要求第三方程序响应。第三方程序响应完后必须调用sendRsp返回。在调用sendRsp返回时，会切回到微信终端程序界面。

 @param req 微信终端发起的请求
 */
-(void)onReq:(BaseReq *)req{
    NSLog(@"%s",__func__);
    
}


/**
 如果第三方程序向微信发送了sendReq的请求，那么onResp会被回调。sendReq请求调用后，会切到微信终端程序界面。

 @param resp 微信终端发过来的响应
 */
-(void)onResp:(BaseResp *)resp{
    NSLog(@"%s",__func__);
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
}


@end
