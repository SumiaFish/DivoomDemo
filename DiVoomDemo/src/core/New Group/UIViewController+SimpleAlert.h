//
//  UIViewController+SimpleAlert.h
//  youlian
//
//  Created by hlw on 2019/5/9.
//  Copyright © 2019 youlian. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (SimpleAlert)

- (void)simpleAlertWithTitle:(NSString *_Nullable)title msg:(NSString * _Nullable)msg;

- (void)simpleAlert:(NSString * _Nullable)msg;

- (void)simpleAlertWithTitle:(NSString * _Nullable)title msg:(NSString * _Nullable)msg ConformBlock:(void (^ _Nullable) (void))conformBlock cancelBlock:(void (^ _Nullable) (void))cancelBlock;

- (void)simpleAlertWithTitle:(NSString * _Nullable)title attributString:(NSAttributedString * _Nullable)attributString ConformBlock:(void (^ _Nullable) (void))conformBlock cancelBlock:(void (^ _Nullable) (void))cancelBlock;



- (void)actionSheetAlertWithTitle:(NSString * _Nullable)title msg:(NSString * _Nullable)msg ops:(NSArray<NSString *> *)ops ConformBlock:(void (^ _Nullable) (NSInteger idx))conformBlock cancelBlock:(void (^ _Nullable) (void))cancelBlock;


@end

NS_ASSUME_NONNULL_END
