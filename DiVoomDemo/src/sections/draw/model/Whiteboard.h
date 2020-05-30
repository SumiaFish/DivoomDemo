//
//  Whiteboard.h
//  DiVoomDemo
//
//  Created by kevin on 2020/5/29.
//  Copyright © 2020 kevin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class Page;
@class Line;
@class Whiteboard;
@protocol GraphicsProtocol;

typedef NS_ENUM(NSInteger, PageInsertType) {
    PageInsertType_Append,
    PageInsertType_AfterSelectePage,
};

@protocol GraphicsProtocol <NSObject>

- (NSString *)id;
- (id<GraphicsProtocol>)superGraphic;
- (NSArray<id<GraphicsProtocol>> *)graphics;
- (NSDictionary<NSString *, id<GraphicsProtocol>> *)graphicsMap;
- (id<GraphicsProtocol>)current;

@end

@interface Graphic : NSObject
<GraphicsProtocol>

@property (copy, nonatomic, readonly) NSString *id;

@end

@interface ZPoint : Graphic

@property (strong, nonatomic, readonly) UIColor *color;
@property (assign, nonatomic, readonly) CGFloat lineWidth;
@property (assign, nonatomic, readonly) CGFloat x;
@property (assign, nonatomic, readonly) CGFloat y;

+ (instancetype)pointX:(CGFloat)x y:(CGFloat)y lineWidth:(CGFloat)lineWidth color:(UIColor *)color;
- (Line * _Nullable)line;
- (CGPoint)getPoint;

@end

@interface Line : Graphic

@property (strong, nonatomic, readonly) NSArray<ZPoint *> *points;

+ (instancetype)line;
- (ZPoint * _Nullable)lastPoint:(ZPoint *)point;
- (ZPoint * _Nullable)currentPoint;
- (Page * _Nullable)page;

@end

@interface Page : Graphic

@property (strong, nonatomic, readonly) NSArray<Line *> *lines;
@property (strong, nonatomic, nullable) UIImage *background;

+ (instancetype)page;
- (Whiteboard * _Nullable)whiteboard;

@end

@interface Whiteboard : NSObject

@property (copy, nonatomic, readonly) NSString *id;
@property (strong, nonatomic, readonly) NSArray<Page *> *pages;
@property (strong, nonatomic, readonly) NSDictionary<NSString *, Page *> *pagesMap;
@property (assign, nonatomic, readonly) CGSize size;
@property (strong, nonatomic, readonly, nullable) UIImage *defaultBackground;
@property (assign, nonatomic) PageInsertType pageInsertType;
/// 选中页面改变，因为内部在增删页面的时候会调整选中页面，所以这里提供统一回调; 这里比较特殊，先这样吧！
@property (copy, nonatomic) void (^ onSeletePageChangeBlock) (Whiteboard *object, Page *lastPage, Page *currentPage);

+ (instancetype)whiteboardWithSize:(CGSize)size defaultBackground:(UIImage * _Nullable)defaultBackground;

- (void)selectePageId:(NSString *)pageId;
- (void)addGraphic:(Graphic *)graphic;
- (void)removeGraphic:(Graphic *)graphic;
- (void)removeGraphicWithId:(NSString *)id;

- (NSInteger)getPageIndex:(NSString *)pageId;

/// 是不是当前page 的元素
- (BOOL)isCurrentPageOfGraphic:(Graphic *)graphic;
/// 是不是当前page 的元素
- (BOOL)isCurrentPageOfGraphicId:(NSString *)id;

- (Page * _Nullable)currentPage;
- (Line * _Nullable)currentLine;
- (ZPoint * _Nullable)currentPoint;

@end

NS_ASSUME_NONNULL_END
