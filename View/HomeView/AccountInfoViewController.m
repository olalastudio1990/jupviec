//
//  AccountInfoViewController.m
//  JupViec
//
//  Created by Khanhlt on 12/16/19.
//  Copyright © 2019 Olala. All rights reserved.
//

#import "AccountInfoViewController.h"
#import "EditAccountInfoViewController.h"
#import "LoginWithPasswordViewController.h"
#import "HomeViewController.h"
#import "CommonDefines.h"

@interface AccountInfoViewController ()

@end

@implementation AccountInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [_addressLb setTextColor:UIColorFromRGB(0xACB3BF)];
    [_phoneNumLb setTextColor:UIColorFromRGB(0xACB3BF)];
    [_emailLb setTextColor:UIColorFromRGB(0xACB3BF)];
    [_logoutBtn setTitleColor:UIColorFromRGB(0xFF5B14) forState:UIControlStateNormal];
    
    self.view.layer.masksToBounds = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tabBarController.tabBar setHidden:NO];
    [self.navigationController.navigationBar setHidden:YES];
}

-(void)updateContentView
{
    if (_user) {
        _generalInfo = [_user dictUserInfo];
        if ([[_generalInfo objectForKey:@"name"] isKindOfClass:[NSString class]]) {
            _usernameLb.text = [_generalInfo objectForKey:@"name"];
        }
        else{
            _usernameLb.text = @"Không có sẵn";
        }
        
        if ([[_generalInfo objectForKey:@"address"] isKindOfClass:[NSString class]]) {
            _addressLb.text = [_generalInfo objectForKey:@"address"];
        }
        else{
            _addressLb.text = @"Không có sẵn";
        }
        
        if ([[_generalInfo objectForKey:@"email"] isKindOfClass:[NSString class]]) {
            _emailLb.text = [_generalInfo objectForKey:@"email"];
        }
        else{
            _emailLb.text = @"Không có sẵn";
        }
        
        _phoneNumLb.text = [_user userPhoneNum];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"idshoweditaccountinfo"])
    {
        EditAccountInfoViewController* editAccountInfoVC = segue.destinationViewController;
        editAccountInfoVC.user = _user;
        editAccountInfoVC.tokenStr = _tokenStr;
    }
}

- (IBAction)didPressLogoutButton:(id)sender
{
    HomeViewController *homeview;
    
    for (UINavigationController *item in [self.tabBarController viewControllers])
    {
        UIViewController *viewcontroll = [item visibleViewController];
        
        if ([viewcontroll isKindOfClass:[HomeViewController class]])
        {
            homeview = (HomeViewController*)viewcontroll;
            
            [homeview logOut];
            break;
        }
    }
    
    LoginWithPasswordViewController *loginview = [self.storyboard instantiateViewControllerWithIdentifier:@"idloginview"];
    [self.navigationController setViewControllers:@[loginview] animated:YES];
    
    _user = nil;
    _tokenStr = @"";
}
@end
