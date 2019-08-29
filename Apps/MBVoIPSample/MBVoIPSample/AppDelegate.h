#import <UIKit/UIKit.h>
#import <MBVoIP/MBVoIP.h>
#import "MBVoIPManager.h"
#import "Reachability.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (readonly, nonatomic) Reachability *reachability;

@end
