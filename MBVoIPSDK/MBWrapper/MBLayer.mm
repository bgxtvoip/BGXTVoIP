#import "MBLayer.h"

@interface MBLayer () {
    GLuint _renderBuffer;
    GLuint _frameBuffer;
    
    GLint _renderBufferWidth;
    GLint _renderBufferHeight;
    GLfloat _vertices[8];
    
    GLuint _program;
    GLuint _vertexShader;
    GLuint _fragmentShader;
    
    GLint _uniformLocationModelViewProjectionMatrix;
    GLint _uniformLocationSamplers[3];
    
    GLuint _textures[3];
}

@property (strong, nonatomic) EAGLContext *context;
@property (assign, nonatomic) NSUInteger frameWidth;
@property (assign, nonatomic) NSUInteger frameHeight;

@end

@implementation MBLayer

#pragma mark - NSObject

- (void)dealloc
{
    [self cleanUp];
    
    self.context = nil;
    
    return;
}

- (id)init
{
    self = [super init];
    if (self) {
        _renderBuffer = 0;
        _frameBuffer = 0;
        
        _renderBufferWidth = 0;
        _renderBufferHeight = 0;
        _vertices[0] = 0;
        _vertices[1] = 0;
        _vertices[2] = 0;
        _vertices[3] = 0;
        _vertices[4] = 0;
        _vertices[5] = 0;
        _vertices[6] = 0;
        _vertices[7] = 0;
        
        _program = 0;
        _vertexShader = 0;
        _fragmentShader = 0;
        
        _uniformLocationModelViewProjectionMatrix = 0;
        _uniformLocationSamplers[0] = 0;
        _uniformLocationSamplers[1] = 0;
        _uniformLocationSamplers[2] = 0;
        
        _textures[0] = 0;
        _textures[1] = 0;
        _textures[2] = 0;
        
        self.context = nil;
    }
    return self;
}

#pragma mark - CALayer

+ (MBLayer *)layer
{
    MBLayer *layer = [[self alloc] init];
    layer.frame = CGRectMake(0, 0, 10, 10);
    if ([layer setUp] == NO) {
        layer = nil;
    }
    return layer;
}

#pragma mark - management

- (BOOL)setUp
{
    BOOL result = NO;
    GLuint renderBuffer = 0;
    GLuint frameBuffer = 0;
    GLint renderBufferWidth = 0;
    GLint renderBufferHeight = 0;
    GLuint program = 0;
    GLuint vertexShader = 0;
    GLuint fragmentShader = 0;
    @try {
        [self cleanUp];
        
        // layer
        CAEAGLLayer *layer = self;
        layer.opaque = NO;
        layer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithBool:FALSE], kEAGLDrawablePropertyRetainedBacking,
                                    kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat,
                                    nil];
        
        // context
        EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        if (![context isKindOfClass:[EAGLContext class]] || ![EAGLContext setCurrentContext:context]) {
            NSString *reason = [NSString stringWithFormat:@"failed to set up a context."];
            @throw [NSException exceptionWithName:NSGenericException reason:reason userInfo:nil];
        }
        
        // render buffer
        glGenRenderbuffers(1, &renderBuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, renderBuffer);
        [context renderbufferStorage:GL_RENDERBUFFER fromDrawable:layer];
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &renderBufferWidth);
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &renderBufferHeight);
        
        // frame buffer
        glGenFramebuffers(1, &frameBuffer);
        glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, renderBuffer);
        
        if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
            NSString *reason = [NSString stringWithFormat:@"failed to make completed frame buffer."];
            @throw [NSException exceptionWithName:NSGenericException reason:reason userInfo:nil];
        }
        
        // shaders
        program = glCreateProgram();
        if (program == 0) {
            NSString *reason = [NSString stringWithFormat:@"failed to create a program."];
            @throw [NSException exceptionWithName:NSGenericException reason:reason userInfo:nil];
        }
        
        NSError *error = nil;
        vertexShader = [self compileShader:vertexShaderString type:GL_VERTEX_SHADER error:&error];
        if (error) {
            NSString *reason = [error localizedDescription];
            @throw [NSException exceptionWithName:NSGenericException reason:reason userInfo:nil];
        }
        glAttachShader(program, vertexShader);
        glBindAttribLocation(program, 0, "position");
        
        fragmentShader = [self compileShader:yuvFragmentShaderString type:GL_FRAGMENT_SHADER error:&error];
        if (error) {
            NSString *reason = [error localizedDescription];
            @throw [NSException exceptionWithName:NSGenericException reason:reason userInfo:nil];
        }
        glAttachShader(program, fragmentShader);
        glBindAttribLocation(program, 1, "texcoord");
        
        glLinkProgram(program);
        GLint glLinkStatus = GL_FALSE;
        glGetProgramiv(program, GL_LINK_STATUS, &glLinkStatus);
        if (glLinkStatus == GL_FALSE) {
            NSString *reason = [NSString stringWithFormat:@"failed to link a program."];
            @throw [NSException exceptionWithName:NSGenericException reason:reason userInfo:nil];
        }
        
        glValidateProgram(program);
        GLint glValidateStatus = GL_FALSE;
        glGetProgramiv(program, GL_VALIDATE_STATUS, &glValidateStatus);
        if (glValidateStatus == GL_FALSE) {
            NSString *reason = [NSString stringWithFormat:@"failed to validate a program."];
            GLint logLength = 0;
            glGetProgramiv(program, GL_INFO_LOG_LENGTH, &logLength);
            if (logLength > 0) {
                GLchar *log = (GLchar *)malloc(sizeof(GLchar) * logLength);
                glGetProgramInfoLog(program, sizeof(log), &logLength, log);
                reason = [NSString stringWithFormat:@"%@ [log: %s]", reason, log];
                free(log);
            }
            @throw [NSException exceptionWithName:NSGenericException reason:reason userInfo:nil];
        }
        
        _uniformLocationModelViewProjectionMatrix = glGetUniformLocation(program, "modelViewProjectionMatrix");
        _uniformLocationSamplers[0] = glGetUniformLocation(program, "s_texture_y");
        _uniformLocationSamplers[1] = glGetUniformLocation(program, "s_texture_u");
        _uniformLocationSamplers[2] = glGetUniformLocation(program, "s_texture_v");
        
        _fragmentShader = fragmentShader;
        _vertexShader = vertexShader;
        _program = program;
        
        _vertices[0] = -1.0f; // x0
        _vertices[1] = -1.0f; // y0
        _vertices[2] = 1.0f; // ..
        _vertices[3] = -1.0f;
        _vertices[4] = -1.0f;
        _vertices[5] = 1.0f;
        _vertices[6] = 1.0f; // x3
        _vertices[7] = 1.0f; // y3
        _renderBufferWidth = renderBufferWidth;
        _renderBufferHeight = renderBufferHeight;
        
        _frameBuffer = frameBuffer;
        _renderBuffer = renderBuffer;
        self.context = context;
        
        result = YES;
    }
    @catch (NSException *exception) {
        NSLog(@"exception : %@", exception.reason);
        if (fragmentShader) {
            glDeleteShader(fragmentShader);
        }
        if (vertexShader) {
            glDeleteShader(vertexShader);
        }
        if (program) {
            glDeleteProgram(program);
        }
        
        if (frameBuffer) {
            glDeleteFramebuffers(1, &frameBuffer);
        }
        if (renderBuffer) {
            glDeleteRenderbuffers(1, &renderBuffer);
        }
        
        result = NO;
    }
    @finally {
    }
    
    return result;
}

- (void)cleanUp
{
    if (_textures[0]) {
        glDeleteTextures(3, _textures);
    }
    
    if (_fragmentShader) {
        glDeleteShader(_fragmentShader);
        _fragmentShader = 0;
    }
    if (_vertexShader) {
        glDeleteShader(_vertexShader);
        _vertexShader = 0;
    }
    if (_program) {
        glDeleteProgram(_program);
        _program = 0;
    }
    
    if (_frameBuffer) {
        glDeleteFramebuffers(1, &_frameBuffer);
        _frameBuffer = 0;
    }
    if (_renderBuffer) {
        glDeleteRenderbuffers(1, &_renderBuffer);
        _renderBuffer = 0;
    }
    
    _renderBufferWidth = 0;
    _renderBufferHeight = 0;
    _vertices[0] = 0; // x0
    _vertices[1] = 0; // y0
    _vertices[2] = 0; // ..
    _vertices[3] = 0;
    _vertices[4] = 0;
    _vertices[5] = 0;
    _vertices[6] = 0; // x3
    _vertices[7] = 0; // y3
    _uniformLocationModelViewProjectionMatrix = 0;
    _uniformLocationSamplers[0] = 0;
    _uniformLocationSamplers[1] = 0;
    _uniformLocationSamplers[2] = 0;
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
    self.context = nil;
    
    return;
}

- (void)render:(UInt8 *)data width:(NSUInteger)width height:(NSUInteger)height error:(NSError **)error
{
    if([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive)
    {
        return;
    }
    static const GLfloat texCoords[] = {
        0.0f, 1.0f,
        1.0f, 1.0f,
        0.0f, 0.0f,
        1.0f, 0.0f,
    };
    
    @try {
        if (self.superlayer == nil) {
            NSString *reason = [NSString stringWithFormat:@"layer is not shown."];
            @throw [NSException exceptionWithName:NSGenericException reason:reason userInfo:nil];
        }
        
        if (data == NULL || width <= 0 || height <= 0) {
            NSString *reason = [NSString stringWithFormat:@"invalid argument."];
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:reason userInfo:nil];
        }
        
        if (![EAGLContext setCurrentContext:_context]) {
            NSString *reason = [NSString stringWithFormat:@"failed to set a context up."];
            @throw [NSException exceptionWithName:NSGenericException reason:reason userInfo:nil];
        }
        
        GLint renderBufferWidth = self.bounds.size.width;
        GLint renderBufferHeight = self.bounds.size.height;
        if (renderBufferWidth != _renderBufferWidth || renderBufferHeight != _renderBufferHeight) {
            glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
            [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:self];
            glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_renderBufferWidth);
            glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_renderBufferHeight);
            
            self.frameWidth = 0;
            self.frameHeight = 0;
        }
        if (width != self.frameWidth || height != self.frameHeight) {
            const float frameWidth = width;
            const float frameHeight = height;
            const float dW = (float)_renderBufferWidth / frameWidth;
            const float dH = (float)_renderBufferHeight / frameHeight;
            const float dd = MIN(dH, dW);
            const float w = (frameWidth * dd / (float)_renderBufferWidth);
            const float h = (frameHeight * dd / (float)_renderBufferHeight);
            
            _vertices[0] = - w;
            _vertices[1] = - h;
            _vertices[2] =   w;
            _vertices[3] = - h;
            _vertices[4] = - w;
            _vertices[5] =   h;
            _vertices[6] =   w;
            _vertices[7] =   h;
            
            self.frameWidth = width;
            self.frameHeight = height;
        }
        
        glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
        glViewport(0, 0, _renderBufferWidth, _renderBufferHeight);
        glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
        glClear(GL_COLOR_BUFFER_BIT);
        glUseProgram(_program);
        
        glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
        
        NSUInteger lumaLength = width * height;
        NSUInteger chromaBLength = (width * height) / 4;
        //NSUInteger chromaRLength = (width * height) / 4;
        
        NSUInteger frameWidth = width;
        NSUInteger frameHeight = height;
        
        const UInt8 *pixels[3] = { data, data + lumaLength, data + lumaLength + chromaBLength };
        const NSUInteger widths[3]  = { frameWidth, frameWidth / 2, frameWidth / 2 };
        const NSUInteger heights[3] = { frameHeight, frameHeight / 2, frameHeight / 2 };
        
        if (_textures[0] == 0) {
            glGenTextures(3, _textures);
        }
        if (_textures[0]) {
            for (int i = 0; i < 3; i++) {
                glBindTexture(GL_TEXTURE_2D, _textures[i]);
                
                glTexImage2D(GL_TEXTURE_2D,
                             0,
                             GL_LUMINANCE,
                             widths[i],
                             heights[i],
                             0,
                             GL_LUMINANCE,
                             GL_UNSIGNED_BYTE,
                             pixels[i]);
                
                glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
                glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
                glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
                glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
            }
        }
        
        if (_textures[0]) {
            for (int i = 0; i < 3; i++) {
                glActiveTexture(GL_TEXTURE0 + i);
                glBindTexture(GL_TEXTURE_2D, _textures[i]);
                glUniform1i(_uniformLocationSamplers[i], i);
            }
            
            GLfloat modelviewProj[16];
            mat4f_LoadOrtho(-1.0f, 1.0f, -1.0f, 1.0f, -1.0f, 1.0f, modelviewProj);
            glUniformMatrix4fv(_uniformLocationModelViewProjectionMatrix, 1, GL_FALSE, modelviewProj);
            
            glVertexAttribPointer(0, 2, GL_FLOAT, 0, 0, _vertices);
            glEnableVertexAttribArray(0);
            glVertexAttribPointer(1, 2, GL_FLOAT, 0, 0, texCoords);
            glEnableVertexAttribArray(1);
            
            glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
        }
        
        glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
        [_context presentRenderbuffer:GL_RENDERBUFFER];
    }
    @catch (NSException *exception) {
        NSLog(@"exception : %@", exception.reason);
        if (error) {
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
            NSString *localizedDescription = exception.reason;
            [userInfo setValue:localizedDescription forKey:NSLocalizedDescriptionKey];
            *error = [NSError errorWithDomain:@"application" code:999 userInfo:userInfo];
        }
    }
    @finally {
    }
    
    return;
}

#pragma mark - Shader

#define STRINGIZE(x) #x
#define STRINGIZE2(x) STRINGIZE(x)
#define SHADER_STRING(text) @ STRINGIZE2(text)

NSString *const vertexShaderString = SHADER_STRING
(
 attribute vec4 position;
 attribute vec2 texcoord;
 uniform mat4 modelViewProjectionMatrix;
 varying vec2 v_texcoord;
 
 void main()
 {
     gl_Position = modelViewProjectionMatrix * position;
     v_texcoord = texcoord.xy;
 }
 );

NSString *const yuvFragmentShaderString = SHADER_STRING
(
 varying highp vec2 v_texcoord;
 uniform sampler2D s_texture_y;
 uniform sampler2D s_texture_u;
 uniform sampler2D s_texture_v;
 
 void main()
 {
     highp float y = texture2D(s_texture_y, v_texcoord).r;
     highp float u = texture2D(s_texture_u, v_texcoord).r - 0.5;
     highp float v = texture2D(s_texture_v, v_texcoord).r - 0.5;
     
     highp float r = y +             1.402 * v;
     highp float g = y - 0.344 * u - 0.714 * v;
     highp float b = y + 1.772 * u;
     
     gl_FragColor = vec4(r,g,b,1.0);
 }
 );

- (GLuint)compileShader:(NSString *)source type:(GLenum)type error:(NSError **)error
{
    GLuint shader = 0;
    @try {
        shader = glCreateShader(type);
        if (shader == 0) {
            @throw [NSException exceptionWithName:NSGenericException reason:@"failed to create a shader." userInfo:nil];
        }
        
        const GLchar *string = (GLchar *)source.UTF8String;
        glShaderSource(shader, 1, &string, NULL);
        glCompileShader(shader);
        
        GLint status = 0;
        glGetShaderiv(shader, GL_COMPILE_STATUS, &status);
        if (status == GL_FALSE) {
            NSString *reason = [NSString stringWithFormat:@"failed to compile a shader."];
            GLint logLength = 0;
            glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &logLength);
            if (logLength > 0) {
                GLchar *log = (GLchar *)malloc(sizeof(GLchar) * logLength);
                glGetShaderInfoLog(shader, logLength, NULL, log);
                reason = [NSString stringWithFormat:@"%@ [log: %s]", reason, log];
                free(log);
            }
            @throw [NSException exceptionWithName:NSGenericException reason:reason userInfo:nil];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"exception : %@", exception.reason);
        if (shader) {
            glDeleteShader(shader);
            shader = 0;
        }
        if (error) {
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
            NSString *localizedDescription = exception.reason;
            [userInfo setValue:localizedDescription forKey:NSLocalizedDescriptionKey];
            *error = [NSError errorWithDomain:@"application" code:999 userInfo:userInfo];
        }
    }
    @finally {
        //
    }
    return shader;
}

static void mat4f_LoadOrtho(float left, float right, float bottom, float top, float near, float far, float* mout)
{
    float r_l = right - left;
    float t_b = top - bottom;
    float f_n = far - near;
    float tx = - (right + left) / (right - left);
    float ty = - (top + bottom) / (top - bottom);
    float tz = - (far + near) / (far - near);
    
    mout[0] = 2.0f / r_l;
    mout[1] = 0.0f;
    mout[2] = 0.0f;
    mout[3] = 0.0f;
    
    mout[4] = 0.0f;
    mout[5] = 2.0f / t_b;
    mout[6] = 0.0f;
    mout[7] = 0.0f;
    
    mout[8] = 0.0f;
    mout[9] = 0.0f;
    mout[10] = -2.0f / f_n;
    mout[11] = 0.0f;
    
    mout[12] = tx;
    mout[13] = ty;
    mout[14] = tz;
    mout[15] = 1.0f;
}

@end
