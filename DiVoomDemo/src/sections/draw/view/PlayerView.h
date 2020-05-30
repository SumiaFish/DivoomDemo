//
//  PlayerView.h
//  DiVoomDemo
//
//  Created by kevin on 2020/5/29.
//  Copyright © 2020 kevin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+Context.h"

NS_ASSUME_NONNULL_BEGIN

@protocol PlayerViewProtocol <NSObject>

- (void)playImages:(NSArray<UIImage *> *)images animationDuration:(CGFloat)animationDuration animationRepeatCount:(NSInteger)animationRepeatCount;

@end

@interface PlayerView : UIView
<PlayerViewProtocol>

@end

NS_ASSUME_NONNULL_END
