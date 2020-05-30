//
//  ColorPickerView.m
//  DiVoomDemo
//
//  Created by kevin on 2020/5/29.
//  Copyright © 2020 kevin. All rights reserved.
//

#import "ColorPickerView.h"

@interface ColorPickerView ()

@property (strong, nonatomic) UIView *bg;
@property (strong, nonatomic) UIImageView *imgView;

@end

@implementation ColorPickerView

@synthesize color = _color;
@synthesize onPickColorBlock = _onPickColorBlock;

- (instancetype)init {
    if (self = [super init]) {
        _color = UIColor.redColor;
        [self bg];
        [self imgView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _bg.frame = self.bounds;
    
    _imgView.frame = CGRectMake(0, (self.bounds.size.height-self.bounds.size.width)/2, self.bounds.size.width, self.bounds.size.width);
    if (!CGSizeEqualToSize(_imgView.image.size, _imgView.bounds.size)) {
        _imgView.image = [self customImageWith:[UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"color.jpg" ofType:nil]] toSize:_imgView.bounds.size];
    }
}

- (void)tapBG {
    [self display:NO animate:YES];
}

- (void)touchPickColorSource:(UITapGestureRecognizer *)sender {
    CGPoint point = [sender locationInView:_imgView];
    UIColor *color = [self getPointColorWithImage:_imgView.image location:point];
    _color = color;
    _onPickColorBlock? _onPickColorBlock(color): nil;
    
    [self display:NO animate:YES];
}

- (UIImageView *)imgView {
    if (!_imgView) {
        _imgView = UIImageView.new;
        [self addSubview:_imgView];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchPickColorSource:)];
        _imgView.userInteractionEnabled = YES;
        [_imgView addGestureRecognizer:tap];
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

- (UIImage *)customImageWith:(UIImage *)image toSize:(CGSize)toSize
{
    UIGraphicsBeginImageContext(CGSizeMake(toSize.width, toSize.height));
    [image drawInRect:CGRectMake(0, 0, toSize.width, toSize.height)];
    UIImage *customImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return customImage;
}

- (UIColor *)getPointColorWithImage:(UIImage *)image location:(CGPoint)point
{
    UIColor *pointColor = nil;
    
    //如果图片上不存在该点返回nil
    if (!CGRectContainsPoint(CGRectMake(0.0f, 0.0f, image.size.width, image.size.height), point)) {
        return nil;
    }
    
    NSInteger pointX = truncl(point.x); //直接舍去小数，如1.58 -> 1.0
    NSInteger pointY= truncl(point.y);
    CGImageRef cgImage = image.CGImage;
    NSUInteger width = image.size.width;
    NSUInteger height = image.size.height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();  //bitmap上下文使用的颜色空间
    int bytesPerPixel = 4;  //bitmap在内存中所占的比特数
    int bytesPerRow = bytesPerPixel * 1;   //bitmap的每一行在内存所占的比特数
    NSUInteger bitsPerComponent = 8;   //内存中像素的每个组件的位数.例如，对于32位像素格式和RGB 颜色空间，你应该将这个值设为8.
    unsigned char pixelData[4] = {0, 0, 0, 0};  //初始化像素信息
    
    //创建位图文件环境。位图文件可自行百度 bitmap
    CGContextRef context = CGBitmapContextCreate(pixelData,
                                                 1,
                                                 1,
                                                 bitsPerComponent,
                                                 bytesPerRow,
                                                 colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big); //指定bitmap是否包含alpha通道，像素中alpha通道的相对位置，像素组件是整形还是浮点型等信息的字符串。
    CGColorSpaceRelease(colorSpace);
    
    CGContextSetBlendMode(context, kCGBlendModeCopy); //当一个颜色覆盖上另外一个颜色，两个颜色的混合方式
    
    CGContextTranslateCTM(context, -pointX, pointY - (CGFloat)height);  //改变画布位置
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, (CGFloat)width, (CGFloat)height ), cgImage);   //绘制图片
    CGContextRelease(context);
    
    CGFloat red = (CGFloat)pixelData[0] / 255.0f;
    CGFloat green = (CGFloat)pixelData[1] / 255.0f;
    CGFloat blue = (CGFloat)pixelData[2] / 255.0f;
    CGFloat alpha = (CGFloat)pixelData[3] / 255.0f;
    
    pointColor = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
    
    return pointColor;
}

@end
