#import "VideoConferenceViewController.h"
#import "AppDelegate.h"

@interface VideoConferenceViewController ()

// Views
@property (strong, nonatomic) IBOutlet UIView *largeVideoView;
@property (strong, nonatomic) IBOutlet UIView *smallVideoView;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *localLayer;
@property (strong, nonatomic) CAEAGLLayer *remoteLayer;
@property (strong, nonatomic) IBOutlet UIButton *micMuteButton;
@property (strong, nonatomic) IBOutlet UIButton *powerButton;
@property (strong, nonatomic) IBOutlet UIButton *cameraButton;
@property (strong, nonatomic) IBOutlet UIView *menuOpenView;
@property (strong, nonatomic) IBOutlet UIButton *menuArrowCloseButton;
@property (strong, nonatomic) IBOutlet UIButton *menuFlashButton;
@property (strong, nonatomic) IBOutlet UIButton *menuSpeakerButton;
@property (strong, nonatomic) IBOutlet UIButton *menuMessageButton;
@property (strong, nonatomic) IBOutlet UIView *menuCloseView;
@property (strong, nonatomic) IBOutlet UIButton *menuArrowOpenButton;
// Constraints
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *smallVideoViewHeightLayoutConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *smallVideoViewWidthLayoutConstraint;
// Gesture Recognizer
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *swipeGestureRecognizer;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapGestureRecognizer;
@property (strong, nonatomic) IBOutlet UIPinchGestureRecognizer *pinchGestureRecognizer;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *menuCloseViewTextImageViewTapGestureRecognizer;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *menuOpenViewTextImageViewTapGestureRecognizer;
// Controls
@property (strong, nonatomic) AVCaptureSession *captureSession;
@property (strong, nonatomic) AVCaptureDeviceInput *captureDeviceInput;

@end

@implementation VideoConferenceViewController

#pragma mark - NSObject

- (void)dealloc {
    // NSNotification
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionRouteChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceProximityStateDidChangeNotification object:nil];
    // Views
    [self.remoteLayer removeFromSuperlayer];
    self.remoteLayer = nil;
    [self.localLayer removeFromSuperlayer];
    self.localLayer = nil;
    // Controls
    self.captureSession = nil;
    self.captureDeviceInput = nil;
    return;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    AVCaptureSession *captureSession = [[MBMediaEngineManager sharedInstance] captureSession];
    AVCaptureVideoPreviewLayer *captureVideoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:captureSession];
    self.localLayer = captureVideoPreviewLayer;
    [self.largeVideoView.layer addSublayer:self.localLayer];
    self.localLayer.frame = self.localLayer.superlayer.bounds;
    self.captureSession = captureSession;
    
    self.remoteLayer = [[MBMediaEngineManager sharedInstance] remoteLayer];
    [self.smallVideoView.layer addSublayer:self.remoteLayer];
    self.remoteLayer.frame = self.remoteLayer.superlayer.bounds;
    
    // NSNotification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeAudioSessionRouteNotification:) name:AVAudioSessionRouteChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserverForName:UIDeviceProximityStateDidChangeNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      [UIDevice currentDevice].proximityMonitoringEnabled = NO;
                                                  }];
    
    // Set camera id to cameraButton tag.
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSArray* devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for(AVCaptureDevice *dev in devices)
    {
        if([dev position] == AVCaptureDevicePositionFront) {
            device = dev;
            break;
        }
    }
    if([device position] > 0)
    {
        self.cameraButton.tag = [device position] - 1; // Back:1, Front:2, so minus 1.
    }
    
    self.cameraButton.selected = YES;
    
    return;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    BOOL statusBarHidden = YES;
    if ([UIApplication sharedApplication].statusBarHidden != statusBarHidden) {
        UIStatusBarAnimation statusBarAnimation = UIStatusBarAnimationNone;
        if (animated) {
            statusBarAnimation = UIStatusBarAnimationFade;
        }
        [[UIApplication sharedApplication] setStatusBarHidden:statusBarHidden withAnimation:statusBarAnimation];
    }
    
    return;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [self setLayout];
    
    return;
}

#pragma mark - UIViewController (UIViewControllerRotation)

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self.view setNeedsLayout];
    
    return;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - NSNotification

- (void)changeAudioSessionRouteNotification:(NSNotification *)notification {
    return;
}

#pragma mark - IBAction

- (IBAction)selector:(id)sender {
    // Button
    if (sender == self.micMuteButton) {
        BOOL enable = !self.micMuteButton.selected;
        if ([self updateMute:enable isInput:YES]) {
            self.micMuteButton.selected = enable;
        }
        return;
    }
    if (sender == self.powerButton) {
        [self dismissViewControllerAnimated:YES completion:nil];
        [[MBVoIPManager sharedInstance] dropCalls];
        return;
    }
    if (sender == self.cameraButton) {
        NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
        NSInteger tag = self.cameraButton.tag;
        NSUInteger index = (tag + 1) % [devices count];
        AVCaptureDevice *captureDevice = [devices objectAtIndex:index];
        AVCaptureSession *captureSession = self.captureSession;
        [captureSession beginConfiguration];
        captureDevice = [self updateCaptureDeviceInput:captureSession captureDevice:captureDevice];
        if ([captureDevice isKindOfClass:[AVCaptureDevice class]]) {
            AVCaptureVideoOrientation captureVideoOrientation = [self captureVideoOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
            [self updateCaptureDeviceOutputVideoOrientation:captureSession captureVideoOrientation:captureVideoOrientation];
        }
        [captureSession commitConfiguration];
        self.cameraButton.tag = [devices indexOfObject:captureDevice];
        self.cameraButton.selected = (captureDevice.position == AVCaptureDevicePositionFront);
        if ([captureDevice hasTorch]) {
            self.menuFlashButton.enabled = YES;
            if (captureDevice.torchMode == AVCaptureTorchModeOn) {
                self.menuFlashButton.selected = YES;
            }
            else {
                self.menuFlashButton.selected = NO;
            }
        }
        else {
            self.menuFlashButton.enabled = NO;
            self.menuFlashButton.selected = NO;
        }
        return;
    }
    // Menu
    if (sender == self.menuArrowCloseButton) {
        self.menuOpenView.hidden = YES;
        self.menuCloseView.hidden = NO;
        return;
    }
    if (sender == self.menuFlashButton) {
        BOOL enable = !self.menuFlashButton.selected;
        AVCaptureDeviceInput *input = [self.captureSession.inputs firstObject];
        if ([input.device hasTorch]) {
            if ([input.device lockForConfiguration:nil]) {
                enable ? [input.device setTorchMode:AVCaptureTorchModeOn] : [input.device setTorchMode:AVCaptureTorchModeOff];
                self.menuFlashButton.selected = enable;
                [input.device unlockForConfiguration];
            }
        }
        else {
            self.menuFlashButton.enabled = NO;
            self.menuFlashButton.selected = NO;
        }
        return;
    }
    if (sender == self.menuSpeakerButton) {
        BOOL enable = !self.menuSpeakerButton.selected;
        if ([self updateMute:enable isInput:NO]) {
            self.menuSpeakerButton.selected = enable;
        }
        return;
    }
    if (sender == self.menuArrowOpenButton) {
        self.menuOpenView.hidden = NO;
        self.menuCloseView.hidden = YES;
    }
    // Gesture Recognizer
    if (sender == self.menuCloseViewTextImageViewTapGestureRecognizer) {
        [self selector:self.menuArrowOpenButton];
        return;
    }
    if (sender == self.menuOpenViewTextImageViewTapGestureRecognizer) {
        [self selector:self.menuArrowCloseButton];
        return;
    }
    if (sender == self.swipeGestureRecognizer) {
        UISwipeGestureRecognizer *swipeGestureRecognizer = self.swipeGestureRecognizer;
        if (swipeGestureRecognizer.state == UIGestureRecognizerStateEnded) {
            CALayer *localLayerSuperlayer = self.localLayer.superlayer;
            CALayer *remoteLayerSuperlayer = self.remoteLayer.superlayer;
            [self.localLayer removeFromSuperlayer];
            [self.remoteLayer removeFromSuperlayer];
            [localLayerSuperlayer addSublayer:self.remoteLayer];
            self.remoteLayer.frame = self.remoteLayer.superlayer.bounds;
            [remoteLayerSuperlayer addSublayer:self.localLayer];
            self.localLayer.frame = self.localLayer.superlayer.bounds;
        }
    }
    if (sender == self.tapGestureRecognizer) {
        if (self.smallVideoViewHeightLayoutConstraint.constant > 100.0f) {
            self.smallVideoViewHeightLayoutConstraint.constant = 50.0f;
        }
        else {
            self.smallVideoViewHeightLayoutConstraint.constant = 150.0f;
        }
        self.smallVideoViewWidthLayoutConstraint.constant = self.smallVideoViewHeightLayoutConstraint.constant;
    }
    if (sender == self.pinchGestureRecognizer) {
        static AVCaptureDeviceInput *captureDeviceInput = nil;
        static CGFloat beganVideoZoomFactor = 1.0f;
        
        switch (self.pinchGestureRecognizer.state) {
            case UIGestureRecognizerStatePossible:
                break;
            case UIGestureRecognizerStateBegan: {
                @try {
                    if ([self.captureSession.inputs count] == 0) {
                        @throw [NSException exceptionWithName:NSGenericException reason:@"no input from session." userInfo:nil];
                    }
                    captureDeviceInput = [self.captureSession.inputs firstObject];
                    if (![captureDeviceInput isKindOfClass:[AVCaptureDeviceInput class]]) {
                        @throw [NSException exceptionWithName:NSGenericException reason:@"no device input." userInfo:nil];
                    }
                    beganVideoZoomFactor = captureDeviceInput.device.videoZoomFactor;
                }
                @catch (NSException *exception) {
                    captureDeviceInput = nil;
                    beganVideoZoomFactor = 1.0f;
                    self.pinchGestureRecognizer.enabled = NO;
                    self.pinchGestureRecognizer.enabled = YES;
                }
                @finally {
                }
            }
                break;
            case UIGestureRecognizerStateChanged: {
                if ([captureDeviceInput.device lockForConfiguration:nil]) {
                    CGFloat videoZoomFactor = beganVideoZoomFactor * self.pinchGestureRecognizer.scale;
                    if (videoZoomFactor > captureDeviceInput.device.activeFormat.videoZoomFactorUpscaleThreshold) {
                        videoZoomFactor = captureDeviceInput.device.activeFormat.videoZoomFactorUpscaleThreshold;
                    }
                    else if (videoZoomFactor < 1.0f) {
                        videoZoomFactor = 1.0f;
                    }
                    captureDeviceInput.device.videoZoomFactor = videoZoomFactor;
                    [captureDeviceInput.device unlockForConfiguration];
                }
            }
                break;
            case UIGestureRecognizerStateEnded: {
                captureDeviceInput = nil;
                beganVideoZoomFactor = 1.0f;
            }
                break;
            case UIGestureRecognizerStateFailed: {
                captureDeviceInput = nil;
                beganVideoZoomFactor = 1.0f;
            }
                break;
                
            default:
                break;
        }
    }
    
    return;
}

#pragma mark - layout

- (void)setLayout {
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    AVCaptureSession *captureSession = self.captureSession;
    [captureSession beginConfiguration];
    [self updateCaptureDeviceOutputVideoOrientation:captureSession captureVideoOrientation:[self captureVideoOrientation:interfaceOrientation]];
    [captureSession commitConfiguration];
    self.localLayer.transform = [self transform3D:interfaceOrientation];
    self.localLayer.frame = self.localLayer.superlayer.bounds;
    self.remoteLayer.transform = CATransform3DIdentity;
    self.remoteLayer.frame = self.remoteLayer.superlayer.bounds;
    
    [self setVideoGravity:interfaceOrientation];
    
    return;
}

- (void)setVideoGravity:(UIInterfaceOrientation)interfaceOrientation {
    CMediaEngineWrapper *mediaEngineWrapper = CMediaEngineWrapper::getEngineWrapperInstance();
    if (mediaEngineWrapper != NULL && mediaEngineWrapper->getOnlyLandscape() == false)
    {
        self.localLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    }
    else
    {
        switch (interfaceOrientation) {
            case UIInterfaceOrientationLandscapeLeft:
            case UIInterfaceOrientationLandscapeRight:
                self.localLayer.videoGravity = AVLayerVideoGravityResizeAspect;
                break;
            default:
                self.localLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
                break;
        }
    }
}
- (CATransform3D)transform3D:(UIInterfaceOrientation)interfaceOrientation {
    CATransform3D transform3D = CATransform3DIdentity;
    switch (interfaceOrientation) {
        case UIInterfaceOrientationLandscapeLeft:
            transform3D = CATransform3DRotate(CATransform3DIdentity, M_PI_2, 0, 0, 1.0f);
            break;
        case UIInterfaceOrientationLandscapeRight:
            transform3D = CATransform3DRotate(CATransform3DIdentity, M_PI + M_PI_2, 0, 0, 1.0f);
            break;
            
        default:
            break;
    }
    return transform3D;
}

#pragma mark - control

- (AVCaptureDevice *)updateCaptureDeviceInput:(AVCaptureSession *)captureSession captureDevice:(AVCaptureDevice *)captureDevice {
    AVCaptureDeviceInput *oldCaptureDeviceInput = nil;
    for (AVCaptureDeviceInput *input in captureSession.inputs) {
        if ([input.device hasMediaType:AVMediaTypeVideo]) {
            oldCaptureDeviceInput = input;
            if (oldCaptureDeviceInput.device == captureDevice) {
                return oldCaptureDeviceInput.device;
            }
            break;
        }
    }

    AVCaptureDeviceInput *newCaptureDeviceInput = nil;
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if (device == captureDevice) {
            newCaptureDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
            if ([newCaptureDeviceInput isKindOfClass:[AVCaptureDeviceInput class]]) {
                [captureSession removeInput:oldCaptureDeviceInput];
                [captureSession addInput:newCaptureDeviceInput];
            }
            break;
        }
    }

    return newCaptureDeviceInput.device;
}

- (void)updateCaptureDeviceOutputVideoOrientation:(AVCaptureSession *)captureSession captureVideoOrientation:(AVCaptureVideoOrientation)captureVideoOrientation {
    AVCaptureConnection *captureConnection = nil;
    for (AVCaptureOutput *output in captureSession.outputs) {
        AVCaptureConnection *connection = [output connectionWithMediaType:AVMediaTypeVideo];
        if ([connection isKindOfClass:[AVCaptureConnection class]]) {
            captureConnection = connection;
            break;
        }
    }
    if ([captureConnection videoOrientation] != captureVideoOrientation) {
        [captureConnection setVideoOrientation:captureVideoOrientation];
    }

    return;
}

- (AVCaptureVideoOrientation)captureVideoOrientation:(UIInterfaceOrientation)interfaceOrientation {
    AVCaptureVideoOrientation captureVideoOrientation = AVCaptureVideoOrientationPortrait;
    switch (interfaceOrientation) {
        case UIInterfaceOrientationLandscapeLeft:
            captureVideoOrientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
        case UIInterfaceOrientationLandscapeRight:
            captureVideoOrientation = AVCaptureVideoOrientationLandscapeRight;
            break;

        default:
            break;
    }
    return captureVideoOrientation;
}

- (BOOL)updateMute:(BOOL)enable isInput:(BOOL)isInput {
    BOOL result = NO;
    @try {
        CMediaEngineWrapper *mediaEngineWrapper = CMediaEngineWrapper::getEngineWrapperInstance();
        if (mediaEngineWrapper == NULL) {
            @throw [NSException exceptionWithName:NSGenericException reason:@"failed to get a media engine." userInfo:nil];
        }
        int channelID = -1;
        MediaChannelDirection mediaChannelDirection = (isInput) ? MEDIA_CHANNEL_SENDER : MEDIA_CHANNEL_RECEIVER;
        for (int i = 0; i < MB_TOTAL_CHANNEL_NUM; i++) {
            if (mediaEngineWrapper->channels[i].id > -1 &&
                mediaEngineWrapper->channels[i].type == MEDIA_TYPE_AUDIO &&
                mediaEngineWrapper->channels[i].direction == mediaChannelDirection) {
                channelID = mediaEngineWrapper->channels[i].id;
                break;
            }
        }
        if (channelID == -1) {
            @throw [NSException exceptionWithName:NSGenericException reason:@"failed to get a channel ID." userInfo:nil];
        }
        MbStatus status = mediaEngineWrapper->SetMute(channelID, enable);
        if (status != MB_STATUS_OK) {
            @throw [NSException exceptionWithName:NSGenericException reason:@"failed to set a mute enable." userInfo:nil];
        }

        result = YES;
    }
    @catch (NSException *exception) {
        NSLog(@"exception : %@", exception.reason);
    }
    @finally {
    }

    return result;
}

@end
