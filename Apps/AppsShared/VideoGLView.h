#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@interface VideoGLView : UIView

- (void)render;
- (void)setVideo:(void *)data width:(NSUInteger)width height:(NSUInteger)height;

@end