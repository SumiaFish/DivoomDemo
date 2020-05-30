//
//  UIViewController+SimpleAlert.m
//  youlian
//
//  Created by hlw on 2019/5/9.
//  Copyright © 2019 youlian. All rights reserved.
//

#import "UIViewController+SimpleAlert.h"

@implementation UIViewController (SimpleAlert)

- (void)simpleAlertWithTitle:(NSString *)title msg:(NSString *)msg
{
    title = title? title: @"提示";
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:(UIAlertControllerStyleAlert)];
    
    __weak typeof(alert) ws = alert;
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        [ws dismissViewControllerAnimated:YES completion:nil];
    }];
    [alert addAction:action];
    
    [self presentViewController:alert animated:YES completion:nil];
}


- (void)simpleAlert:(NSString *)msg
{
    [self simpleAlertWithTitle:@"提示" msg:msg];
}

- (void)simpleAlertWithTitle:(NSString *)title msg:(NSString *)msg ConformBlock:(void (^) (void))conformBlock cancelBlock:(void (^) (void))cancelBlock
{
    [self simpleAlertWithTitle:title msg:msg attributString:nil ConformBlock:conformBlock cancelBlock:cancelBlock];
}

- (void)simpleAlertWithTitle:(NSString * _Nullable)title attributString:(NSAttributedString * _Nullable)attributString ConformBlock:(void (^ _Nullable) (void))conformBlock cancelBlock:(void (^ _Nullable) (void))cancelBlock
{
    [self simpleAlertWithTitle:title msg:nil attributString:attributString ConformBlock:conformBlock cancelBlock:cancelBlock];
}

- (void)simpleAlertWithTitle:(NSString *)title msg:(NSString *)msg attributString:(NSAttributedString *)attributString ConformBlock:(void (^) (void))conformBlock cancelBlock:(void (^) (void))cancelBlock
{
    title = title? title: @"提示";
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:(UIAlertControllerStyleAlert)];
    
    __weak typeof(alert) ws = alert;
    
    if (attributString) {
        [alert setValue:attributString forKey:@"attributedMessage"];
    }
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        conformBlock? conformBlock(): nil;
        [ws dismissViewControllerAnimated:YES completion:nil];
    }];
    [alert addAction:action];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {
        cancelBlock? cancelBlock(): nil;
        [ws dismissViewControllerAnimated:YES completion:nil];
    }];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)actionSheetAlertWithTitle:(NSString *)title msg:(NSString *)msg ops:(nonnull NSArray<NSString *> *)ops ConformBlock:(void (^ _Nullable)(NSInteger))conformBlock cancelBlock:(void (^ _Nullable)(void))cancelBlock
{
    title = title? title: @"提示";
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:(UIAlertControllerStyleActionSheet)];
 
    __weak typeof(alert) ws = alert;
    
    [ops enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIAlertAction *optAction = [UIAlertAction actionWithTitle:obj style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
            conformBlock? conformBlock(idx): nil;
            [ws dismissViewControllerAnimated:YES completion:nil];
        }];
        [ws addAction:optAction];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {
        [ws dismissViewControllerAnimated:YES completion:nil];
    }];
    [ws addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end
