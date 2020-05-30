//
//  DrawView.h
//  DiVoomDemo
//
//  Created by kevin on 2020/5/29.
//  Copyright © 2020 kevin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+Context.h"

NS_ASSUME_NONNULL_BEGIN

@protocol DrawViewProtocol;

@protocol DrawViewProtocol <NSObject>

@property (copy, nonatomic) void (^ onDrawBeginBlock) (CGPoint point);
@property (copy, nonatomic) void (^ onDrawMoveBlock) (CGPoint point);
@property (copy, nonatomic) void (^ onDrawEndBlock) (CGPoint point);

@property (strong, nonatomic) UIImage *background;
@property (strong, nonatomic) UIImage *content;

@end

@interface DrawView : UIView
<DrawViewProtocol>

@end

NS_ASSUME_NONNULL_END
