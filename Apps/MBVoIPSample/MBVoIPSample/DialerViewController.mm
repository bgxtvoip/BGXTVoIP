#import "DialerViewController.h"
#import "AppDelegate.h"
#import "AppDelegate+MBVoIP.h"
#import "MBVoIPManager.h"

@interface DialerViewController ()

// views
@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (strong, nonatomic) IBOutlet UIView *foregroundView;
@property (strong, nonatomic) IBOutlet UILabel *numberLabel;
@property (strong, nonatomic) IBOutlet UIButton *backspaceButton;
@property (strong, nonatomic) IBOutlet UIButton *oneButton;
@property (strong, nonatomic) IBOutlet UIButton *twoButton;
@property (strong, nonatomic) IBOutlet UIButton *threeButton;
@property (strong, nonatomic) IBOutlet UIButton *fourButton;
@property (strong, nonatomic) IBOutlet UIButton *fiveButton;
@property (strong, nonatomic) IBOutlet UIButton *sixButton;
@property (strong, nonatomic) IBOutlet UIButton *sevenButton;
@property (strong, nonatomic) IBOutlet UIButton *eightButton;
@property (strong, nonatomic) IBOutlet UIButton *nineButton;
@property (strong, nonatomic) IBOutlet UIButton *asteriskButton;
@property (strong, nonatomic) IBOutlet UIButton *zeroButton;
@property (strong, nonatomic) IBOutlet UIButton *hashtagButton;
@property (strong, nonatomic) IBOutlet UIButton *audioCallButton;
@property (strong, nonatomic) IBOutlet UIButton *videoCallButton;

@end

@implementation DialerViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[MBVoIPManager sharedInstance] addDelegate:self];
    [self setLayout:[[MBVoIPManager sharedInstance] isRegistered] animated:NO];
    
    return;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if ([[MBVoIPManager sharedInstance] isStarted] == NO) {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSMutableDictionary *voipConfiguration = appDelegate.voipConfiguration;
        [voipConfiguration setValue:nil forKey:kMBVoIPConfigurationLocalIPKey];
        [[MBVoIPManager sharedInstance] commitConfiguration:voipConfiguration];
        if ([[MBVoIPManager sharedInstance] start:nil] == NO) {
            self.tabBarController.selectedIndex = 1;
        }
    }
    
    return;
}

#pragma mark - MBVoIPDelegate

- (void)registered:(BOOL)success {
    [self setLayout:success animated:YES];
    
    return;
}

- (void)unregistered {
    [self setLayout:NO animated:YES];
    
    return;
}

#pragma mark - IBAction

- (IBAction)selector:(id)sender {
    if (sender == self.backspaceButton) {
        if (self.numberLabel.text.length > 0) {
            self.numberLabel.text = [self.numberLabel.text substringToIndex:self.numberLabel.text.length - 1];
        }
        
        return;
    }
    
    if (sender == self.audioCallButton) {
        [[MBVoIPManager sharedInstance] makeAudioOnlyCall:self.numberLabel.text];
        
        return;
    }
    
    if (sender == self.videoCallButton) {
        [[MBVoIPManager sharedInstance] makeVideoCall:self.numberLabel.text];
        
        return;
    }
    
    return;
}

- (IBAction)clickedPadButton:(id)sender {
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)sender;
        self.numberLabel.text = [self.numberLabel.text stringByAppendingString:button.titleLabel.text];
        
        return;
    }
}

#pragma mark - layout

- (void)setLayout:(BOOL)enable {
    [self setLayout:enable animated:NO];
    
    return;
}

- (void)setLayout:(BOOL)enable animated:(BOOL)animated {
    NSTimeInterval duration = 0.0f;
    if (animated) {
        duration = 0.25f;
    }
    
    self.view.userInteractionEnabled = NO;
    [UIView animateWithDuration:duration animations:^{
        if (enable) {
            self.mainView.alpha = 1.0f;
            self.foregroundView.alpha = 0.1f;
        }
        else {
            self.mainView.alpha = 0.0f;
            self.foregroundView.alpha = 1.0f;
        }
        self.mainView.userInteractionEnabled = enable;
        self.foregroundView.userInteractionEnabled = !enable;
        
        return ;
    } completion:^(BOOL finished) {
        self.view.userInteractionEnabled = YES;
        
        return ;
    }];
    
    return;
}

@end
