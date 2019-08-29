#import "SettingsCodecsViewController.h"
#import "AppDelegate.h"
#import "AppDelegate+MBVoIP.h"
#import "SwitchTableViewCell.h"

@interface SettingsCodecsViewController ()

// data sources
@property (strong, nonatomic) NSMutableDictionary *configurationDataSource;

@end

@implementation SettingsCodecsViewController

static NSString * const kAssociatedCodecEnableKey = @"associated_codec_enable";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.clearsSelectionOnViewWillAppear = YES;
    
    return;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tableView setEditing:YES animated:animated];
    
    return;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        NSArray *audioCodecEnableKeys = [self.configuration valueForKey:kMBVoIPConfigurationAudioCodecEnableKeysKey];
        return [audioCodecEnableKeys count];
    }
    else if (section == 1) {
        NSArray *videoCodecEnableKeys = [self.configuration valueForKey:kMBVoIPConfigurationVideoCodecEnableKeysKey];
        return [videoCodecEnableKeys count];
    }
    else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"SwitchTableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    if ([cell isKindOfClass:[SwitchTableViewCell class]] == NO) {
        return cell;
    }
    SwitchTableViewCell *switchTableViewCell = (SwitchTableViewCell *)cell;
    NSString *codecEnableKey = nil;
    switch (indexPath.section) {
        case 0: {
            NSArray *audioCodecEnableKeys = [self.configuration valueForKey:kMBVoIPConfigurationAudioCodecEnableKeysKey];
            codecEnableKey = [audioCodecEnableKeys objectAtIndex:indexPath.row];
        }
            break;
        case 1: {
            NSArray *videoCodecEnableKeys = [self.configuration valueForKey:kMBVoIPConfigurationVideoCodecEnableKeysKey];
            codecEnableKey = [videoCodecEnableKeys objectAtIndex:indexPath.row];
        }
            break;
            
        default:
            break;
    }
    if ([codecEnableKey isKindOfClass:[NSString class]] == NO) {
        return cell;
    }
    switchTableViewCell.label.text = [self.configurationDataSource valueForKey:codecEnableKey];
    switchTableViewCell.switchControl.on = [[self.configuration valueForKey:codecEnableKey] boolValue];
    objc_setAssociatedObject(switchTableViewCell.switchControl, (void *)&kAssociatedCodecEnableKey, codecEnableKey, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSArray *audioCodecEnableKeys = [self.configuration valueForKey:kMBVoIPConfigurationAudioCodecEnableKeysKey];
    if ([audioCodecEnableKeys isKindOfClass:[NSArray class]] == NO) {
        return 0;
    }
    NSArray *videoCodecEnableKeys = [self.configuration valueForKey:kMBVoIPConfigurationVideoCodecEnableKeysKey];
    if ([videoCodecEnableKeys isKindOfClass:[NSArray class]] == NO) {
        return 0;
    }
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return [NSString stringWithFormat:@"Audio"];
    }
    else if (section == 1) {
        return [NSString stringWithFormat:@"Video"];
    }
    else {
        return nil;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    if (sourceIndexPath.section != destinationIndexPath.section) {
        return;
    }
    if (sourceIndexPath.row == destinationIndexPath.row) {
        return;
    }
    if (sourceIndexPath.section == 0) {
        NSMutableArray *audioCodecEnableKeys = [NSMutableArray arrayWithArray:[self.configuration valueForKey:kMBVoIPConfigurationAudioCodecEnableKeysKey]];
        id object = [audioCodecEnableKeys objectAtIndex:sourceIndexPath.row];
        [audioCodecEnableKeys removeObjectAtIndex:sourceIndexPath.row];
        [audioCodecEnableKeys insertObject:object atIndex:destinationIndexPath.row];
        [self.configuration setValue:audioCodecEnableKeys forKey:kMBVoIPConfigurationAudioCodecEnableKeysKey];
    }
    else if (sourceIndexPath.section == 1) {
        NSMutableArray *videoCodecEnableKeys = [NSMutableArray arrayWithArray:[self.configuration valueForKey:kMBVoIPConfigurationVideoCodecEnableKeysKey]];
        id object = [videoCodecEnableKeys objectAtIndex:sourceIndexPath.row];
        [videoCodecEnableKeys removeObjectAtIndex:sourceIndexPath.row];
        [videoCodecEnableKeys insertObject:object atIndex:destinationIndexPath.row];
        [self.configuration setValue:videoCodecEnableKeys forKey:kMBVoIPConfigurationVideoCodecEnableKeysKey];
    }
}

#pragma mark - UITableViewDelegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
    if (sourceIndexPath.section == proposedDestinationIndexPath.section) {
        return proposedDestinationIndexPath;
    }
    else {
        return sourceIndexPath;
    }
}

#pragma mark - IBAction

- (IBAction)selector:(id)sender {
    if ([sender isKindOfClass:[UISwitch class]]) {
        UISwitch *switchControl = sender;
        NSString *codecEnableKey = objc_getAssociatedObject(switchControl, (void *)&kAssociatedCodecEnableKey);
        if ([codecEnableKey isKindOfClass:[NSString class]]) {
            [self.configuration setValue:[NSNumber numberWithBool:switchControl.on] forKey:codecEnableKey];
        }
        
        return;
    }
}

#pragma mark - property

- (NSMutableDictionary *)configurationDataSource {
    if (_configurationDataSource) {
        return _configurationDataSource;
    }
    NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionary];
    // audio
    [mutableDictionary setValue:@"G711A" forKey:kMBVoIPConfigurationAudioCodecEnableG711AKey];
    [mutableDictionary setValue:@"G711U" forKey:kMBVoIPConfigurationAudioCodecEnableG711UKey];
    [mutableDictionary setValue:@"G729" forKey:kMBVoIPConfigurationAudioCodecEnableG729Key];
    [mutableDictionary setValue:@"G7231" forKey:kMBVoIPConfigurationAudioCodecEnableG723Key];
    [mutableDictionary setValue:@"AMRNB" forKey:kMBVoIPConfigurationAudioCodecEnableAMRKey];
    [mutableDictionary setValue:@"AMRWB" forKey:kMBVoIPConfigurationAudioCodecEnableAMRWBKey];
    [mutableDictionary setValue:@"AAC" forKey:kMBVoIPConfigurationAudioCodecEnableAACKey];
    [mutableDictionary setValue:@"ILBC" forKey:kMBVoIPConfigurationAudioCodecEnableiLBCKey];
    [mutableDictionary setValue:@"SILK" forKey:kMBVoIPConfigurationAudioCodecEnableSILKKey];
    [mutableDictionary setValue:@"GSM" forKey:kMBVoIPConfigurationAudioCodecEnableGSMKey];
    [mutableDictionary setValue:@"G722" forKey:kMBVoIPConfigurationAudioCodecEnableG722Key];
    [mutableDictionary setValue:@"FEC AUDIO" forKey:kMBVoIPConfigurationAudioCodecEnableFECKey];
    // video
    //[mutableDictionary setValue:@"H263" forKey:kMBVoIPConfigurationVideoCodecEnableH263Key];
    [mutableDictionary setValue:@"H264" forKey:kMBVoIPConfigurationVideoCodecEnableH264Key];
    [mutableDictionary setValue:@"FEC VIDEO" forKey:kMBVoIPConfigurationVideoCodecEnableFECKey];
    self.configurationDataSource = mutableDictionary;
    
    return _configurationDataSource;
}

@end
