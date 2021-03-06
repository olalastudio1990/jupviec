//
//  ViewController.m
//  JupViec
//
//  Created by KienVu on 11/28/19.
//  Copyright © 2019 Olala. All rights reserved.
//

#import "ViewController.h"
#import "HomeViewController.h"
#import "APIRequest.h"
#import "CommonDefines.h"
#import "LoadingViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [_btskip setTitleColor:UIColorFromRGB(0xFF5B14) forState:UIControlStateNormal];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //show welcome view at the first launch
    BOOL isSecondLaunch = [[[NSUserDefaults standardUserDefaults] objectForKey:@"isSecondLaunch"] boolValue];
    if (!isSecondLaunch)
    {
        [_btStart setHidden:NO];
        [_btskip setHidden:NO];
        [self setupWelcomeView];
    }
    else{
        [_btStart setHidden:YES];
        [_btskip setHidden:YES];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    BOOL isSecondLaunch = [[[NSUserDefaults standardUserDefaults] objectForKey:@"isSecondLaunch"] boolValue];
    if (isSecondLaunch)
    {
        [self getStart];
    }
}

-(void)setupWelcomeView
{
    
    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                          navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                        options:nil];
    self.pageController.delegate = self;
    self.pageController.dataSource = self;
    
    [[self.pageController view] setFrame:[[self contentArea] bounds]];
    
    WelcomeViewController *initialViewController = [self viewControllerAtIndex:0];
    
    NSArray *viewControllers = [NSArray arrayWithObject:initialViewController];
    
    [self.pageController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    
    [self addChildViewController:self.pageController];
    [[self contentArea] addSubview:[self.pageController view]];
    
    [self.pageController didMoveToParentViewController:self];
    [self addPageControll];
    
    [_btskip setHidden:NO];
    [_btStart setHidden:YES];
}

-(WelcomeViewController*)viewControllerAtIndex:(NSInteger)index
{
    WelcomeViewController *welcomeViewController = [self.storyboard instantiateViewControllerWithIdentifier:ID_WELCOME_VIEW];
    [welcomeViewController setIndex:index];
    [welcomeViewController.view setFrame:[self.view frame]];
    
    return welcomeViewController;
}

-(void)addPageControll
{
    self.pageControll = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 130, self.view.frame.size.width, 50)];
    [self.pageControll setPageIndicatorTintColor:[UIColor colorWithRed:255.0f/255.0f green:143.0f/255.0f blue:96.0f/255.0f alpha:0.3]];
    [self.pageControll setCurrentPageIndicatorTintColor:UIColorFromRGB(0xFF8F60)];
    [self.pageControll setHidesForSinglePage:YES];
    [self.pageControll setNumberOfPages:3];
    [self.pageControll setCurrentPage:0];
    
    [self.pageControll sizeToFit];
    
    CGRect frame = [self.pageControll frame];
    frame.origin.x = (self.view.frame.size.width - frame.size.width)/2;
    
    [self.pageControll setFrame:frame];
    
    [self.view addSubview:self.pageControll];
}

#pragma mark - PageViewDelegate
-(void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers
{
    WelcomeViewController *welcomeviewcontroller = (WelcomeViewController*)pendingViewControllers[0];
    
    [self.pageControll setCurrentPage:[welcomeviewcontroller index]];
    [self.pageControll updateCurrentPageDisplay];
    
    switch ([welcomeviewcontroller index]) {
        case 0:
        case 1:
            [_btStart setHidden:YES];
            [_btskip setHidden:NO];
            break;
        case 2:
            [_btStart setHidden:NO];
            [_btskip setHidden:YES];
        default:
            break;
    }
}

-(UIViewController*)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSInteger index = [(WelcomeViewController*)viewController index];
    
    index++;
    if (index > 2) {
        
        return nil;
    }
    
    return [self viewControllerAtIndex:index];
}

-(UIViewController*)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSInteger index = [(WelcomeViewController*)viewController index];
    
    if (index == 0) {
        [_btskip setHidden:NO];
        [_btStart setHidden:YES];
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

#pragma mark -
#pragma mark WelcomeViewDelegate
-(void)getStart
{
    NSLog(@"did press start or skip");
    LoadingViewController *loadingview = [self.storyboard instantiateViewControllerWithIdentifier:@"idloadingview"];
    [loadingview show:self];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        UITabBarController *tabController = (UITabBarController*)[self.storyboard instantiateViewControllerWithIdentifier:@"idTabBarView"];
        [tabController setSelectedIndex:0];
        
        HomeViewController *homeVC = (HomeViewController*)[(UINavigationController*)[[tabController viewControllers] objectAtIndex:0] visibleViewController];
        
        // get info of services
        APIRequest* apiRequest = [[APIRequest alloc]init];
        [apiRequest requestAPIGetConfiguration:^(NSDictionary * _Nullable configurationInfo, NSError * _Nonnull error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error.code == RESPONSE_CODE_NORMARL && configurationInfo) {
                    homeVC.configurationInfoDict = configurationInfo;
                    
                    //get coupon
                    [apiRequest requestAPIGetNotifiesWithType:@"" notifyType:NOTIFIES_TYPE_PROMOTION completionHandler:^(NSArray * _Nullable resultDict, NSError * _Nonnull error) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                        
                            [loadingview dismiss];
                            
                            if (error.code == 200 ){
                                [homeVC setCouponArray:[NSMutableArray arrayWithArray:resultDict]];
                            }
                            else if (error.code == RESPONSE_CODE_NODATA){
                                [JUntil showPopup:self responsecode:RESPONSE_CODE_NODATA];
                            }
                            else if (error.code == RESPONSE_CODE_TIMEOUT){
                                [JUntil showPopup:self responsecode:RESPONSE_CODE_TIMEOUT];
                            }
                            else{
                                [JUntil showPopup:self responsecode:RESPONSE_CODE_OTHER];
                            }
                            
                            appdelegate.window.rootViewController = tabController;
                            [appdelegate.window makeKeyAndVisible];
                        
                            [self.pageController removeFromParentViewController];
                            [self.pageController.view removeFromSuperview];
                            [self.pageControll removeFromSuperview];
                            
                            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isSecondLaunch"];
                        });
                    }];
                }
                else if (error.code == RESPONSE_CODE_NODATA){
                    [JUntil showPopup:self responsecode:RESPONSE_CODE_NODATA];
                }
                else if (error.code == RESPONSE_CODE_TIMEOUT){
                    [JUntil showPopup:self responsecode:RESPONSE_CODE_TIMEOUT];
                }
                else if (error.code == RESPONSE_CODE_NOINTERNET){
                    [JUntil showPopup:self responsecode:RESPONSE_CODE_NOINTERNET];
                }
                else{
                    [JUntil showPopup:self responsecode:RESPONSE_CODE_OTHER];
                }
            });
        }];
    });
}

- (IBAction)didPressSkipButton:(id)sender
{
    [self getStart];
}

- (IBAction)didPressStartButton:(id)sender
{
    [self getStart];
}
@end
