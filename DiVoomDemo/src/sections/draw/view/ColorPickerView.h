//
//  ColorPickerView.h
//  DiVoomDemo
//
//  Created by kevin on 2020/5/29.
//  Copyright © 2020 kevin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+Context.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ColorPickerProtocol <NSObject>

@property (strong, nonatomic) UIColor *color;
@property (copy, nonatomic) void (^ onPickColorBlock) (UIColor *color);

@end

@interface ColorPickerView : UIView
<ColorPickerProtocol>

@end

NS_ASSUME_NONNULL_END
