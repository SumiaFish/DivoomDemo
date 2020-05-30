//
//  UIView+Context.h
//  kvtemplate
//
//  Created by kevin on 2020/5/27.
//  Copyright © 2020 kevin. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol KVUIViewDisplayDelegate <NSObject>

- (void)onView:(UIView *)view display:(BOOL)isDisplay animate:(BOOL)animate;

@end

//@interface UIView (Context)
//
//@property (weak, nonatomic) id context;
//
//@end

@interface UIView (DisplayContext)

@property (weak, nonatomic) id<KVUIViewDisplayDelegate> displayContext;

- (void)display:(BOOL)isDisplay;

- (void)display:(BOOL)isDisplay animate:(BOOL)animate;

- (BOOL)isDisplay;

@end

NS_ASSUME_NONNULL_END
