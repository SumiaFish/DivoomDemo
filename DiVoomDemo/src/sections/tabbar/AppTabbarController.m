//
//  AppTabbarController.m
//  DiVoomDemo
//
//  Created by kevin on 2020/5/28.
//  Copyright © 2020 kevin. All rights reserved.
//

#import "AppTabbarController.h"

#import "AppNavigationController.h"

#import "HomeViewController.h"
#import "ChannelViewController.h"
#import "DrawViewController.h"
#import "DiscoverViewController.h"
#import "PersonalViewController.h"

@interface AppTabbarController ()

@end

@implementation AppTabbarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.whiteColor;
    
    NSMutableArray *vcs = NSMutableArray.array;
    for (NSInteger i = 0; i < 5; i++) {
        UIViewController *vc = nil;
        NSString *title = @"";
        if (i == 0) {
            vc = HomeViewController.new;
            title = @"Home";
        } else if (i == 1) {
            vc = ChannelViewController.new;
            title = @"Channel";
        } else if (i == 2) {
            vc = DrawViewController.new;
            title = @"Draw";
        } else if (i == 3) {
            vc = DiscoverViewController.new;
            title = @"Discover";
        } else if (i == 4) {
            vc = PersonalViewController.new;
            title = @"Personal";
        }
        
        AppNavigationController *nav = [[AppNavigationController alloc] initWithRootViewController:vc];
        nav.title = title;
        vc.title = title;
        [vcs addObject:nav];
        
        nav.tabBarItem = [[UITabBarItem alloc] initWithTitle:title image:nil tag:i];
        
    }
    self.viewControllers = vcs;
    
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
