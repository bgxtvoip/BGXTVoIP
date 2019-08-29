#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@interface MBLayer : CAEAGLLayer

#pragma mark - CALayer
+ (MBLayer *)layer;
#pragma mark - management
- (void)render:(UInt8 *)data width:(NSUInteger)width height:(NSUInteger)height error:(NSError **)error;

@end
