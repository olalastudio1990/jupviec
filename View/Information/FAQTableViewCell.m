//
//  FAQTableViewCell.m
//  JupViec
//
//  Created by Khanhlt on 1/15/20.
//  Copyright © 2020 Olala. All rights reserved.
//

#import "FAQTableViewCell.h"
#import "CommonDefines.h"

@implementation FAQTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _contentLabel.numberOfLines = 0;
    [_contentLabel setText:@""];
    
    [_titleLabel setTextColor:[UIColor blackColor]];
    [_contentLabel setTextColor:UIColorFromRGB(0xACB3BF)];
    [_separateLine setBackgroundColor:UIColorFromRGB(0xF0F0F0)];
    
    [self setBackgroundColor:[UIColor whiteColor]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)didClickShowContentAction:(id)sender {
    if (_isShowContent == NO)
    {
        _isShowContent = YES;
    }
    else
    {
        _isShowContent = NO;
    }
    if ([self.delegate respondsToSelector:@selector(showFAQContentInfo:)])
    {
        [self.delegate showFAQContentInfo:_indexPath];
    }
}
@end
