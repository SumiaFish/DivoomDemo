//
//  WhiteboardManager.h
//  DiVoomDemo
//
//  Created by kevin on 2020/5/29.
//  Copyright © 2020 kevin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Drawer.h"
#import "Whiteboard.h"

NS_ASSUME_NONNULL_BEGIN

@protocol WhiteboardManagerProtocol;
@class WhiteboardManagerPayload;
@class WhiteboardSimpleManager;
@class PageSnapshootData;

typedef NS_ENUM(NSInteger, PageChangeType) {
    PageChangeType_AddPage,
    PageChangeType_RemovePage,
    PageChangeType_UpdatePage,
    PageChangeType_SelectePage,
};

@protocol WhiteboardManagerProtocol <NSObject>

/// 新建页面的背景图片
@property (strong, nonatomic, nullable) UIImage *defaultBackground;

/// 获取画笔线宽
@property (copy, nonatomic) CGFloat (^ onGetLineWidthBlock) (id<WhiteboardManagerProtocol> object);
/// 获取画笔颜色
@property (copy, nonatomic) UIColor* (^ onGetColorBlock) (id<WhiteboardManagerProtocol> object);
/// 白板状态发生改变
@property (copy, nonatomic) void (^ onWhitebaordChangeBlock) (id<WhiteboardManagerProtocol> object, WhiteboardManagerPayload *payload);

/// size 画布的大小
- (instancetype)initWithSize:(CGSize)size defaultBackground:(UIImage * _Nullable)defaultBackground;
- (void)setDrawer:(Drawer *)drawer;
- (void)setSmallDrawer:(Drawer *)smallDrawer;
- (CGSize)size;

/// 开始绘制
- (void)beginDraw:(CGPoint)point;
/// 添加点
- (void)drawPoint:(CGPoint)point;
/// 绘制结束
- (void)endDraw;
- (BOOL)isDrawing;


/// 撤销一次操作
- (void)undo;
/// 能否撤销
- (BOOL)canUndo;
/// 恢复一次操作
- (void)redo;
/// 能否恢复
- (BOOL)canRedo;

/// 添加新页面的插入位置
@property (assign, nonatomic) PageInsertType pageInsertType;
/// 新建一个页面
- (void)createNewPage;
/// 删除当前页
- (void)removeCurrentPage;
/// 删除一个页面
- (void)removePage:(NSString *)pageId;
/// 选中一个页面
- (void)selectePageId:(NSString *)pageId;


/// 获取所有内容
- (NSArray<UIImage *> *)getImages;
- (NSArray<UIImage *> *)getImagesWithSize:(CGSize)size;
/// 生成一个同比例缩放的绘制器
//- (Drawer *)getDrawerWithSize:(CGSize)size;
//- (Drawer *)getDrawerWhioutPixellateWithSize:(CGSize)size;

/// 给某一个页面设置背景图片
- (void)setBackground:(UIImage * _Nullable)background toPage:(NSString *)pageId;

/// 当前页面
- (Page *)currentPage;
/// 当前所有页面
- (NSArray<Page *> * _Nonnull)pages;
- (NSDictionary<NSString *,Page *> * _Nonnull)pagesMap;
- (NSInteger)getPageIndex:(NSString *)pageId;

@end

@interface Page (Snapshoot)

@property (strong, nonatomic, nullable) PageSnapshootData *data;
@property (strong, nonatomic, nullable) UIImage *snapshoot;
@property (strong, nonatomic, nullable) UIImage *smallSnapshoot;

@end

@interface WhiteboardManagerPayload : NSObject

@property (assign, nonatomic, readonly) PageChangeType type;
@property (strong, nonatomic, readonly) Page *page;
@property (strong, nonatomic, readonly) Page *currentPage;
@property (assign, nonatomic, readonly) NSArray<Page *> *pages;

@end

@interface WhiteboardManager : NSObject
<WhiteboardManagerProtocol>


@end

NS_ASSUME_NONNULL_END
