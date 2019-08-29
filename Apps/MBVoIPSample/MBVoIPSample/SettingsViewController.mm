#import "SettingsViewController.h"
#import "AppDelegate.h"
#import "AppDelegate+MBVoIP.h"
#import "TextFieldTableViewCell.h"
#import "PickerViewTableViewCell.h"
#import "SettingsCodecsViewController.h"

@interface SettingsViewController ()

// VoIP
@property (strong, nonatomic) IBOutlet TextFieldTableViewCell *registerIPCell;
@property (strong, nonatomic) IBOutlet TextFieldTableViewCell *registerPortCell;
@property (strong, nonatomic) IBOutlet TextFieldTableViewCell *localPortCell;
// Audio
@property (strong, nonatomic) IBOutlet UISegmentedControl *audioAECSegmentedControl;
@property (strong, nonatomic) IBOutlet UISlider *audioMicGainBeforeAECVolumeSlider;
@property (strong, nonatomic) IBOutlet UISlider *audioMicGainAfterAECVolumeSlider;
@property (strong, nonatomic) IBOutlet PickerViewTableViewCell *audioAGCCell;
@property (strong, nonatomic) IBOutlet PickerViewTableViewCell *audioDenoiserCell;
@property (strong, nonatomic) IBOutlet UISlider *audioVolumeSlider;
// Video
@property (strong, nonatomic) IBOutlet PickerViewTableViewCell *videoResolutionCell;
@property (strong, nonatomic) IBOutlet PickerViewTableViewCell *videoBitrateCell;
@property (strong, nonatomic) IBOutlet TextFieldTableViewCell *videoFramerateCell;
@property (strong, nonatomic) IBOutlet TextFieldTableViewCell *videoIframeRequestCell;
@property (strong, nonatomic) IBOutlet TextFieldTableViewCell *videoIframeIntervalCell;
// Input Accessory
@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneBarButtonItem;
// Navigation
@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveBarButtonItem;
// Data Sources
@property (strong, nonatomic) NSMutableDictionary *configuration;
@property (strong, nonatomic) NSMutableDictionary *configurationDataSource;
@property (strong, nonatomic) NSMutableArray *configurationKeys;
@property (assign, atomic) BOOL hasChangedConfiguration;

@end

@implementation SettingsViewController

@synthesize configuration = _configuration;
@synthesize configurationKeys = _configurationKeys;

static NSString * const kDictionaryNameKey = @"name";
static NSString * const kDictionaryValueKey = @"value";

#pragma mark - NSObject

- (void)dealloc {
    // NSNotificationCenter
    // VoIP
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:self.registerIPCell.textField];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:self.registerPortCell.textField];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:self.localPortCell.textField];    
    // Video
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:self.videoFramerateCell.textField];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:self.videoIframeRequestCell.textField];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:self.videoIframeIntervalCell.textField];
    return;
}

#pragma mark - UIResponder(UIResponderInputViewAdditions)

- (UIView *)inputAccessoryView {
    return self.toolbar;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.clearsSelectionOnViewWillAppear = YES;
    
    // NSNotificationCenter
    // VoIP
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChangeNotification:) name:UITextFieldTextDidChangeNotification object:self.registerIPCell.textField];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChangeNotification:) name:UITextFieldTextDidChangeNotification object:self.registerPortCell.textField];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChangeNotification:) name:UITextFieldTextDidChangeNotification object:self.localPortCell.textField];
    // Video
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChangeNotification:) name:UITextFieldTextDidChangeNotification object:self.videoFramerateCell.textField];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChangeNotification:) name:UITextFieldTextDidChangeNotification object:self.videoIframeRequestCell.textField];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChangeNotification:) name:UITextFieldTextDidChangeNotification object:self.videoIframeIntervalCell.textField];
    
    // Static Cells
    /// VoIP
    self.registerIPCell.textField.text = [self.configuration valueForKey:kMBVoIPConfigurationRegisterIPKey];
    self.registerPortCell.textField.text = [self.configuration valueForKey:kMBVoIPConfigurationRegisterPortKey];
    self.localPortCell.textField.text = [self.configuration valueForKey:kMBVoIPConfigurationLocalPortKey];
    /// Audio
    self.audioAECSegmentedControl.selectedSegmentIndex = [[self.configuration valueForKey:kMBVoIPConfigurationAudioAECKey] intValue];
    self.audioMicGainBeforeAECVolumeSlider.value = [[self.configuration valueForKey:kMBVoIPConfigurationAudioMicGainBeforeAECVolumeKey] floatValue];
    self.audioMicGainAfterAECVolumeSlider.value = [[self.configuration valueForKey:kMBVoIPConfigurationAudioMicGainAfterAECVolumeKey] floatValue];
    int audioAGCValue = [[self.configuration valueForKey:kMBVoIPConfigurationAudioAGCKey] intValue];
    NSArray *audioAGCs = [self.configurationDataSource valueForKey:kMBVoIPConfigurationAudioAGCKey];
    for (NSDictionary *audioAGC in audioAGCs) {
        if ([[audioAGC valueForKey:kDictionaryValueKey] intValue] == audioAGCValue) {
            NSInteger selectRow = [audioAGCs indexOfObject:audioAGC];
            [self.audioAGCCell.pickerView selectRow:selectRow inComponent:0 animated:NO];
            self.audioAGCCell.contentLabel.text = [audioAGC valueForKey:kDictionaryNameKey];
            break;
        }
    }
    int audioDenoiserValue = [[self.configuration valueForKey:kMBVoIPConfigurationAudioDenoiserKey] intValue];
    NSArray *audioDenoisers = [self.configurationDataSource valueForKey:kMBVoIPConfigurationAudioDenoiserKey];
    for (NSDictionary *audioDenoiser in audioDenoisers) {
        if ([[audioDenoiser valueForKey:kDictionaryValueKey] intValue] == audioDenoiserValue) {
            NSInteger selectRow = [audioDenoisers indexOfObject:audioDenoiser];
            [self.audioDenoiserCell.pickerView selectRow:selectRow inComponent:0 animated:NO];
            self.audioDenoiserCell.contentLabel.text = [audioDenoiser valueForKey:kDictionaryNameKey];
            break;
        }
    }
    self.audioVolumeSlider.value = [[self.configuration valueForKey:kMBVoIPConfigurationAudioVolumeKey] floatValue];
    /// Video
    int videoResolutionValue = [[self.configuration valueForKey:kMBVoIPConfigurationVideoResolutionKey] intValue];
    NSArray *videoResolutions = [self.configurationDataSource valueForKey:kMBVoIPConfigurationVideoResolutionKey];
    for (NSDictionary *videoResolution in videoResolutions) {
        if ([[videoResolution valueForKey:kDictionaryValueKey] intValue] == videoResolutionValue) {
            NSInteger selectRow = [videoResolutions indexOfObject:videoResolution];
            [self.videoResolutionCell.pickerView selectRow:selectRow inComponent:0 animated:NO];
            self.videoResolutionCell.contentLabel.text = [videoResolution valueForKey:kDictionaryNameKey];
            break;
        }
    }
    int videoBitrateValue = [[self.configuration valueForKey:kMBVoIPConfigurationVideoBitrateKey] intValue];
    NSArray *videoBitrates = [self.configurationDataSource valueForKey:kMBVoIPConfigurationVideoBitrateKey];
    for (NSDictionary *videoBitrate in videoBitrates) {
        if ([[videoBitrate valueForKey:kDictionaryValueKey] intValue] == videoBitrateValue) {
            NSInteger selectRow = [videoBitrates indexOfObject:videoBitrate];
            [self.videoBitrateCell.pickerView selectRow:selectRow inComponent:0 animated:NO];
            self.videoBitrateCell.contentLabel.text = [videoBitrate valueForKey:kDictionaryNameKey];
            break;
        }
    }
    self.videoFramerateCell.textField.text = [[self.configuration valueForKey:kMBVoIPConfigurationVideoFramerateKey] stringValue];
    self.videoIframeRequestCell.textField.text = [[self.configuration valueForKey:kMBVoIPConfigurationVideoIframeRequestKey] stringValue];
    self.videoIframeIntervalCell.textField.text = [[self.configuration valueForKey:kMBVoIPConfigurationVideoIframeIntervalKey] stringValue];
    return;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIViewController *viewController = [segue destinationViewController];
    if ([viewController isKindOfClass:[SettingsCodecsViewController class]]) {
        SettingsCodecsViewController *settingsCodecsViewController = (SettingsCodecsViewController *)viewController;
        settingsCodecsViewController.configuration = self.configuration;
    }
    
    return;
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    if (cell.userInteractionEnabled == YES) {
        cell.contentView.alpha = 1.0f;
    }
    else {
        cell.contentView.alpha = 0.5f;
    }
    return cell;
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    NSString *configurationDataSourceKey = nil;
    // Audio
    if (pickerView == self.audioAGCCell.pickerView) {
        configurationDataSourceKey = kMBVoIPConfigurationAudioAGCKey;
    }
    if (pickerView == self.audioDenoiserCell.pickerView) {
        configurationDataSourceKey = kMBVoIPConfigurationAudioDenoiserKey;
    }
    // Video
    if (pickerView == self.videoResolutionCell.pickerView) {
        configurationDataSourceKey = kMBVoIPConfigurationVideoResolutionKey;
    }
    if (pickerView == self.videoBitrateCell.pickerView) {
        configurationDataSourceKey = kMBVoIPConfigurationVideoBitrateKey;
    }
    
    if ([configurationDataSourceKey isKindOfClass:[NSString class]]) {
        NSArray *sources = [self.configurationDataSource valueForKey:configurationDataSourceKey];
        return ([sources count] != 0);
    }
    return 0;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSString *configurationDataSourceKey = nil;
    // Audio
    if (pickerView == self.audioAGCCell.pickerView) {
        configurationDataSourceKey = kMBVoIPConfigurationAudioAGCKey;
    }
    if (pickerView == self.audioDenoiserCell.pickerView) {
        configurationDataSourceKey = kMBVoIPConfigurationAudioDenoiserKey;
    }
    // Video
    if (pickerView == self.videoResolutionCell.pickerView) {
        configurationDataSourceKey = kMBVoIPConfigurationVideoResolutionKey;
    }
    if (pickerView == self.videoBitrateCell.pickerView) {
        configurationDataSourceKey = kMBVoIPConfigurationVideoBitrateKey;
    }
    
    if ([configurationDataSourceKey isKindOfClass:[NSString class]]) {
        NSArray *sources = [self.configurationDataSource valueForKey:configurationDataSourceKey];
        return [sources count];
    }
    return 0;
}

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString *configurationDataSourceKey = nil;
    // Audio
    if (pickerView == self.audioAGCCell.pickerView) {
        configurationDataSourceKey = kMBVoIPConfigurationAudioAGCKey;
    }
    if (pickerView == self.audioDenoiserCell.pickerView) {
        configurationDataSourceKey = kMBVoIPConfigurationAudioDenoiserKey;
    }
    // Video
    if (pickerView == self.videoResolutionCell.pickerView) {
        configurationDataSourceKey = kMBVoIPConfigurationVideoResolutionKey;
    }
    if (pickerView == self.videoBitrateCell.pickerView) {
        configurationDataSourceKey = kMBVoIPConfigurationVideoBitrateKey;
    }
    
    if ([configurationDataSourceKey isKindOfClass:[NSString class]]) {
        NSArray *sources = [self.configurationDataSource valueForKey:configurationDataSourceKey];
        return [[sources objectAtIndex:row] valueForKey:kDictionaryNameKey];
    }
    return nil;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSString *configurationDataSourceKey = nil;
    UILabel *contentLabel = nil;
    // Audio
    if (pickerView == self.audioAGCCell.pickerView) {
        configurationDataSourceKey = kMBVoIPConfigurationAudioAGCKey;
        contentLabel = self.audioAGCCell.contentLabel;
    }
    if (pickerView == self.audioDenoiserCell.pickerView) {
        configurationDataSourceKey = kMBVoIPConfigurationAudioDenoiserKey;
        contentLabel = self.audioDenoiserCell.contentLabel;
    }
    // Video
    if (pickerView == self.videoResolutionCell.pickerView) {
        configurationDataSourceKey = kMBVoIPConfigurationVideoResolutionKey;
        contentLabel = self.videoResolutionCell.contentLabel;
    }
    if (pickerView == self.videoBitrateCell.pickerView) {
        configurationDataSourceKey = kMBVoIPConfigurationVideoBitrateKey;
        contentLabel = self.videoBitrateCell.contentLabel;
    }
    
    if ([configurationDataSourceKey isKindOfClass:[NSString class]]) {
        NSArray *sources = [self.configurationDataSource valueForKey:configurationDataSourceKey];
        NSDictionary *source = [sources objectAtIndex:row];
        [self.configuration setValue:[source valueForKey:kDictionaryValueKey] forKey:configurationDataSourceKey];
        contentLabel.text = [source valueForKey:kDictionaryNameKey];
    }
    return;
}

#pragma mark - Notification

- (void)textFieldTextDidChangeNotification:(NSNotification *)notification {
    UITextField *textField = (UITextField *)notification.object;
    NSString *key = nil;
    id value = nil;
    // VoIP
    if (textField == self.registerIPCell.textField) {
        key = kMBVoIPConfigurationRegisterIPKey;
        value = textField.text;
    }
    if (textField == self.registerPortCell.textField) {
        key = kMBVoIPConfigurationRegisterPortKey;
        value = textField.text;
    }
    if (textField == self.localPortCell.textField) {
        key = kMBVoIPConfigurationLocalPortKey;
        value = textField.text;
    }
    // Video
    if (textField == self.videoFramerateCell.textField) {
        key = kMBVoIPConfigurationVideoFramerateKey;
        value = [NSNumber numberWithInt:[textField.text intValue]];
    }
    if (textField == self.videoIframeRequestCell.textField) {
        key = kMBVoIPConfigurationVideoIframeRequestKey;
        value = [NSNumber numberWithInt:[textField.text intValue]];
    }
    if (textField == self.videoIframeIntervalCell.textField) {
        key = kMBVoIPConfigurationVideoIframeIntervalKey;
        value = [NSNumber numberWithInt:[textField.text intValue]];
    }
    
    if ([key isKindOfClass:[NSString class]]) {
        [self.configuration setValue:value forKey:key];
    }
    return;
}

#pragma mark - IBAction

- (IBAction)selector:(id)sender {
    // Audio
    if (sender == self.audioAECSegmentedControl) {
        [self.configuration setValue:[NSNumber numberWithInt:(int)self.audioAECSegmentedControl.selectedSegmentIndex] forKey:kMBVoIPConfigurationAudioAECKey];
        return;
    }
    if (sender == self.audioMicGainBeforeAECVolumeSlider) {
        [self.configuration setValue:[NSNumber numberWithFloat:self.audioMicGainBeforeAECVolumeSlider.value] forKey:kMBVoIPConfigurationAudioMicGainBeforeAECVolumeKey];
        return;
    }
    if (sender == self.audioMicGainAfterAECVolumeSlider) {
        [self.configuration setValue:[NSNumber numberWithFloat:self.audioMicGainAfterAECVolumeSlider.value] forKey:kMBVoIPConfigurationAudioMicGainAfterAECVolumeKey];
        return;
    }
    if (sender == self.audioVolumeSlider) {
        [self.configuration setValue:[NSNumber numberWithFloat:self.audioVolumeSlider.value] forKey:kMBVoIPConfigurationAudioVolumeKey];
        return;
    }
    // Input Accessory
    if (sender == self.doneBarButtonItem) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        if ([indexPath isKindOfClass:[NSIndexPath class]]) {
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
        
        return;
    }
    // Navigation
    if (sender == self.saveBarButtonItem) {
        if ([[MBVoIPManager sharedInstance] isStarted]) {
            [[MBVoIPManager sharedInstance] stop];
        }
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        appDelegate.voipConfiguration = self.configuration;
        self.saveBarButtonItem.enabled = NO;
        // Go automatically to the dialer.
        self.tabBarController.selectedIndex = 0;
    }
    return;
}

#pragma mark - property

- (NSMutableDictionary *)configuration {
    NSMutableDictionary *mutableDictionary = _configuration;
    if ([mutableDictionary isKindOfClass:[NSMutableDictionary class]]) {
        return mutableDictionary;
    }
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    mutableDictionary = appDelegate.voipConfiguration;
    self.configuration = mutableDictionary;
    return mutableDictionary;
}

- (void)setConfiguration:(NSMutableDictionary *)configuration {
    NSMutableArray *keys = self.configurationKeys;
    NSMutableDictionary *mutableDictionary = _configuration;
    if ([mutableDictionary isKindOfClass:[NSMutableDictionary class]]) {
        @try {
            for (NSString *key in keys) {
                [mutableDictionary removeObserver:self forKeyPath:key];
            }
        }
        @catch (NSException *exception) {
        }
        @finally {
        }
    }
    mutableDictionary = configuration;
    if ([mutableDictionary isKindOfClass:[NSMutableDictionary class]]) {
        @try {
            for (NSString *key in keys) {
                [mutableDictionary addObserver:self forKeyPath:key options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
            }
        }
        @catch (NSException *exception) {
        }
        @finally {
        }
    }
    _configuration = mutableDictionary;
    self.saveBarButtonItem.enabled = NO;
    
    return;
}

- (NSMutableDictionary *)configurationDataSource {
    if (_configurationDataSource) {
        return _configurationDataSource;
    }
    NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionary];
    // Audio
    /// AGC
    NSMutableArray *audioAGCs = [NSMutableArray array];
    for (int i = 0; i <= 15; i++) {
        NSString *name = [NSString stringWithFormat:@"%d", i];
        NSNumber *value = [NSNumber numberWithInt:i];
        NSMutableDictionary *audioAGC = [NSMutableDictionary dictionary];
        [audioAGC setValue:name forKey:kDictionaryNameKey];
        [audioAGC setValue:value forKey:kDictionaryValueKey];
        
        [audioAGCs addObject:audioAGC];
    }
    [mutableDictionary setValue:audioAGCs forKey:kMBVoIPConfigurationAudioAGCKey];
    /// Denoiser
    NSMutableArray *audioDenoisers = [NSMutableArray array];
    for (int i = 0; i <= 4; i++) {
        NSString *name = [NSString stringWithFormat:@"%d", i];
        NSNumber *value = [NSNumber numberWithInt:i];
        NSMutableDictionary *audioDenoiser = [NSMutableDictionary dictionary];
        [audioDenoiser setValue:name forKey:kDictionaryNameKey];
        [audioDenoiser setValue:value forKey:kDictionaryValueKey];
        
        [audioDenoisers addObject:audioDenoiser];
    }
    [mutableDictionary setValue:audioDenoisers forKey:kMBVoIPConfigurationAudioDenoiserKey];
    // Video
    /// Resolution
    NSMutableArray *videoResolutions = [NSMutableArray array];
    NSMutableDictionary *videoResolution = [NSMutableDictionary dictionary];
    [videoResolution setValue:[NSString stringWithFormat:@"CIF"] forKey:kDictionaryNameKey];
    [videoResolution setValue:[NSNumber numberWithInt:(int)MEDIA_VIDEO_SIZE_CIF] forKey:kDictionaryValueKey];
    [videoResolutions addObject:videoResolution];
    videoResolution = [NSMutableDictionary dictionary];
    [videoResolution setValue:[NSString stringWithFormat:@"VGA"] forKey:kDictionaryNameKey];
    [videoResolution setValue:[NSNumber numberWithInt:(int)MEDIA_VIDEO_SIZE_VGA] forKey:kDictionaryValueKey];
    [videoResolutions addObject:videoResolution];
    videoResolution = [NSMutableDictionary dictionary];
    [videoResolution setValue:[NSString stringWithFormat:@"720p"] forKey:kDictionaryNameKey];
    [videoResolution setValue:[NSNumber numberWithInt:(int)MEDIA_VIDEO_SIZE_720P] forKey:kDictionaryValueKey];
    [videoResolutions addObject:videoResolution];
    videoResolution = [NSMutableDictionary dictionary];
    [videoResolution setValue:[NSString stringWithFormat:@"1080p"] forKey:kDictionaryNameKey];
    [videoResolution setValue:[NSNumber numberWithInt:(int)MEDIA_VIDEO_SIZE_1080p] forKey:kDictionaryValueKey];
    [videoResolutions addObject:videoResolution];
    videoResolution = [NSMutableDictionary dictionary];
    [mutableDictionary setValue:videoResolutions forKey:kMBVoIPConfigurationVideoResolutionKey];
    /// Bitrate
    NSMutableArray *videoBitrates = [NSMutableArray array];
    NSMutableDictionary *videoBitrate = [NSMutableDictionary dictionary];
    [videoBitrate setValue:[NSString stringWithFormat:@"64000"] forKey:kDictionaryNameKey];
    [videoBitrate setValue:[NSNumber numberWithInt:64000] forKey:kDictionaryValueKey];
    [videoBitrates addObject:videoBitrate];
    videoBitrate = [NSMutableDictionary dictionary];
    [videoBitrate setValue:[NSString stringWithFormat:@"128000"] forKey:kDictionaryNameKey];
    [videoBitrate setValue:[NSNumber numberWithInt:128000] forKey:kDictionaryValueKey];
    [videoBitrates addObject:videoBitrate];
    videoBitrate = [NSMutableDictionary dictionary];
    [videoBitrate setValue:[NSString stringWithFormat:@"192000"] forKey:kDictionaryNameKey];
    [videoBitrate setValue:[NSNumber numberWithInt:192000] forKey:kDictionaryValueKey];
    [videoBitrates addObject:videoBitrate];
    videoBitrate = [NSMutableDictionary dictionary];
    [videoBitrate setValue:[NSString stringWithFormat:@"256000"] forKey:kDictionaryNameKey];
    [videoBitrate setValue:[NSNumber numberWithInt:256000] forKey:kDictionaryValueKey];
    [videoBitrates addObject:videoBitrate];
    videoBitrate = [NSMutableDictionary dictionary];
    [videoBitrate setValue:[NSString stringWithFormat:@"384000"] forKey:kDictionaryNameKey];
    [videoBitrate setValue:[NSNumber numberWithInt:384000] forKey:kDictionaryValueKey];
    [videoBitrates addObject:videoBitrate];
    videoBitrate = [NSMutableDictionary dictionary];
    [videoBitrate setValue:[NSString stringWithFormat:@"512000"] forKey:kDictionaryNameKey];
    [videoBitrate setValue:[NSNumber numberWithInt:512000] forKey:kDictionaryValueKey];
    [videoBitrates addObject:videoBitrate];
    videoBitrate = [NSMutableDictionary dictionary];
    [videoBitrate setValue:[NSString stringWithFormat:@"768000"] forKey:kDictionaryNameKey];
    [videoBitrate setValue:[NSNumber numberWithInt:768000] forKey:kDictionaryValueKey];
    [videoBitrates addObject:videoBitrate];
    videoBitrate = [NSMutableDictionary dictionary];
    [videoBitrate setValue:[NSString stringWithFormat:@"1024000"] forKey:kDictionaryNameKey];
    [videoBitrate setValue:[NSNumber numberWithInt:1024000] forKey:kDictionaryValueKey];
    [videoBitrates addObject:videoBitrate];
    videoBitrate = [NSMutableDictionary dictionary];
    [videoBitrate setValue:[NSString stringWithFormat:@"1536000"] forKey:kDictionaryNameKey];
    [videoBitrate setValue:[NSNumber numberWithInt:1536000] forKey:kDictionaryValueKey];
    [videoBitrates addObject:videoBitrate];
    videoBitrate = [NSMutableDictionary dictionary];
    [videoBitrate setValue:[NSString stringWithFormat:@"2048000"] forKey:kDictionaryNameKey];
    [videoBitrate setValue:[NSNumber numberWithInt:2048000] forKey:kDictionaryValueKey];
    [videoBitrates addObject:videoBitrate];
    videoBitrate = [NSMutableDictionary dictionary];
    [videoBitrate setValue:[NSString stringWithFormat:@"4096000"] forKey:kDictionaryNameKey];
    [videoBitrate setValue:[NSNumber numberWithInt:4096000] forKey:kDictionaryValueKey];
    [videoBitrates addObject:videoBitrate];
    [mutableDictionary setValue:videoBitrates forKey:kMBVoIPConfigurationVideoBitrateKey];
    self.configurationDataSource = mutableDictionary;
    return _configurationDataSource;
}

- (NSMutableArray *)configurationKeys {
    if (_configurationKeys) {
        return _configurationKeys;
    }
    NSMutableArray *mutableArray = [NSMutableArray array];
    // VoIP
    [mutableArray addObject:kMBVoIPConfigurationUsernameKey];
    [mutableArray addObject:kMBVoIPConfigurationPasswordKey];
    [mutableArray addObject:kMBVoIPConfigurationRegisterIPKey];
    [mutableArray addObject:kMBVoIPConfigurationRegisterPortKey];
    //[mutableArray addObject:kMBVoIPConfigurationLocalIPKey];
    [mutableArray addObject:kMBVoIPConfigurationLocalPortKey];
    [mutableArray addObject:kMBVoIPConfigurationDisplayNameKey];
    [mutableArray addObject:kMBVoIPConfigurationAudioCodecEnableG711AKey];
    [mutableArray addObject:kMBVoIPConfigurationAudioCodecEnableG711UKey];
    [mutableArray addObject:kMBVoIPConfigurationAudioCodecEnableG729Key];
    [mutableArray addObject:kMBVoIPConfigurationAudioCodecEnableG723Key];
    [mutableArray addObject:kMBVoIPConfigurationAudioCodecEnableAMRKey];
    [mutableArray addObject:kMBVoIPConfigurationAudioCodecEnableAMRWBKey];
    [mutableArray addObject:kMBVoIPConfigurationAudioCodecEnableAACKey];
    [mutableArray addObject:kMBVoIPConfigurationAudioCodecEnableiLBCKey];
    [mutableArray addObject:kMBVoIPConfigurationAudioCodecEnableSILKKey];
    [mutableArray addObject:kMBVoIPConfigurationAudioCodecEnableGSMKey];
    [mutableArray addObject:kMBVoIPConfigurationAudioCodecEnableG722Key];
    [mutableArray addObject:kMBVoIPConfigurationAudioCodecEnableFECKey];
    [mutableArray addObject:kMBVoIPConfigurationAudioCodecEnableKeysKey];
    //[mutableArray addObject:kMBVoIPConfigurationVideoCodecEnableH263Key];
    [mutableArray addObject:kMBVoIPConfigurationVideoCodecEnableH264Key];
    [mutableArray addObject:kMBVoIPConfigurationVideoCodecEnableFECKey];
    [mutableArray addObject:kMBVoIPConfigurationVideoCodecEnableKeysKey];
    // Audio
    [mutableArray addObject:kMBVoIPConfigurationAudioAECKey];
    [mutableArray addObject:kMBVoIPConfigurationAudioAGCKey];
    [mutableArray addObject:kMBVoIPConfigurationAudioDenoiserKey];
    [mutableArray addObject:kMBVoIPConfigurationAudioMicGainBeforeAECVolumeKey];
    [mutableArray addObject:kMBVoIPConfigurationAudioMicGainAfterAECVolumeKey];
    [mutableArray addObject:kMBVoIPConfigurationAudioVolumeKey];
    // Video
    [mutableArray addObject:kMBVoIPConfigurationVideoResolutionKey];
    [mutableArray addObject:kMBVoIPConfigurationVideoBitrateKey];
    [mutableArray addObject:kMBVoIPConfigurationVideoFramerateKey];
    [mutableArray addObject:kMBVoIPConfigurationVideoIframeRequestKey];
    [mutableArray addObject:kMBVoIPConfigurationVideoIframeIntervalKey];
    self.configurationKeys = mutableArray;
    return mutableArray;
}

#pragma mark - NSKeyValueObserving

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self.configuration) {
        if (self.saveBarButtonItem.enabled == NO) {
            self.saveBarButtonItem.enabled = YES;
        }
    }
    
    return;
}

@end
