#import "AppDelegate+UserDefaults.h"

@implementation AppDelegate (UserDefaults)

- (id)valueFromUserDefaultsForKey:(NSString *)key
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    id value = [userDefaults valueForKey:key];
    
    return value;
}

- (BOOL)setValue:(id)value toUserDefaultsForKey:(NSString *)key
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:value forKey:key];
    
    return [userDefaults synchronize];
}

@end
