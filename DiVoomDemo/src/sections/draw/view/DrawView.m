//
//  DrawView.m
//  DiVoomDemo
//
//  Created by kevin on 2020/5/29.
//  Copyright © 2020 kevin. All rights reserved.
//

#import "DrawView.h"

@interface DrawView ()

@property (strong, nonatomic) UIImageView *bgv;
@property (strong, nonatomic) UIImageView *cv;

@end

@implementation DrawView

@synthesize onDrawBeginBlock = _onDrawBeginBlock;
@synthesize onDrawMoveBlock = _onDrawMoveBlock;
@synthesize onDrawEndBlock = _onDrawEndBlock;

@dynamic background;
@dynamic content;

- (instancetype)init {
    if (self = [super init]) {
        _bgv = UIImageView.new;
        _bgv.backgroundColor = UIColor.clearColor;
        _cv = UIImageView.new;
        _cv.backgroundColor = UIColor.clearColor;
        [self addSubview:_bgv];
        [self addSubview:_cv];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _bgv.frame = self.bounds;
    _cv.frame = self.bounds;
}

- (void)setBackground:(UIImage *)background {
    _bgv.image = background;
}

- (UIImage *)background {
    return _bgv.image;
}

- (void)setContent:(UIImage *)content {
    _cv.image = content;
}

- (UIImage *)content {
    return _cv.image;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    _onDrawBeginBlock? _onDrawBeginBlock([self point:touches]): nil;
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    _onDrawMoveBlock? _onDrawMoveBlock([self point:touches]): nil;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    _onDrawEndBlock? _onDrawEndBlock([self point:touches]): nil;
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    _onDrawEndBlock? _onDrawEndBlock([self point:touches]): nil;
}

- (CGPoint)point:(NSSet<UITouch *> *)touches {
    return [touches.anyObject locationInView:self];
}

@end
