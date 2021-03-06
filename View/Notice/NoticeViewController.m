//
//  NoticeViewController.m
//  JupViec
//
//  Created by KienVu on 12/3/19.
//  Copyright © 2019 Olala. All rights reserved.
//

#import "NoticeViewController.h"
#import "NoticeTableViewCell.h"
#import "CouponTableViewCell.h"
#import "NoticeDetailViewController.h"
#import "APIRequest.h"
#import "CommonDefines.h"
#import "JUntil.h"

@interface NoticeViewController ()
{
    NSMutableArray *_listNotices;
    NSMutableArray *_listCoupons;
}

@end

@implementation NoticeViewController
@synthesize user = _user;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [_lbNoData setTextColor:UIColorFromRGB(0x5C5C5C)];
    [_separationView setBackgroundColor:UIColorFromRGB(0xEBEBEB)];
    [_categoriesSelectionView setBackgroundColor:[UIColor colorWithRed:240.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:0.21]];
    [_categoriesSelectionView.layer setCornerRadius:10];
    [_categoriesSelectionView.layer setBorderWidth:1];
    [_categoriesSelectionView.layer setBorderColor:[UIColor colorWithRed:218.0f/255.0f green:218.0f/255.0f blue:218.0f/255.0f alpha:0.51].CGColor];
    
    _listNotices = [[NSMutableArray alloc] initWithCapacity:0];
    
    if (!_listCoupons) {
        _listCoupons = [[NSMutableArray alloc] initWithCapacity:0];
    }
    
    [_tbNotice registerNib:[UINib nibWithNibName:@"NoticeCell" bundle:nil] forCellReuseIdentifier:@"idnoticecell"];
    [_tbNotice registerNib:[UINib nibWithNibName:@"CouponCell" bundle:nil] forCellReuseIdentifier:@"idcouponcell"];
    
    [_tbNotice setDelegate:self];
    [_tbNotice setDataSource:self];
    
    [_tbNotice setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_tbNotice setBackgroundColor:[UIColor whiteColor]];
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName: [UIFont fontWithName:@"Comfortaa-Regular" size:20]}];
    
    [self configPullToRefreshControl];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setHidden:YES];
    [self.tabBarController.tabBar setHidden:NO];
    
    [self showSelectedList];
    
    if ([_listNotices count] == 0) {
        [self getNotice];
    }
    
    if ([_listCoupons count] == 0) {
        [self getCoupon];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.navigationController.navigationBar setHidden:NO];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

-(void)configPullToRefreshControl
{
    UIRefreshControl *refreshControll = [[UIRefreshControl alloc] init];
    [refreshControll addTarget:self action:@selector(willRefreshContent) forControlEvents:UIControlEventValueChanged];
    
    _tbNotice.refreshControl = refreshControll;
}

-(void)willRefreshContent
{
    if (_selectedNotice == NOTICE_CHOISE_NOTICE)
    {
        APIRequest *apirequest = [[APIRequest alloc] init];
        [apirequest requestAPIGetNotifiesWithType:[_user userToken] notifyType:NOTIFIES_TYPE_NOTIFY completionHandler:^(NSArray * _Nullable resultDict, NSError * _Nonnull error)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.tbNotice.refreshControl endRefreshing];
                
                if (error.code == 200) {
                    [self showNotice:resultDict];
                }
            });
        }];
    }
    else
    {
        APIRequest *apirequest = [[APIRequest alloc] init];
        [apirequest requestAPIGetNotifiesWithType:[_user userToken] notifyType:NOTIFIES_TYPE_PROMOTION completionHandler:^(NSArray * _Nullable resultDict, NSError * _Nonnull error)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.tbNotice.refreshControl endRefreshing];
                
                if (error.code == 200) {
                    [self showCoupon:resultDict];
                }
            });
        }];
    }
}

-(void)setUser:(User *)user
{
    _user = user;
}

- (User *)user
{
    return _user;
}

-(void)getNotice
{
    APIRequest *apirequest = [[APIRequest alloc] init];
    [apirequest requestAPIGetNotifiesWithType:[_user userToken] notifyType:NOTIFIES_TYPE_NOTIFY completionHandler:^(NSArray * _Nullable resultDict, NSError * _Nonnull error)
    {
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (error.code == 200) {
                [self showNotice:resultDict];
            }
            else if (error.code == RESPONSE_CODE_NODATA)
            {
                [JUntil showPopup:self responsecode:RESPONSE_CODE_NODATA];
            }
            else if (error.code == RESPONSE_CODE_TIMEOUT)
            {
                [JUntil showPopup:self responsecode:RESPONSE_CODE_TIMEOUT];
            }
            else
            {
                [JUntil showPopup:self responsecode:RESPONSE_CODE_OTHER];
            }
        });
    }];
}

-(void)getCoupon
{
    APIRequest *apirequest = [[APIRequest alloc] init];
    [apirequest requestAPIGetNotifiesWithType:[_user userToken] notifyType:NOTIFIES_TYPE_PROMOTION completionHandler:^(NSArray * _Nullable resultDict, NSError * _Nonnull error)
    {
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (error.code == 200) {
                [self showCoupon:resultDict];
            }
            else if (error.code == RESPONSE_CODE_NODATA)
            {
                [JUntil showPopup:self responsecode:RESPONSE_CODE_NODATA];
            }
            else if (error.code == RESPONSE_CODE_TIMEOUT)
            {
                [JUntil showPopup:self responsecode:RESPONSE_CODE_TIMEOUT];
            }
            else
            {
                [JUntil showPopup:self responsecode:RESPONSE_CODE_OTHER];
            }
        });
    }];
}

-(void)showNotice:(NSArray*)notices
{
    _listNotices = [self sortArray:notices];
    
    [self showSelectedList];
    
    [_tbNotice reloadData];
}

-(void)showCoupon:(NSArray*)coupons
{
    _listCoupons = [self sortArray:coupons];
    
    [self showSelectedList];
    
    [_tbNotice reloadData];
}

- (IBAction)didSelectNoticeType:(id)sender
{
    if ([_listNotices count] == 0)
    {
        [self getNotice];
    }
    else{
        [self showNoticeView];
    }
    
}

- (IBAction)didSelectPromotionType:(id)sender
{
    if ([_listCoupons count] == 0)
    {
        [self getCoupon];
    }
    else{
        [self showCouponView];
    }
}

-(void)showCouponView
{
    _selectedNotice = NOTICE_CHOISE_COUPON;
    
    [_btNotice setTitleColor:UIColorFromRGB(0x000000) forState:UIControlStateNormal];
    [_btPromotion setTitleColor:UIColorFromRGB(0xFF7E46) forState:UIControlStateNormal];
    
    [_tbNotice reloadData];
}

-(void)showNoticeView
{
    _selectedNotice = NOTICE_CHOISE_NOTICE;
    
    [_btNotice setTitleColor:UIColorFromRGB(0xFF7E46) forState:UIControlStateNormal];
    [_btPromotion setTitleColor:UIColorFromRGB(0x000000) forState:UIControlStateNormal];
    
    [_tbNotice reloadData];
}

-(NSMutableArray*)sortArray:(NSArray*)array
{
    NSArray *sortedarray = [array sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2)
    {
        static NSDateFormatter *dateFormatter = nil;

        if (!dateFormatter) {
            dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSZ";
        }

        NSString *date1String = [obj1 valueForKey:ID_UPDATE_DATE];
        NSString *date2String = [obj2 valueForKey:ID_UPDATE_DATE];

        NSDate *date1 = [dateFormatter dateFromString:date1String];
        NSDate *date2 = [dateFormatter dateFromString:date2String];

        return [date1 compare:date2];
    }];
    
    NSMutableArray *sortedlist = [[NSMutableArray alloc] initWithCapacity:0];
    for (int i = [sortedarray count] - 1; i >= 0; i--)
    {
        [sortedlist addObject:[sortedarray objectAtIndex:i]];
    }
    
    return sortedlist;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)showSelectedList
{
    if (_selectedNotice == NOTICE_CHOISE_NOTICE)
    {
        [_btNotice setTitleColor:UIColorFromRGB(0xFF7E46) forState:UIControlStateNormal];
        [_btPromotion setTitleColor:UIColorFromRGB(0x000000) forState:UIControlStateNormal];
    }
    else
    {
        [_btPromotion setTitleColor:UIColorFromRGB(0xFF7E46) forState:UIControlStateNormal];
        [_btNotice setTitleColor:UIColorFromRGB(0x000000) forState:UIControlStateNormal];
    }
}

-(NSMutableArray*)getSelectedList
{
    if (_selectedNotice == NOTICE_CHOISE_NOTICE)
   {
       if ([_listNotices count] == 0)
       {
           [_tbNotice setHidden:YES];
           [_lbNoData setHidden:NO];
           
           [_lbNoData setText:@"Danh sách thông báo chưa có dữ liệu"];
       }
       else{
           [_tbNotice setHidden:NO];
           [_lbNoData setHidden:YES];
       }
       
       return _listNotices;
   }
   else if (_selectedNotice == NOTICE_CHOISE_COUPON)
   {
       if ([_listCoupons count] == 0)
       {
           [_tbNotice setHidden:YES];
           [_lbNoData setHidden:NO];
           
           [_lbNoData setText:@"Danh sách khuyến mại chưa có dữ liệu"];
       }
       else{
           [_tbNotice setHidden:NO];
           [_lbNoData setHidden:YES];
       }
       
       return _listCoupons;
   }
    
    return [[NSMutableArray alloc] initWithCapacity:0];
}

#pragma mark - TableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self getSelectedList] count];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_selectedNotice == NOTICE_CHOISE_NOTICE)
    {
        NoticeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"idnoticecell"];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell setNoticeInfo:[_listNotices objectAtIndex:indexPath.row]];
        
        return cell;
    }
    else if (_selectedNotice == NOTICE_CHOISE_COUPON)
    {
        CouponTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"idcouponcell"];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell setNotifyCoupon:[_listCoupons objectAtIndex:indexPath.row]];
        return cell;
    }
    
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_selectedNotice == NOTICE_CHOISE_NOTICE)
    {
        return 130;
    }
    else if (_selectedNotice == NOTICE_CHOISE_COUPON)
    {
        return 167;
    }
    
    return 50;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NoticeDetailViewController *detailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"idnoticedetail"];
    if (_selectedNotice == NOTICE_CHOISE_NOTICE)
    {
        [detailViewController setNotifyInfo:[_listNotices objectAtIndex:indexPath.row]];
    }
    else if (_selectedNotice == NOTICE_CHOISE_COUPON)
    {
        [detailViewController setNotifyInfo:[_listCoupons objectAtIndex:indexPath.row]];
    }
    
    UIViewController *topview = [self.navigationController topViewController];
    
    if (![topview isKindOfClass:[NoticeDetailViewController class]])
    {
        [self.navigationController pushViewController:detailViewController animated:YES];
    }
}
@end
