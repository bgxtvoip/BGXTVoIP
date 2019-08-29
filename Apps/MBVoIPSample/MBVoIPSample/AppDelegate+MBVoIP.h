#import <objc/runtime.h>
#import "AppDelegate.h"

@interface AppDelegate (MBVoIP) <MBVoIPDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) NSMutableDictionary *voipConfiguration;

@end
