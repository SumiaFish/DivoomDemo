//
//  DrawViewController.m
//  DiVoomDemo
//
//  Created by kevin on 2020/5/28.
//  Copyright © 2020 kevin. All rights reserved.
//

#import "DrawViewController.h"
#import "WhiteboardViewController.h"

@interface DrawViewController ()

@end

@implementation DrawViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"whiteboard" style:(UIBarButtonItemStylePlain) target:self action:@selector(pushWhiteboard)];
    self.navigationItem.rightBarButtonItem = item;
}

- (void)pushWhiteboard {
    [self.navigationController pushViewController:[WhiteboardViewController new] animated:YES];
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
