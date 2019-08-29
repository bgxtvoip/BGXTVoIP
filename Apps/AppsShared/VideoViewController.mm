#import "VideoViewController.h"

@interface VideoViewController ()

@end

@implementation VideoViewController

#pragma mark - lifecycle

- (void)dealloc
{
    if (_remoteVideoData != NULL) {
        free(_remoteVideoData);
        _remoteVideoData = NULL;
    }
    
    return;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    mediaEngineWrapper = CMediaEngineWrapper::getEngineWrapperInstance();
    mediaEngineWrapperSetting = CMediaEngineWrapperSetting::getInstance();
    
    mediaEngineWrapper->m_display->delegate = self;
    
    _remoteVideoData = NULL;
    
    return;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([self.sessionPreset length] > 0) {
        self.captureSession.sessionPreset = self.sessionPreset;
    }
    [self.captureSession startRunning];
    
    return;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.captureSession stopRunning];
    
    return;
}

#pragma mark - property

- (AVCaptureSession *)captureSession
{
    if (_captureSession == nil) {
        AVCaptureSession *captureSession = [[AVCaptureSession alloc] init];
        
        AVCaptureDeviceInput *captureDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:self.frontCaptureDevice error:nil];
        if (captureDeviceInput) {
            [captureSession addInput:captureDeviceInput];
        }
        
        AVCaptureVideoDataOutput *captureVideoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
        [captureVideoDataOutput setAlwaysDiscardsLateVideoFrames:YES];
        [captureVideoDataOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
        NSDictionary *videoSettings = [[NSDictionary alloc]initWithObjectsAndKeys:
                                       [NSNumber numberWithUnsignedInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange], kCVPixelBufferPixelFormatTypeKey, nil];
        captureVideoDataOutput.videoSettings = videoSettings;
        
        AVCaptureConnection *captureConnection = [captureVideoDataOutput connectionWithMediaType:AVMediaTypeVideo];
        captureConnection.videoMinFrameDuration = CMTimeMake(1, 1);
        captureConnection.videoMaxFrameDuration = CMTimeMake(1, 1);
        [captureSession addOutput:captureVideoDataOutput];
        
        AVCaptureVideoPreviewLayer *captureVideoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:captureSession];
        captureVideoPreviewLayer.frame = [self.localView bounds];
        captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspect;
        [self.localView.layer addSublayer:captureVideoPreviewLayer];
        
        dispatch_queue_t queue = dispatch_queue_create("camera_queue", NULL);
        [captureVideoDataOutput setSampleBufferDelegate:self queue:queue];
//        dispatch_release(queue);
        
        self.captureSession = captureSession;
    }
    
    return _captureSession;
}

- (AVCaptureDevice *)backCaptureDevice
{
    if (_backCaptureDevice == nil) {
        NSArray *array = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
        for (AVCaptureDevice *device in array) {
            if (device.position == AVCaptureDevicePositionBack) {
                self.backCaptureDevice = device;
                break;
            }
        }
    }
    return _backCaptureDevice;
}

- (AVCaptureDevice *)frontCaptureDevice
{
    if (_frontCaptureDevice == nil) {
        NSArray *array = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
        for (AVCaptureDevice *device in array) {
            if (device.position == AVCaptureDevicePositionFront) {
                self.frontCaptureDevice = device;
                break;
            }
        }
    }
    return _frontCaptureDevice;
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    @autoreleasepool {
        if (self.localView.alpha == 0.0f) {
            dispatch_async(dispatch_get_main_queue(), ^{
                CGAffineTransform affineTransform;
                UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
                switch (deviceOrientation) {
                    case UIDeviceOrientationLandscapeLeft:
                        [connection setVideoOrientation:AVCaptureVideoOrientationLandscapeRight];
                        affineTransform = CGAffineTransformMakeRotation(M_PI + M_PI_2);
                        break;
                        
                    case UIDeviceOrientationLandscapeRight:
                        [connection setVideoOrientation:AVCaptureVideoOrientationLandscapeLeft];
                        affineTransform = CGAffineTransformMakeRotation(M_PI_2);
                        break;
                        
                    case UIDeviceOrientationPortrait:
                    default:
                        [connection setVideoOrientation:AVCaptureVideoOrientationPortrait];
                        affineTransform = CGAffineTransformMakeRotation(0);
                        break;
                }
                
                [UIView beginAnimations:nil context:nil];
                [UIView setAnimationDuration:0.25f];
                
                self.localView.alpha = 1.0f;
                self.localView.transform = affineTransform;
                
                [UIView commitAnimations];
                
                return ;
            });
            
            return;
        }
        
        CVImageBufferRef imageBufferRef = CMSampleBufferGetImageBuffer(sampleBuffer);
        
        CVPixelBufferLockBaseAddress(imageBufferRef, 0);
        
        size_t width = CVPixelBufferGetWidth(imageBufferRef);
        size_t height = CVPixelBufferGetHeight(imageBufferRef);
        
        char *buffer = (char *)CVPixelBufferGetBaseAddressOfPlane(imageBufferRef,0);
        mediaEngineWrapper->m_camera->InputRawVideoData(buffer, width, height);
        
        CVPixelBufferUnlockBaseAddress(imageBufferRef, 0);
    }
    
    return;
}

//- (void)captureOutput:(AVCaptureOutput *)captureOutput didDropSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
//{
//    return;
//}

#pragma mark - MBDisplayDelegate

- (void)MBDisplay:(void *)display videoData:(char *)videoData videoSize:(int)videoSize videoWidth:(int)videoWidth videoHeight:(int)videoHeight
{
    //NSLog(@"???????");
    if (self.currentRemoteVideoSize.width != videoWidth || self.currentRemoteVideoSize.height != videoHeight) {
        if (_remoteVideoData != NULL) {
            free(_remoteVideoData);
            _remoteVideoData = NULL;
        }
        _remoteVideoData = (void *)malloc(sizeof(char *) * ((videoWidth * videoHeight) + ((videoWidth * videoHeight / 4) * 2)));
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.25f];
            
            CGSize newSize = CGSizeMake(videoWidth, videoHeight);
            CGSize boundSize = self.remoteView.superview.bounds.size;
            
            CGFloat widthScaleFactor = boundSize.width / newSize.width;
            CGFloat heightScaleFactor = boundSize.height / newSize.height;
            CGFloat scaleFactor = (widthScaleFactor < heightScaleFactor) ? widthScaleFactor : heightScaleFactor;
            CGRect newBound = CGRectMake(0, 0, newSize.width * scaleFactor, newSize.height * scaleFactor);
            self.remoteView.bounds = newBound;
            self.remoteView.center = CGPointMake(self.remoteView.superview.bounds.size.width / 2, self.remoteView.superview.bounds.size.height / 2);
            self.remoteView.alpha = 1.0f;
            [self.remoteView setVideo:nil width:0 height:0];
            
            self.currentRemoteVideoSize = newSize;
            
            [UIView commitAnimations];
            
            return ;
        });
    }
    
    void *data = _remoteVideoData;
    if (data == NULL) {
        return;
    }
    
    memcpy(data, videoData, (videoWidth * videoHeight) + ((videoWidth * videoHeight / 4) * 2));
    [self.remoteView setVideo:data width:videoWidth height:videoHeight];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.remoteView render];
        
        return ;
    });
    
    return;
}

@end