//
//  AppDelegate.m
//  JupViec
//
//  Created by KienVu on 11/28/19.
//  Copyright © 2019 Olala. All rights reserved.
//

#import "AppDelegate.h"
#import <GoogleMaps/GoogleMaps.h>
#import <GooglePlaces/GooglePlaces.h>
#import "JUntil.h"
#import "APIRequest.h"

@interface AppDelegate ()
{
    CLLocationManager *locationmanager;
}

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
// check internet connection
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onNetworkStatusChanged:) name:NETWORK_REACHABILITY_STATUS_CHANGED_NOTIFICATION object:nil];
    [JUntil monitorNetworkReachabilityChanges];
    
    [[UNUserNotificationCenter currentNotificationCenter] setDelegate:self];
    [[FIRMessaging messaging] setDelegate:self];
    
    UNAuthorizationOptions option = UNAuthorizationOptionAlert;
    [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:option completionHandler:^(BOOL granted, NSError * _Nullable error) {
        NSLog(@"allow app send notification on this device");
    }];
    
    [application registerForRemoteNotifications];
    [FIRApp configure];
    
    [[FIRInstanceID instanceID] instanceIDWithHandler:^(FIRInstanceIDResult * _Nullable result, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"error fetching remote Firebase instance ID");
        }
        else{
            NSLog(@"Firebase remote Token : %@",result.token);
            NSLog(@"Firebase remote instance ID : %@",result.instanceID);
            NSString *token = result.token;
            
            if (![[NSUserDefaults standardUserDefaults] objectForKey:ID_FCM_DEVICE_TOKEN])
            {
                [[NSUserDefaults standardUserDefaults] setObject:token forKey:ID_FCM_DEVICE_TOKEN];
                [JUntil sendFCMDeviceTokenToServer:nil];
            }
        }
    }];
    
    [GMSPlacesClient provideAPIKey:@"AIzaSyB1Qo46kfokUCUb9pTGUb0QV5aoKmPV6qE"];
    [GMSServices provideAPIKey:@"AIzaSyB1Qo46kfokUCUb9pTGUb0QV5aoKmPV6qE"];

    return YES;
}

- (void)onNetworkStatusChanged:(NSNotification*)notification
{
    if ([JUntil internetConnectionStatus] != ONLINE)
    {
        [self showAlertForInternetConnection];
    }
}

- (void)showAlertForInternetConnection
{
    UIViewController* topVC = self.window.rootViewController;
    
    [JUntil showPopup:topVC responsecode:RESPONSE_CODE_NOINTERNET];
}

-(BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary<UIApplicationLaunchOptionsKey,id> *)launchOptions
{
    //access location
    [self requestLocationPermission];
    
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
}

#pragma mark - LocationDelegate
-(void)requestLocationPermission
{
    if ([CLLocationManager locationServicesEnabled])
    {
        locationmanager = [[CLLocationManager alloc] init];
        locationmanager.delegate = self;
        
        [locationmanager requestAlwaysAuthorization];
    }
    else
    {
        NSLog(@"Location service was disable. Plz anable first");
    }
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    NSLog(@"did change status %d",status);
    
    switch (status) {
        case kCLAuthorizationStatusDenied:
        case kCLAuthorizationStatusRestricted:
            NSLog(@"Location permission denied");
            break;
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            NSLog(@"Location permission allowed");
            break;
        case kCLAuthorizationStatusNotDetermined:
            NSLog(@"Location permission is not determine");
            break;
        default:
            break;
    }
}

#pragma mark - Firebase Messegging
-(void)messaging:(FIRMessaging *)messaging didReceiveMessage:(FIRMessagingRemoteMessage *)remoteMessage
{
    NSLog(@"%@",remoteMessage.appData);
}

-(void)messaging:(FIRMessaging *)messaging didReceiveRegistrationToken:(NSString *)fcmToken
{
    NSLog(@"did received new token %@",fcmToken);
    [[NSUserDefaults standardUserDefaults] setObject:fcmToken forKey:ID_FCM_DEVICE_TOKEN];
    
    [JUntil sendFCMDeviceTokenToServer:nil];
}

//case FirebaseAppDelegateProxyEnabled : NO
-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [FIRMessaging messaging].APNSToken = deviceToken;
}
@end
