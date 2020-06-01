//
//  Drawer.m
//  DiVoomDemo
//
//  Created by kevin on 2020/5/29.
//  Copyright © 2020 kevin. All rights reserved.
//

#import "Drawer.h"

@interface DrawerInterpolationCache : NSObject

@property (assign, nonatomic, readonly) CGPoint p1;
@property (assign, nonatomic, readonly) CGPoint p2;
@property (assign, nonatomic, readonly) CGFloat distance;
@property (strong, nonatomic, readonly) NSArray<NSValue *> *result;

@end

@implementation DrawerInterpolationCache

+ (instancetype)cacheItemP1:(CGPoint)p1 p2:(CGPoint)p2 distance:(CGFloat)distance {
    return [[self.class alloc] initWithP1:p1 p2:p2 distance:distance];
}

- (instancetype)initWithP1:(CGPoint)p1 p2:(CGPoint)p2 distance:(CGFloat)distance {
    if (self = [super init]) {
        _p1 = p1;
        _p2 = p2;
        _distance = distance;
    }
    return self;
}

- (NSString *)id {
    return [NSString stringWithFormat:@"%@.%@.%@", NSStringFromCGPoint([self.class intPoint:_p1]), NSStringFromCGPoint([self.class intPoint:_p2]), @((int)(_distance))];
}

+ (CGPoint)intPoint:(CGPoint)point {
    return CGPointMake((int)(point.x), (int)(point.y));
}

- (void)compute {
    _result = [Drawer getInterpolationWithBeginPoint:_p1 endPoint:_p2 distance:1];
}

@end

@interface DrawerInterpolationCacheManager : NSObject

@property (strong, nonatomic) NSMutableDictionary<NSString *, DrawerInterpolationCache *> *items;
@property (strong, nonatomic) NSMutableDictionary<NSString *, NSValue *> *point2rects;

@end

@implementation DrawerInterpolationCacheManager

- (NSArray<NSValue *> *)getInterpolationWithBeginPoint:(CGPoint)p1 p2:(CGPoint)p2 distance:(CGFloat)distance {
    DrawerInterpolationCache *item = [DrawerInterpolationCache cacheItemP1:p1 p2:p2 distance:distance];
    DrawerInterpolationCache *cacheItem = self.items[item.id];
    if (cacheItem) {
        return cacheItem.result;
    }
    [item compute];
    self.items[item.id] = item;
    return item.result;
}

- (NSMutableDictionary<NSString *,DrawerInterpolationCache *> *)items {
    if (!_items) {
        _items = NSMutableDictionary.dictionary;
    }
    return _items;
}

- (NSMutableDictionary<NSString *,NSValue *> *)point2rects {
    if (!_point2rects) {
        _point2rects = NSMutableDictionary.dictionary;
    }
    return _point2rects;
}

@end

@interface KVPixellate : NSObject

@property (assign, nonatomic) CGSize size;
@property (assign, nonatomic) CGFloat scale;
@property (strong, nonatomic) CIFilter *filter;
@property (strong, nonatomic) CIContext *context;

+ (instancetype)pixellateWithSize:(CGSize)size scale:(CGFloat)scale;
- (UIImage *)filter:(UIImage *)image;

@end

@implementation KVPixellate

+ (instancetype)pixellateWithSize:(CGSize)size scale:(CGFloat)scale {
    return [[self.class alloc] initWithSize:size scale:scale];
}

- (instancetype)initWithSize:(CGSize)size scale:(CGFloat)scale {
    if (self = [super init]) {
        _size = size;
        _scale = scale;
    }
    return self;
}

- (UIImage *)filter:(UIImage *)image {
    if (!image) {
        return image;
    }
    
    CIImage *inputImage = [[CIImage alloc] initWithImage:image];
    [self.filter setValue:inputImage forKey:kCIInputImageKey];
    [self.filter setValue:@(_scale) forKey:kCIInputScaleKey];
    CIImage *output = self.filter.outputImage;
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    return [UIImage imageWithCGImage:[self.context createCGImage:output fromRect:rect]];
}

- (CIFilter *)filter {
    if (!_filter) {
        _filter = [CIFilter filterWithName:@"CIPixellate"];
    }
    return _filter;
}

- (CIContext *)context {
    if (!_context) {
        _context = [[CIContext alloc] initWithOptions:nil];
    }
    return _context;
}

@end

@interface Drawer ()

@property (nonatomic) CGContextRef context;
@property (strong, nonatomic) NSMutableData *data;
@property (assign, nonatomic) CGSize size;
@property (assign, nonatomic) NSInteger rows;

@property (strong, nonatomic) UIImage *backgroundImage;

@property (strong, nonatomic) DrawerInterpolationCacheManager *interpolationCacheManager;

@end

@implementation Drawer

- (void)dealloc {
    
}

+ (instancetype)drawWithSize:(CGSize)size {
    return [[self.class alloc] initWithSize:size scale:CGSizeMake(1, 1) pixellateRows:1];
}

+ (instancetype)drawWithSize:(CGSize)size scale:(CGSize)scale {
    return [[self.class alloc] initWithSize:size scale:scale pixellateRows:1];
}

+ (instancetype)drawWithSize:(CGSize)size scale:(CGSize)scale pixellateRows:(NSInteger)rows {
    return [[self.class alloc] initWithSize:size scale:scale pixellateRows:rows];
}

- (instancetype)init {
    return nil;
}

- (instancetype)initWithSize:(CGSize)size scale:(CGSize)scale pixellateRows:(NSInteger)rows {
    if (self = [super init]) {
        _scale = scale;
        _size = size;
        if (rows < 1) {
            _rows = 1;
        } else {
            _rows = rows;
        }
        [self initContext];
    }
    return self;
}

- (void)drawSnapshoot:(UIImage *)snapshoot {
    if (!snapshoot) {
        return;
    }
    
    CGContextTranslateCTM(_context, 0, self.size.height);
    CGContextScaleCTM(_context, 1.0, -1.0);
    
    CGContextDrawImage(_context, CGRectMake(0, 0, self.size.width, self.size.height), snapshoot.CGImage);
    
    CGContextTranslateCTM(_context, 0, self.size.height);
    CGContextScaleCTM(_context, 1.0, -1.0);
}

- (UIImage *)drawGraphic:(Graphic *)graphic backgroundImage:(UIImage *)backgroundImage {
    
    [self drawBackground:backgroundImage];
    
    if ([graphic isKindOfClass:Page.class]) {
        [self drawPage:(Page *)graphic];
    } else if ([graphic isKindOfClass:Line.class]) {
        [self drawLine:(Line *)graphic];
    } else if ([graphic isKindOfClass:ZPoint.class]) {
        [self drawPoint:(ZPoint *)graphic];
    }
    return [self.class getImageWithContext:_context];
    
}

- (void)drawBackground:(UIImage *)backgroundImage {
    BOOL drawBG = backgroundImage && backgroundImage != _backgroundImage;
    _backgroundImage = backgroundImage;
    if (drawBG) {
        CGContextTranslateCTM(_context, 0, self.size.height);
        CGContextScaleCTM(_context, 1.0, -1.0);
        
        UIImage *currentImage = [self.class getImageWithContext:self.context];
        UIImage *bgimg = nil;
        if (_rows == 1) {
            bgimg = backgroundImage;
        } else {
            bgimg = [self.class pixellate:backgroundImage size:self.size scale:self.size.width / self.rows];
        }
        
        UIGraphicsBeginImageContext(self.size);
        /// TODO；这里解释不清楚，待查证
        if (_rows == 1) {
            [currentImage drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
            [bgimg drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
        } else {
            [bgimg drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
            [currentImage drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
        }
//        [bgimg drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
        UIImage *compoundImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        CGContextDrawImage(self.context, CGRectMake(0, 0, self.size.width, self.size.height), compoundImage.CGImage);
        
        CGContextTranslateCTM(_context, 0, self.size.height);
        CGContextScaleCTM(_context, 1.0, -1.0);
    }
}

- (void)drawPage:(Page *)page {
    if (!page) {
        return;
    }
    [page.lines enumerateObjectsUsingBlock:^(Line * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self drawLine:obj];
    }];
}

- (void)drawLine:(Line *)line {
    if (!line) {
        return;
    }
    [line.points enumerateObjectsUsingBlock:^(ZPoint * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self drawPoint:obj];
    }];
}

- (void)drawPoint:(ZPoint *)zp {
    if (!zp) {
        return;
    }
    
    Line *line = zp.line;
    if (!line) {
        return;
    }
    
    ZPoint *pp = [line lastPoint:zp];
    if (!pp) {
        pp = zp;
    }
    
    ZPoint *ppp = [line lastPoint:pp];
    
    if (_rows == 1) {
        /// 正常画线
        CGContextSetLineWidth(_context, [self getScaleLineWidth:zp.lineWidth]);
        CGContextSetStrokeColorWithColor(_context, zp.color.CGColor);

        if (!ppp) {
            CGPoint cp0 = [self getScalePoint:pp.getPoint];
            CGContextMoveToPoint(_context, cp0.x, cp0.y);
            CGPoint cp1 = [self getScalePoint:zp.getPoint];
            CGContextAddLineToPoint(_context, cp1.x, cp1.y);
        } else {
            CGPoint cp0 = [self getScalePoint:[self getMidP0:pp.getPoint p1:ppp.getPoint]];
            CGPoint cp1 = [self getScalePoint:pp.getPoint];
            CGPoint cp2 = [self getScalePoint:[self getMidP0:pp.getPoint p1:zp.getPoint]];
            CGContextMoveToPoint(_context, cp0.x, cp0.y);
            CGContextAddQuadCurveToPoint(_context, cp1.x, cp1.y, cp2.x, cp2.y);
        }

        CGContextDrawPath(_context, kCGPathStroke);
        
    } else {
        CGPoint cp1 = [self getScalePoint:pp.getPoint];
        CGPoint cp2 = [self getScalePoint:zp.getPoint];
        CGFloat distance = 1;
        NSArray<NSValue *> *ps = [self.interpolationCacheManager getInterpolationWithBeginPoint:cp1 p2:cp2 distance:distance];
        
        if (ps.count == 0) {
            CGContextSetLineWidth(self.context, 1);
            CGContextSetFillColorWithColor(self.context, zp.color.CGColor);
            CGContextSetStrokeColorWithColor(self.context, zp.color.CGColor);
            
            CGContextStrokeRect(self.context, [self getRect:[self getScalePoint:zp.getPoint]]);//画方框
            CGContextAddRect(self.context, [self getRect:[self getScalePoint:zp.getPoint]]);
            CGContextDrawPath(self.context, kCGPathFillStroke);
            
        } else {
            [ps enumerateObjectsUsingBlock:^(NSValue * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                CGPoint p = obj.CGPointValue;
                CGRect rect = [self getRect:p];
                
                CGContextSetLineWidth(self.context, 1);
                CGContextSetFillColorWithColor(self.context, zp.color.CGColor);
                CGContextSetStrokeColorWithColor(self.context, zp.color.CGColor);
                
                CGContextStrokeRect(self.context, rect);//画方框
                CGContextAddRect(self.context, rect);
                CGContextDrawPath(self.context, kCGPathFillStroke);
                                
            }];
            
        }
    }
}

- (CGFloat)getScaleLineWidth:(CGFloat)lineWidth {
    return lineWidth * _scale.height;
}

- (CGPoint)getScalePoint:(CGPoint)point {
    return CGPointMake(_scale.width * point.x, _scale.height * point.y);
}

- (CGPoint)getMidP0:(CGPoint)p0 p1:(CGPoint)p1 {
    return CGPointMake((p0.x+p1.x)/2, (p0.y+p1.y)/2);
}

- (CGRect)getRect:(CGPoint)point {
    return [self getRect:point scale:self.scale];
}

- (CGRect)getRect:(CGPoint)point scale:(CGSize)scale {
    CGFloat w = self.size.width / self.rows / scale.width;
    CGFloat h = self.size.height / self.rows / scale.height;
    CGFloat x = ((NSInteger)(point.x / w)) * w;
    CGFloat y = ((NSInteger)(point.y / h)) * h;
    return CGRectMake(x, y, w, h);
}


/// 清楚画布
- (void)clearContent {
    [_data resetBytesInRange:NSMakeRange(0, _data.length)];
    [self releaseContext];
    [self initContext];
    //
    _backgroundImage = nil;
}

- (NSData *)currentData {
    return [NSData dataWithData:_data];
}

- (void)initContext {
    if (_context == NULL) {
        //
        NSInteger w = _size.width;
        NSInteger h = _size.height;
        
        if (!_data) {
            _data = [[NSMutableData alloc] initWithLength: w * h * 4];
        }
        
        int bytesPerPixel = 4;  //bitmap在内存中所占的比特数
//        int bytesPerRow = bytesPerPixel * 1;   //bitmap的每一行在内存所占的比特数
        NSUInteger bitsPerComponent = 8;   //内存中像素的每个组件的位数.例如，对于32位像素格式和RGB 颜色空间，你应该将这个值设为8.
//        unsigned char pixelData[4] = {0, 0, 0, 0};  //初始化像素信息
        NSMutableData *data = _data;
        
        //
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef context = CGBitmapContextCreate(data.mutableBytes,
                                                     w,
                                                     h,
                                                     bitsPerComponent,
                                                     w * bytesPerPixel,
                                                     colorSpace,
                                                     kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
//        CGContextSetLineWidth(context, lineWidth);
        CGContextSetLineCap(context, kCGLineCapRound); // 线段起点是终点的样式; 圆角
        CGContextSetLineJoin(context, kCGLineJoinRound); // 两条线连结点的样式; 圆滑衔接
        CGContextSetAllowsAntialiasing(context, true);
        CGContextSetShouldAntialias(context, true);
        
        // 填充颜色
        CGContextSetFillColorWithColor(context, UIColor.clearColor.CGColor);
        // 填充区域
        CGContextFillRect(context, CGRectMake(0, 0, w, h));
        
        //
        _context = context;
        CGContextBeginPath(_context);
        // 转换坐标系
        CGContextTranslateCTM(_context, 0, h);
        CGContextScaleCTM(_context, 1.0, -1.0);
    }
}

- (void)releaseContext {
    if (_context != NULL) {
        CGContextRelease(_context);
        _context = NULL;
    }
}

///

- (DrawerInterpolationCacheManager *)interpolationCacheManager {
    if (!_interpolationCacheManager) {
        _interpolationCacheManager = [[DrawerInterpolationCacheManager alloc] init];
    }
    return _interpolationCacheManager;
}

@end

@implementation Drawer (Extend)

+ (UIImage *)getImageWithContext:(CGContextRef)context {
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    UIImage *res = [UIImage imageWithCGImage:quartzImage];
    CGImageRelease(quartzImage);
    return res;
}

+ (UIImage *)imageWithColor:(UIColor *)color Rect:(CGRect)rect {
    // CGRect rect=CGRectMake(0.0f, 0.0f, 50.0f, 10.0f);
    UIGraphicsBeginImageContext(rect.size);

    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetFillColorWithColor(context, [color CGColor]);

    CGContextFillRect(context, rect);

    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    return theImage;

}

+ (UIImage *)drawBackgroundWithSize:(CGSize)size rows:(NSInteger)rows {
//    CGSize size = size;
    CGFloat zw = size.width / rows;
    CGFloat zh = size.height / rows;
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1);
    CGContextSetFillColorWithColor(context, UIColor.blackColor.CGColor);
    CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
    CGContextSetStrokeColorWithColor(context, [UIColor.whiteColor colorWithAlphaComponent:0.5].CGColor);
    for (NSInteger i = 0; i < rows; i ++) {
        CGFloat x = (i+1) * zw;
        CGFloat y = size.height;
        CGContextMoveToPoint(context, x, 0);
        CGContextAddLineToPoint(context, x, y);

        x = size.width;
        y = (i+1) * zh;
        CGContextMoveToPoint(context, 0, y);
        CGContextAddLineToPoint(context, x, y);

        CGContextDrawPath(context, kCGPathFillStroke);
    }
    UIImage *res = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return res;
}

+ (UIImage *)pixellate:(UIImage *)image size:(CGSize)size scale:(CGFloat)scale {
    return [[KVPixellate pixellateWithSize:size scale:scale] filter:image];
}

+ (NSArray<NSValue *> *)getInterpolationWithBeginPoint:(CGPoint)beginPoint endPoint:(CGPoint)endPoint distance:(float)distance
{
    const float w = endPoint.x - beginPoint.x;
    const float h = endPoint.y - beginPoint.y;
    const int count1 = (int) fabs(w / distance) + 1;
    const int count2 = (int) fabs(h / distance) + 1;
    const int count = count1 > count2 ? count1 : count2;
    
    const float dw = w / count;
    const float dh = h / count;
    const float baseX = beginPoint.x;
    const float baseY = beginPoint.y;
    
    NSMutableArray<NSValue *> * ps = [NSMutableArray array];
    for (int i = 0; i < count; i++) {
        NSValue *value = [NSValue valueWithCGPoint:CGPointMake(baseX + i * dw, baseY + i * dh)];
        [ps addObject:value];
    }
    
    return ps;
}

+ (UIImage *)customImageWith:(UIImage *)image toSize:(CGSize)toSize
{
    UIGraphicsBeginImageContext(CGSizeMake(toSize.width, toSize.height));
    [image drawInRect:CGRectMake(0, 0, toSize.width, toSize.height)];
    UIImage *customImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return customImage;
}

@end
