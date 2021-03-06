//
//  HomePromotionHeaderViewCell.h
//  JupViec
//
//  Created by KienVu on 12/3/19.
//  Copyright © 2019 Olala. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol HomePromotionHeaderDelegate <NSObject>

-(void)didClickViewMorePromotion;

@end

@interface HomePromotionHeaderViewCell : UITableViewHeaderFooterView

@property id<HomePromotionHeaderDelegate>   delegate;

@property (weak, nonatomic) IBOutlet UILabel *txtPromotion;
@property (weak, nonatomic) IBOutlet UIButton *btViewMore;

- (IBAction)didPressViewMoreButton:(id)sender;


@end

NS_ASSUME_NONNULL_END
