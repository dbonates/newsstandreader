//
//  AppDelegate.m
//  Reader
//
//  Created by  Basispress on 12/18/12.
//  Copyright (c) 2012 Basispress. All rights reserved.
//

#import "AppDelegate.h"
#import "CoreData+MagicalRecord.h"
#import "IssueManager.h"
#import <NewsstandKit/NewsstandKit.h>
#import "InAppStore.h"
#import "JSONKit.h"
#import "NSData+Base64.h"
#import "CredentialStore.h"
#import "MMDrawerController.h"
#import "MMDrawerVisualState.h"
#import "RootViewController.h"
#import "OptionsViewController.h"
#import <MediaPlayer/MediaPlayer.h>

//#import "PonyDebugger.h"

@interface AppDelegate ()
@property(nonatomic, strong) MPMoviePlayerViewController *playerController;

@end

@implementation AppDelegate

BOOL printSubscriber;
MPMoviePlayerViewController *playerController;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    [MagicalRecord setupCoreDataStack];

    CGRect frame = [self frameForCurrentOrientation];
    
    
    NSString *introName = frame.size.width > 768 ? @"intro-landscape" : @"intro-portrait";
    NSLog(@"intro-name: %@", introName);
    NSURL * movieUrl = [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:introName ofType:@"m4v"]];
    _playerController = [[MPMoviePlayerViewController alloc]initWithContentURL:movieUrl];
    _playerController.view.frame = frame;
    _playerController.moviePlayer.controlStyle = MPMovieControlStyleNone;
    _playerController.wantsFullScreenLayout = YES;
    _playerController.moviePlayer.scalingMode = MPMovieScalingModeAspectFill;
    _playerController.moviePlayer.shouldAutoplay = YES;
    [_playerController.moviePlayer setFullscreen:YES animated:NO];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:_playerController.moviePlayer];
    
    //[self.window.rootViewController presentModalViewController:playerController animated:NO];

    /*
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    UIViewController * leftSideDrawerViewController = [storyboard instantiateViewControllerWithIdentifier:@"leftViewController"];
    
        
    UIViewController * centerViewController = [storyboard instantiateViewControllerWithIdentifier:@"centerViewController"];
    

     UINavigationController * navigationController = [[UINavigationController alloc] initWithRootViewController:centerViewController];
    
    MMDrawerController * drawerController = [[MMDrawerController alloc]
                                             initWithCenterViewController:navigationController
                                             leftDrawerViewController:leftSideDrawerViewController];
    [drawerController setMaximumLeftDrawerWidth:320.0];
    [drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModePanningNavigationBar];
    [drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
    [drawerController setShouldStretchDrawer:NO];
    [drawerController setDrawerVisualStateBlock:[MMDrawerVisualState swingingDoorVisualStateBlock]];
    */
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window setRootViewController:_playerController];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    
    
[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    self.credentialStore = [[CredentialStore alloc] init];
    
    /*[[NSNotificationCenter defaultCenter] addObserver:self
     selector:@selector(tokenExpiredProvidences:) name:@"token-expired" object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self
     selector:@selector(tokenSaved:) name:@"token-changed" object:nil];
     */
    
    
//  checar se é a primeira vez
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"firstLaunch"] == nil) {
        [defaults setBool:YES forKey:@"firstLaunch"];
        [self.credentialStore clearSavedCredentials];
        [defaults synchronize];
    }
    if ([defaults objectForKey:@"freeSubscriptionEnabled"] == nil) {
        [defaults setBool:NO forKey:@"freeSubscriptionEnabled"];
        [defaults synchronize];
    }
    
    printSubscriber = [self.credentialStore isLoggedIn];

    
    
    /*
      Pony DEBUG: #import "PonyDebugger.h"
   
    PDDebugger *debugger = [PDDebugger defaultInstance];
    [debugger connectToURL:[NSURL URLWithString:@"ws://localhost:9000/device"]];
    [debugger enableNetworkTrafficDebugging];
    [debugger enableCoreDataDebugging];
    [debugger addManagedObjectContext:[NSManagedObjectContext MR_contextForCurrentThread]];
    [debugger forwardAllNetworkTraffic];
    [debugger enableViewHierarchyDebugging];
      */

    [[IssueManager sharedInstance] update];

    [[InAppStore sharedInstance] addObserver:self
                                  forKeyPath:@"storeCacheState"
                                     options:NSKeyValueObservingOptionNew
                                     context:nil];
//    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"NKDontThrottleNewsstandContentNotifications"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
#ifdef DEBUG
    // For debugging - allow multiple pushes per day
//    NSLog(@"yes, debugging...");
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"NKDontThrottleNewsstandContentNotifications"];
    [[NSUserDefaults standardUserDefaults] synchronize];
#endif
    
    
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeNewsstandContentAvailability];
    
    NSLog(@"launch options %@", [launchOptions JSONString]);
    [self letServerKnowAboutPushTokenIfNeeded];
    
    
    

    return YES;
}

- (CGRect)frameForCurrentOrientation
{
    CGRect frame;

    UIInterfaceOrientation currentOrientation = [[UIApplication sharedApplication] statusBarOrientation];

    if (currentOrientation == UIInterfaceOrientationLandscapeLeft
        || currentOrientation == UIInterfaceOrientationLandscapeRight) {
        frame = CGRectMake(0, 0, 1024, 768);
    }
    else
    {
        frame = CGRectMake(0, 0, 768, 1024);
    }

    return frame;
}

-(void) moviePlayBackDidFinish:(NSNotification*)notification
{
    NSLog(@"Intro video stopped");
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    UIViewController * leftSideDrawerViewController = [storyboard instantiateViewControllerWithIdentifier:@"leftViewController"];
    
    
    UIViewController * centerViewController = [storyboard instantiateViewControllerWithIdentifier:@"centerViewController"];
    
    
    UINavigationController * navigationController = [[UINavigationController alloc] initWithRootViewController:centerViewController];
    
    MMDrawerController * drawerController = [[MMDrawerController alloc]
                                             initWithCenterViewController:navigationController
                                             leftDrawerViewController:leftSideDrawerViewController];
    [drawerController setMaximumLeftDrawerWidth:320.0];
    [drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModePanningNavigationBar];
    [drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
    [drawerController setShouldStretchDrawer:NO];
    [drawerController setDrawerVisualStateBlock:[MMDrawerVisualState swingingDoorVisualStateBlock]];
    
    [self.window setRootViewController:drawerController];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"did receive notification %@", [userInfo JSONString]);
    [[IssueManager sharedInstance] update];
    
}

// indica erro ao registrar o aparelho para receber push notifications
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"\n*****\n\n [linha %d] Falha ao registrar para push notifications \n     %@\n\n*****", __LINE__, error);
}


// indica registro bem sucedido do gadget para receber push notifications
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{

    NSLog(@"registrado com sucesso. token: %@", deviceToken);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:deviceToken forKey:@"com.reader.pushToken"];
    [defaults setValue:@NO forKey:@"com.reader.serverNotified"];
    [defaults synchronize];
    
    [self letServerKnowAboutPushTokenIfNeeded];
}

- (void)letServerKnowAboutPushTokenIfNeeded
{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *serverNotified = [defaults valueForKey:@"com.reader.serverNotified"];
    if (!serverNotified.boolValue) {
        NSData *pushToken = [defaults valueForKey:@"com.reader.pushToken"];
        if (pushToken) {
            NSURL *serverURL = [NSURL URLWithString:PUSH_URL];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:serverURL];
            [request setValue:@"application/json" forHTTPHeaderField:@"content-type"];
            NSDictionary *dict = @{@"bundle_id":[NSBundle mainBundle].bundleIdentifier, @"push_token":@{@"token" : [pushToken base64Encode]}};
            NSData *body = [dict JSONData];
            NSLog(@"request data%@", [dict JSONString]);
            [request setHTTPBody:body];
            
//            NSLog(@"url:\n%@", serverURL);
//            NSLog(@"data:\n%@", body);
            
            [request setHTTPMethod:@"POST"];
            [NSURLConnection sendAsynchronousRequest:request
                                               queue:[NSOperationQueue mainQueue]
                                   completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
                                       NSLog(@"registered response %@", response);
                                       NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                       NSLog(@"registered data %@", string);
                                       NSLog(@"registered error %@", error);
                                       if (!error) {
                                           NSLog(@"setting defaults");
                                           [defaults setValue:@YES forKey:@"com.reader.serverNotified"];
                                           [defaults synchronize];
                                       }
                                       
                                   }];
            
            
        }
    }
    
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSLog(@"store cache state > %d",[InAppStore sharedInstance].storeCacheState);
}

- (void)logIssues
{
    NSArray *issues = [Issue MR_findAll];
    NSLog(@"issues %@", issues);
    NSLog(@"--------\n\n");
    for(Issue *issue in issues) {
        NSLog(@"Issue");
        NSLog(@"----> Name: %@", issue.name);
        NSLog(@"----> State: %d", issue.stateValue);
        NSLog(@"----> Product Identifier: %@", issue.productIdentifier);
        NSLog(@"----> Assets:");
        for(Asset *asset in issue.assets) {
            NSLog(@"------------> Type:%@", asset.type);
            NSLog(@"------------> Downloaded:%@", asset.downloaded);
            NSLog(@"------------> File Path:%@", asset.filePath);
            NSLog(@"------------> URL:%@", asset.url);
        }
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [self setCoverImage];
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
    [[IssueManager sharedInstance] update];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [MagicalRecord cleanUp];
    [self setCoverImage];
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)setCoverImage
{

    NSArray *issues = [Issue MR_findAllSortedBy:@"date" ascending:NO];
    if (issues.count) {
        Issue *issue = issues[0];
        Asset *coverAsset = [Asset MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"type == %@ AND issue == %@", AssetTypeCover, issue]];
        UIImage *image = [UIImage imageWithContentsOfFile:coverAsset.filePath];
        NSLog(@"image %@", image);
        [[UIApplication sharedApplication] setNewsstandIconImage:image];
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"new == %d", YES];
    issues = [Issue MR_findAllWithPredicate:predicate];
    if (issues.count > 0)
    {
        [UIApplication sharedApplication].applicationIconBadgeNumber = 1;
    }
    else
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
}

@end
