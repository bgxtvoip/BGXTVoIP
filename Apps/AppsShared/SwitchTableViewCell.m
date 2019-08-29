#import "SwitchTableViewCell.h"

@implementation SwitchTableViewCell

#pragma mark - NSObject(UINibLoadingAdditions)

- (void)awakeFromNib {
    return;
}

#pragma mark - UITableViewCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    return;
}

@end
