#import "AppDelegate.h"

@interface AppDelegate (UserDefaults)

- (id)valueFromUserDefaultsForKey:(NSString *)key;
- (BOOL)setValue:(id)value toUserDefaultsForKey:(NSString *)key;

@end
