//
//  WhiteboardManager.m
//  DiVoomDemo
//
//  Created by kevin on 2020/5/29.
//  Copyright © 2020 kevin. All rights reserved.
//

#import <objc/runtime.h>
#import "WhiteboardManager.h"

#import "Drawer.h"
#import "Whiteboard.h"

#define WhiteboardManagerPayloadInit(t, p, cur, ps) ([WhiteboardManagerPayload payloadWithType:t page:p currentPage:cur pages:ps])

@interface PageSnapshootData : NSObject

@property (strong, nonatomic, nullable) UIImage *snapshoot;
@property (strong, nonatomic, nullable) UIImage *smallSnapshoot;

@end

@implementation PageSnapshootData

@end

@implementation Page (Snapshoot)

static void* PageSnapshootDataKey;

- (void)setData:(PageSnapshootData *)data {
    objc_setAssociatedObject(self, &PageSnapshootDataKey, data, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (PageSnapshootData *)data {
    id res = objc_getAssociatedObject(self, &PageSnapshootDataKey);
    if (res == nil) {
        PageSnapshootData *data = [[PageSnapshootData alloc] init];
        res = data;
        self.data = data;
    }
    return res;
}

- (void)setSnapshoot:(UIImage *)snapshoot {
    self.data.snapshoot = snapshoot;
}

- (UIImage *)snapshoot {
    return self.data.snapshoot;
}

- (void)setSmallSnapshoot:(UIImage *)smallSnapshoot {
    self.data.smallSnapshoot = smallSnapshoot;
}

- (UIImage *)smallSnapshoot {
    return self.data.smallSnapshoot;
}

@end

@implementation WhiteboardManagerPayload

+ (instancetype)payloadWithType:(PageChangeType)type page:(Page *)page currentPage:(Page *)currentPage pages:(NSArray *)pages {
    return [[self.class alloc] initWithType:type page:page currentPage:currentPage pages:pages];
}

- (instancetype)initWithType:(PageChangeType)type page:(Page *)page currentPage:(Page *)currentPage pages:(NSArray *)pages {
    if (self = [super init]) {
        _type = type;
        _page = page;
        _currentPage = currentPage;
        _pages = pages;
    }
    return self;
}

@end

@interface WhiteboardManager ()

@property (strong, nonatomic) NSUndoManager *undoManager;
@property (strong, nonatomic) Drawer *drawer;
@property (strong, nonatomic) Drawer *smallDrawer;
@property (strong, nonatomic) Whiteboard *whiteboard;
@property (assign, nonatomic) BOOL isDrawing;

@end

@implementation WhiteboardManager

@synthesize defaultBackground = _defaultBackground;
@synthesize onGetColorBlock = _onGetColorBlock;
@synthesize onGetLineWidthBlock = _onGetLineWidthBlock;
@synthesize onWhitebaordChangeBlock = _onWhitebaordChangeBlock;
@synthesize pageInsertType = _pageInsertType;

- (void)dealloc {
//    [NSNotificationCenter.defaultCenter removeObserver:self];
    [_undoManager removeAllActions];
    [_undoManager removeAllActionsWithTarget:self];
}

- (instancetype)initWithSize:(CGSize)size defaultBackground:(UIImage *)defaultBackground {
    if (self = [super init]) {
        _whiteboard = [Whiteboard whiteboardWithSize:size defaultBackground:defaultBackground];
        _undoManager = [[NSUndoManager alloc] init];
        
        __weak typeof(self) ws = self;
        _whiteboard.onSeletePageChangeBlock = ^(Whiteboard * _Nonnull object, Page * _Nonnull lastPage, Page * _Nonnull currentPage) {
            [ws.undoManager removeAllActions];
            [ws.undoManager removeAllActionsWithTarget:ws];
            //
            [ws clearContent];
            [ws.drawer drawSnapshoot:currentPage.snapshoot];
            [ws.smallDrawer drawSnapshoot:currentPage.smallSnapshoot];
            //
            ws.onWhitebaordChangeBlock? ws.onWhitebaordChangeBlock(ws, WhiteboardManagerPayloadInit(PageChangeType_SelectePage, ws.whiteboard.currentPage, ws.whiteboard.currentPage, ws.whiteboard.pages)): nil;
        };
        
        //
//        [NSNotificationCenter.defaultCenter addObserverForName:UIApplicationDidReceiveMemoryWarningNotification object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
//            [ws.whiteboard.pagesMap enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, Page * _Nonnull obj, BOOL * _Nonnull stop) {
//                obj.snapshoot = nil;
//            }];
//        }];
    }
    return self;
}

- (void)clearContent {
    [self.drawer clearContent];
    [self.smallDrawer clearContent];
}

- (CGSize)size {
    return _whiteboard.size;
}

- (void)beginDraw:(CGPoint)point {
    _isDrawing = YES;
    //
    [self.undoManager beginUndoGrouping];
    //
    Line *line = [Line line];
    [_whiteboard addGraphic:line];
    ZPoint *zp = [ZPoint pointX:point.x y:point.y lineWidth:self.lineWidth color:self.color];
    [_whiteboard addGraphic:zp];
    //
    [self addLine:line isRestore:NO];
    //
    self.whiteboard.currentPage.snapshoot = [self.drawer drawGraphic:zp backgroundImage:self.whiteboard.currentPage.background];
    self.whiteboard.currentPage.smallSnapshoot = [self.smallDrawer drawGraphic:zp backgroundImage:self.whiteboard.currentPage.background];
    //
    _onWhitebaordChangeBlock? _onWhitebaordChangeBlock(self, WhiteboardManagerPayloadInit(PageChangeType_UpdatePage, _whiteboard.currentPage, _whiteboard.currentPage, _whiteboard.pages)): nil;
}

- (void)drawPoint:(CGPoint)point {
    ZPoint *zp = [ZPoint pointX:point.x y:point.y lineWidth:self.lineWidth color:self.color];
    [_whiteboard addGraphic:zp];
    //
    self.whiteboard.currentPage.snapshoot = [self.drawer drawGraphic:zp backgroundImage:self.whiteboard.currentPage.background];
    self.whiteboard.currentPage.smallSnapshoot = [self.smallDrawer drawGraphic:zp backgroundImage:self.whiteboard.currentPage.background];
    //
    _onWhitebaordChangeBlock? _onWhitebaordChangeBlock(self, WhiteboardManagerPayloadInit(PageChangeType_UpdatePage, _whiteboard.currentPage, _whiteboard.currentPage, _whiteboard.pages)): nil;
}

- (void)endDraw {
    _isDrawing = NO;
    //
    [self.undoManager endUndoGrouping];
    //
    _onWhitebaordChangeBlock? _onWhitebaordChangeBlock(self, WhiteboardManagerPayloadInit(PageChangeType_UpdatePage, _whiteboard.currentPage, _whiteboard.currentPage, _whiteboard.pages)): nil;
}

- (void)addLine:(Line *)line isRestore:(BOOL)isRestore {
    __weak typeof(self) ws = self;
    [self.undoManager registerUndoWithTarget:self handler:^(id  _Nonnull target) {
        if (target == ws) {
            [ws removeLine:line];
        }
    }];
    if (isRestore) {
        [_whiteboard addGraphic:line];
        self.whiteboard.currentPage.snapshoot = [self.drawer drawGraphic:line backgroundImage:self.whiteboard.currentPage.background];
        self.whiteboard.currentPage.smallSnapshoot = [self.smallDrawer drawGraphic:line backgroundImage:self.whiteboard.currentPage.background];
        // 这里canRedo 状态还没改变；所以做异步执行
        __weak typeof(self) ws = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            ws.onWhitebaordChangeBlock? ws.onWhitebaordChangeBlock(ws, WhiteboardManagerPayloadInit(PageChangeType_UpdatePage, ws.whiteboard.currentPage, ws.whiteboard.currentPage, ws.whiteboard.pages)): nil;
        });
    }
}

- (void)removeLine:(Line *)line {
    __weak typeof(self) ws = self;
    [self.undoManager registerUndoWithTarget:self handler:^(id  _Nonnull target) {
        if (target == ws) {
            [ws addLine:line isRestore:YES];
        }
    }];
    BOOL needUpdate = [_whiteboard isCurrentPageOfGraphicId:line.id];
    [_whiteboard removeGraphic:line];
    if (needUpdate) {
        // 必须 重绘
        [self clearContent];
        self.whiteboard.currentPage.snapshoot = [self.drawer drawGraphic:self.whiteboard.currentPage backgroundImage:self.whiteboard.currentPage.background];
        self.whiteboard.currentPage.smallSnapshoot = [self.smallDrawer drawGraphic:self.whiteboard.currentPage backgroundImage:self.whiteboard.currentPage.background];
        // 这里canUndo 状态还没改变；所以做异步执行
        __weak typeof(self) ws = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            ws.onWhitebaordChangeBlock? ws.onWhitebaordChangeBlock(ws, WhiteboardManagerPayloadInit(PageChangeType_UpdatePage, ws.whiteboard.currentPage, ws.whiteboard.currentPage, ws.whiteboard.pages)): nil;
        });
        
    }
}

/// 撤销一次操作
- (void)undo {
    if ([self canUndo]) {
        [self.undoManager undo];
    }
}

/// 能否撤销
- (BOOL)canUndo {
    return self.undoManager.canUndo;
}

/// 恢复一次操作
- (void)redo {
    if (self.undoManager.canRedo) {
        [self.undoManager redo];
    }
}

/// 能否恢复
- (BOOL)canRedo {
    return self.undoManager.canRedo;
}

/// 添加新页面的插入位置
- (void)setPageInsertType:(PageInsertType)pageInsertType {
    _whiteboard.pageInsertType = pageInsertType;
}
- (PageInsertType)pageInsertType {
    return _whiteboard.pageInsertType;
}
/// 新建一个页面
- (void)createNewPage {
    Page *page = [Page page];
    Page *oldPage = _whiteboard.currentPage;
    [_whiteboard addGraphic:page];
    //
    [_drawer clearContent];
    self.whiteboard.currentPage.snapshoot = [self.drawer drawGraphic:self.whiteboard.currentPage backgroundImage:self.whiteboard.currentPage.background];
    self.whiteboard.currentPage.smallSnapshoot = [self.smallDrawer drawGraphic:self.whiteboard.currentPage backgroundImage:self.whiteboard.currentPage.background];
    //
    _onWhitebaordChangeBlock? _onWhitebaordChangeBlock(self, WhiteboardManagerPayloadInit(PageChangeType_AddPage, page, oldPage, _whiteboard.pages)): nil;
}

/// 删除当前页
- (void)removeCurrentPage {
    [self removePage:_whiteboard.currentPage.id];
}

/// 删除一个页面
- (void)removePage:(NSString *)pageId {
    Page *page = _whiteboard.pagesMap[pageId];
    BOOL isCurrentPage = [_whiteboard isCurrentPageOfGraphicId:pageId];

    if (isCurrentPage) {
        [_whiteboard removeGraphicWithId:pageId];
        [_drawer clearContent];
        self.whiteboard.currentPage.snapshoot = [self.drawer drawGraphic:self.whiteboard.currentPage backgroundImage:self.whiteboard.currentPage.background];
        self.whiteboard.currentPage.smallSnapshoot = [self.smallDrawer drawGraphic:self.whiteboard.currentPage backgroundImage:self.whiteboard.currentPage.background];
        //
        _onWhitebaordChangeBlock? _onWhitebaordChangeBlock(self, WhiteboardManagerPayloadInit(PageChangeType_RemovePage, page, _whiteboard.currentPage, _whiteboard.pages)): nil;
    } else {
        [_whiteboard removeGraphicWithId:pageId];
        //
        _onWhitebaordChangeBlock? _onWhitebaordChangeBlock(self, WhiteboardManagerPayloadInit(PageChangeType_RemovePage, page, _whiteboard.currentPage, _whiteboard.pages)): nil;
    }
}

/// 选中一个页面
- (void)selectePageId:(NSString *)pageId {
    [_whiteboard selectePageId:pageId];
}

/// 给某一个页面设置背景图片
- (void)setBackground:(UIImage * _Nullable)background toPage:(NSString *)pageId {
    Page *page = _whiteboard.pagesMap[pageId];
    if (page) {
        page.background = background;
        if ([_whiteboard.currentPage.id isEqualToString:pageId]) {
            [_drawer clearContent];
            self.whiteboard.currentPage.snapshoot = [self.drawer drawGraphic:self.whiteboard.currentPage backgroundImage:self.whiteboard.currentPage.background];
            self.whiteboard.currentPage.smallSnapshoot = [self.smallDrawer drawGraphic:self.whiteboard.currentPage backgroundImage:self.whiteboard.currentPage.background];
        }
        _onWhitebaordChangeBlock? _onWhitebaordChangeBlock(self, WhiteboardManagerPayloadInit(PageChangeType_UpdatePage, page, _whiteboard.currentPage, _whiteboard.pages)): nil;
    }
}

- (NSArray<UIImage *> *)getImages {
    return [self getImagesWithSize:_drawer.size];
}

- (NSArray<UIImage *> *)getImagesWithSize:(CGSize)size {
    NSMutableArray<UIImage *> *images = NSMutableArray.array;
    if (CGSizeEqualToSize(_drawer.size, size)) {
        [_whiteboard.pages enumerateObjectsUsingBlock:^(Page * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            UIImage *image = obj.snapshoot;
            if (image) {
                [images addObject:image];
            }
        }];
        return images;
    }
    
    Drawer *drawer = [self getDrawerWithSize:size];
    [self.pages enumerateObjectsUsingBlock:^(Page * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [drawer clearContent];
        UIImage *image = [drawer drawGraphic:obj backgroundImage:obj.background];
        if (image) {
            [images addObject:image];
        }
    }];
    return images;
}

/// 生成一个同比例缩放的绘制器
- (Drawer *)getDrawerWithSize:(CGSize)size {
    CGSize scale = CGSizeMake(size.width / _drawer.size.width, size.height / _drawer.size.height);
    return [Drawer drawWithSize:size scale:scale pixellateRows:self.drawer.rows];;
}

- (Page *)currentPage {
    return _whiteboard.currentPage;
}

- (NSArray<Page *> *)pages {
    return _whiteboard.pages;
}

- (NSDictionary<NSString *,Page *> *)pagesMap {
    return _whiteboard.pagesMap;
}

- (NSInteger)getPageIndex:(NSString *)pageId {
    return [_whiteboard getPageIndex:pageId];
}

- (CGFloat)lineWidth {
    return _onGetLineWidthBlock? _onGetLineWidthBlock(self): 0;;
}

- (UIColor *)color {
    return _onGetColorBlock? _onGetColorBlock(self): UIColor.clearColor;;
}

@end
