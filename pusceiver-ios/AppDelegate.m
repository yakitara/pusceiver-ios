#import <Parse/Parse.h>
#import <NSURL+queryDictionary.h>
#import "FirebaseRootRef.h"
#import "AppDelegate.h"
#import "ItemsViewController.h"
#import "ItemViewController.h"

@interface AppDelegate ()

@property (nonatomic, retain) NSMutableDictionary *callbacksForActions;

- (void)registerXCallbackUrlAction:(NSString *)action callback:(void (^)(NSDictionary *params))callback;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"didFinishLaunchingWithOptions:%@", launchOptions);
    // AppDefaults
    NSDictionary *appDefaults = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AppDefaults" ofType:@"plist"]];
    [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
    // register x-callback-url action
    [self registerXCallbackUrlAction:@"auth" callback:^(NSDictionary *params) {
        [FirebaseRootRef sharedRef].token = params[@"auth_token"];
    }];
    // UI
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    ItemsViewController *itemsViewController = [ItemsViewController new];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:itemsViewController];
    //self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    // PUSH notification
    [Parse setApplicationId:PARSE_APP_ID clientKey:PARSE_CLIENT_KEY];
    // Register for push notifications
    [application registerForRemoteNotificationTypes:
     UIRemoteNotificationTypeBadge |
     UIRemoteNotificationTypeAlert |
     UIRemoteNotificationTypeSound];
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

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    NSLog(@"handleOpenURL: %@", url);
    if ([url.host isEqual:@"x-callback-url"]) {
        NSString *action = url.pathComponents[1];
        for (NSString *key in self.callbacksForActions.allKeys) {
            if ([action isEqual:key]) {
                void (^callback)(NSDictionary *) = [self.callbacksForActions objectForKey:key];
                callback(url.queryDictionary);
            }
        }
    }
    return NO;
}

#pragma mark - PUSH notification

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    // Store the deviceToken in the current Installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"didReceiveRemoteNotification: %@", userInfo);
    NSString *path = userInfo[@"p"];
    if (path) {
        Firebase *itemRef = [[FirebaseRootRef sharedRef] child:path];
        [itemRef on:FEventTypeValue doCallback:^(FDataSnapshot *snapshot) {
            dispatch_async(dispatch_get_main_queue(), ^{
                ItemViewController *itemViewController = [[ItemViewController alloc] initWithDataSnapshot:snapshot];
                [self.window.rootViewController presentViewController:itemViewController animated:YES completion:^{
                    NSLog(@"present ItemViewController done.");
                }];
            });
        }];
    }
}

#pragma mark - property initializers

- (NSMutableDictionary *)callbacksForActions
{
    if(!_callbacksForActions) {
        _callbacksForActions = [NSMutableDictionary dictionary];
    }
    return _callbacksForActions;
}

#pragma mark -

- (void)registerXCallbackUrlAction:(NSString *)action callback:(void (^)(NSDictionary *))callback
{
    [self.callbacksForActions setObject:[callback copy] forKey:action];

}

@end
