//
//  Drawer.h
//  DiVoomDemo
//
//  Created by kevin on 2020/5/29.
//  Copyright © 2020 kevin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Whiteboard.h"

NS_ASSUME_NONNULL_BEGIN

@interface Drawer : NSObject

/// 绘制时候x y 的缩放比例，默认是(1, 1); 线宽根据 scale.height 缩放
@property (assign, nonatomic) CGSize scale;

/*
 size: 默认(0,0)
 scale: 绘制时候x y 的缩放比例，默认是(1, 1); 线宽根据 scale.height 缩放；
 rows: 像素化单位 每个单元的大小为 size.width / rows 默认是1
 */
+ (instancetype)drawWithSize:(CGSize)size;
+ (instancetype)drawWithSize:(CGSize)size scale:(CGSize)scale;
+ (instancetype)drawWithSize:(CGSize)size scale:(CGSize)scale pixellateRows:(NSInteger)rows;

- (CGSize)size;
- (NSInteger)rows;

- (void)drawSnapshoot:(UIImage *)snapshoot;
- (UIImage *)drawGraphic:(Graphic *)graphic backgroundImage:(UIImage * _Nullable)backgroundImage;
- (void)clearContent;
- (NSData *)currentData;

@end

@interface Drawer (Extend)

+ (UIImage *)getImageWithContext:(CGContextRef)context;
+ (UIImage *)imageWithColor:(UIColor *)color Rect:(CGRect)rect;
+ (UIImage *)drawBackgroundWithSize:(CGSize)size rows:(NSInteger)rows;
+ (UIImage *)pixellate:(UIImage *)image size:(CGSize)size scale:(CGFloat)scale;
+ (NSArray<NSValue *> *)getInterpolationWithBeginPoint:(CGPoint)beginPoint endPoint:(CGPoint)endPoint distance:(float)distance;
+ (UIImage *)customImageWith:(UIImage *)image toSize:(CGSize)toSize;

@end



NS_ASSUME_NONNULL_END
