//
//  PlayerView.m
//  DiVoomDemo
//
//  Created by kevin on 2020/5/29.
//  Copyright © 2020 kevin. All rights reserved.
//

#import "PlayerView.h"

@interface PlayerView ()

@property (strong, nonatomic) UIView *bg;
@property (strong, nonatomic) UIImageView *imgView;

@end

@implementation PlayerView

- (instancetype)init {
    if (self = [super init]) {
        [self bg];
        [self imgView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _bg.frame = self.bounds;
    
    _imgView.frame = CGRectMake(0, (self.bounds.size.height-self.bounds.size.width)/2, self.bounds.size.width, self.bounds.size.width);
}

- (void)playImages:(NSArray<UIImage *> *)images animationDuration:(CGFloat)animationDuration animationRepeatCount:(NSInteger)animationRepeatCount {
    _imgView.animationImages = images; //获取Gif图片列表
    _imgView.animationDuration = animationDuration;     //执行一次完整动画所需的时长
    _imgView.animationRepeatCount = animationRepeatCount;  //动画重复次数
    [_imgView startAnimating];
    
    [self display:YES animate:YES];
}

- (void)tapBG {
    [_imgView stopAnimating];
    [self display:NO animate:YES];
}

- (UIImageView *)imgView {
    if (!_imgView) {
        _imgView = UIImageView.new;
        [self addSubview:_imgView];
    }
    return _imgView;
}

- (UIView *)bg {
    if (!_bg) {
        _bg = UIView.new;
        [self addSubview:_bg];
        _bg.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:1];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBG)];
        [_bg addGestureRecognizer:tap];
    }
    return _bg;
}

@end
