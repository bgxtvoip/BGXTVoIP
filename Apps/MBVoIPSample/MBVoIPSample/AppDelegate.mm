#import "AppDelegate.h"
#import "AppDelegate+MBVoIP.h"
#import <AFHTTPSessionManager.h>

@interface AppDelegate ()

@property (strong, nonatomic) Reachability *reachability;

@end

@implementation AppDelegate

#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    self.reachability = [Reachability reachabilityForInternetConnection];
    [self.reachability startNotifier];
    [[NSNotificationCenter defaultCenter] postNotificationName:kReachabilityChangedNotification object:self.reachability];
    
    [[MBVoIPManager sharedInstance] addDelegate:self];
    NSMutableDictionary *voipConfiguration = self.voipConfiguration;
    [voipConfiguration setValue:nil forKey:kMBVoIPConfigurationLocalIPKey];
    [[MBVoIPManager sharedInstance] commitConfiguration:voipConfiguration];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    return;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    NSLog(@"applicationDidEnterBackground");
    if ([application respondsToSelector:@selector(setKeepAliveTimeout:handler:)]) {
        [application setKeepAliveTimeout:600 handler:^{
            NSLog(@"keep");
            return ;
        }];
    }
    
    return;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    return;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    return;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[MBVoIPManager sharedInstance] removeDelegate:self];
    
    [self.reachability stopNotifier];
    self.reachability = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
    
    return;
}

#pragma mark - NSNotificationCenter

- (void)reachabilityChanged:(NSNotification *)notification {
    Reachability *reachability = [notification object];
    NSParameterAssert([reachability isKindOfClass:[Reachability class]]);

    if ([[MBVoIPManager sharedInstance] isCalling]) {
        [[MBVoIPManager sharedInstance] dropCalls];
        
        [[MBVoIPManager sharedInstance] setIsRestart:YES];
    }

    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    switch (networkStatus) {
        case ReachableViaWiFi:
            break;
        case ReachableViaWWAN:
            break;
        case NotReachable:
            break;
        default:
            break;
    }

    NSString *localIPAddress = [[MBVoIPManager sharedInstance] localIPAddress];
    NSMutableDictionary *configuration = [NSMutableDictionary dictionary];
    [configuration setValue:localIPAddress forKey:kMBVoIPConfigurationLocalIPKey];
    [[MBVoIPManager sharedInstance] commitConfiguration:configuration];

    if (![[MBVoIPManager sharedInstance] isRestart]) {
        if ([[MBVoIPManager sharedInstance] isStarted]) {
            [[MBVoIPManager sharedInstance] stop];
        }

        [[MBVoIPManager sharedInstance] start:nil];
    }
    return;
}

@end
