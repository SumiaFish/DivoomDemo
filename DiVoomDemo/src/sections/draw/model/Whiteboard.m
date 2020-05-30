//
//  Whiteboard.m
//  DiVoomDemo
//
//  Created by kevin on 2020/5/29.
//  Copyright © 2020 kevin. All rights reserved.
//

#import "Whiteboard.h"

@interface Graphic ()

@property (copy, nonatomic) NSString *id;
@property (weak, nonatomic) Graphic *superGraphic;
@property (strong, nonatomic) NSMutableArray<Graphic *> *graphics;
@property (strong, nonatomic) NSMutableDictionary<NSString *, Graphic *> *graphicsMap;
@property (strong, nonatomic) Graphic *current;

@end

@implementation Graphic

- (NSMutableArray<Graphic *> *)graphics {
    if (!_graphics) {
        _graphics = NSMutableArray.array;
    }
    return _graphics;
}

- (NSMutableDictionary<NSString *,Graphic *> *)graphicsMap {
    if (!_graphicsMap) {
        _graphicsMap = NSMutableDictionary.dictionary;
    }
    return _graphicsMap;
}


- (void)addGraphic:(id<GraphicsProtocol>)graphic {
    
}

- (void)removeGraphic:(id<GraphicsProtocol>)graphic {
    
}

- (void)removeGraphicWithId:(NSString *)id {
    
}

@end

@interface ZPoint ()

@end

@implementation ZPoint

+ (instancetype)pointX:(CGFloat)x y:(CGFloat)y lineWidth:(CGFloat)lineWidth color:(UIColor *)color {
    return [[ZPoint alloc] initWithId:NSUUID.UUID.UUIDString x:x y:y lineWidth:lineWidth color:color];
}

- (instancetype)initWithId:(NSString *)id x:(CGFloat)x y:(CGFloat)y lineWidth:(CGFloat)lineWidth color:(UIColor *)color {
    if (self = [super init]) {
        self.id = id;
        _x = x;
        _y = y;
        _lineWidth = lineWidth;
        _color = color;
    }
    return self;
}

- (instancetype)init {
    return nil;
}

- (Line *)line {
    return [self.superGraphic isKindOfClass:Line.class] ? (Line *)self.superGraphic : nil;
}

- (CGPoint)getPoint {
    return CGPointMake(_x, _y);
}

@end

@interface Line ()

@end

@implementation Line

+ (instancetype)line {
    return [[Line alloc] initWithId:NSUUID.UUID.UUIDString];
}

- (instancetype)initWithId:(NSString *)id {
    if (self = [super init]) {
        self.id = id;
    }
    return self;
}

- (instancetype)init {
    return nil;
}

- (Page *)page {
    return [self.superGraphic isKindOfClass:Page.class] ? (Page *)self.superGraphic : nil;
}

- (ZPoint *)lastPoint:(ZPoint *)point {
    if ([point.id isEqualToString:self.currentPoint.id]) {
        if (self.points.count > 1) {
            return self.points[self.points.count-2];
        }
    }
    __block ZPoint *res = nil;
    [self.points enumerateObjectsUsingBlock:^(ZPoint * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.id isEqualToString:point.id]) {
            if (idx > 0) {
                res = self.points[idx-1];
                *stop = YES;
            }
        }
    }];
    return res;
}

- (ZPoint *)currentPoint {
    if ([self.current isKindOfClass:ZPoint.class]) {
        return (ZPoint *)self.current;
    }
    return nil;
}

- (NSArray<ZPoint *> *)points {
    return (NSArray<ZPoint *> *)self.graphics;
}

- (void)addGraphic:(id<GraphicsProtocol>)graphic {
    if ([graphic isKindOfClass:ZPoint.class]) {
        ZPoint *point = (ZPoint *)graphic;
        point.superGraphic = self;
        [self.graphics addObject:point];
        self.graphicsMap[point.id] = point;
        self.current = point;
    }
}

- (void)removeGraphic:(id<GraphicsProtocol>)graphic {
    if ([graphic isKindOfClass:ZPoint.class]) {
        ZPoint *point = (ZPoint *)graphic;
        if ([self.graphics containsObject:point]) {
            [self.graphics removeObject:point];
            [self.graphicsMap removeObjectForKey:point.id];
        } else {
            [self removeGraphicWithId:point.id];
        }
        
        if ([self.current.id isEqualToString:graphic.id]) {
            self.current = nil;
        }
    }
}

- (void)removeGraphicWithId:(NSString *)id {
    [self.graphics enumerateObjectsUsingBlock:^(Graphic * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.id isEqualToString:id]) {
            [self.graphics removeObject:obj];
            [self.graphicsMap removeObjectForKey:obj.id];
        }
    }];
    
    if ([self.current.id isEqualToString:id]) {
        self.current = nil;
    }
}

@end

@interface Page ()

@property (weak, nonatomic) Whiteboard *whiteboard;
@property (assign, nonatomic, readonly) BOOL didSetBackground;

@end

@implementation Page

- (void)dealloc {
    
}

+ (instancetype)page {
    return [[self alloc] initWithId:NSUUID.UUID.UUIDString];
}

- (instancetype)initWithId:(NSString *)id {
    if (self = [super init]) {
        self.id = id;
    }
    return self;
}

- (instancetype)init {
    return nil;
}

- (Line *)currentLine {
    if ([self.current isKindOfClass:Line.class]) {
        return (Line *)self.current;
    }
    return nil;
}

- (NSArray<Line *> *)lines {
    return (NSArray<Line *> *)self.graphics;
}

- (void)addGraphic:(id<GraphicsProtocol>)graphic {
    if ([graphic isKindOfClass:Line.class]) {
        Line *line = (Line *)graphic;
        line.superGraphic = self;
        [self.graphics addObject:line];
        self.graphicsMap[line.id] = line;
        self.current = line;
    }
}

- (void)removeGraphic:(id<GraphicsProtocol>)graphic {
    if ([graphic isKindOfClass:Line.class]) {
        Line *line = (Line *)graphic;
        if ([self.graphics containsObject:line]) {
            [self.graphics removeObject:line];
            [self.graphicsMap removeObjectForKey:line.id];
        } else {
            [self removeGraphicWithId:line.id];
        }
    }
    
    if ([self.current.id isEqualToString:graphic.id]) {
        self.current = nil;
    }
}

- (void)removeGraphicWithId:(NSString *)id {
    [self.graphics enumerateObjectsUsingBlock:^(Graphic * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.id isEqualToString:id]) {
            [self.graphics removeObject:obj];
            [self.graphicsMap removeObjectForKey:obj.id];
        }
    }];
    
    if ([self.current.id isEqualToString:id]) {
        self.current = nil;
    }
}

- (void)setBackground:(UIImage *)background {
    _background = background;
    _didSetBackground = YES;
}

@end

@interface Whiteboard ()

@property (copy, nonatomic, readwrite) NSString *id;
@property (strong, nonatomic) Page *currentPage;
@property (strong, nonatomic, readwrite) NSMutableArray<Page *> *pages;
@property (strong, nonatomic) NSMutableDictionary<NSString *, Page *> *pagesMap;

@end

@implementation Whiteboard

- (void)dealloc {
    
}

+ (instancetype)whiteboardWithSize:(CGSize)size defaultBackground:(UIImage *)defaultBackground {
    return [[self alloc] initWithId:NSUUID.UUID.UUIDString size:size defaultBackground:defaultBackground];
}

- (instancetype)initWithId:(NSString *)id size:(CGSize)size defaultBackground:(UIImage *)defaultBackground {
    if (self = [super init]) {
        self.id = id;
        _size = size;
        _defaultBackground = defaultBackground;
        
        _currentPage = [Page page];
        _pages = NSMutableArray.array;
        _pagesMap = NSMutableDictionary.dictionary;
        
        [_pages addObject:_currentPage];
        _pagesMap[_currentPage.id] = _currentPage;
        _currentPage.whiteboard = self;
    }
    return self;
}

- (instancetype)init {
    return nil;
}

- (Line *)currentLine {
    return _currentPage.currentLine;
}

- (ZPoint *)currentPoint {
    return _currentPage.currentLine.currentPoint;
}

- (void)selectePageId:(NSString *)pageId {
    Page *page = _pagesMap[pageId];
    if (page && ![page.id isEqualToString:_currentPage.id]) {
        Page *oldPage = _currentPage;
        _currentPage = page;
        _onSeletePageChangeBlock? _onSeletePageChangeBlock(self, oldPage, page): nil;
    }
}

- (void)addGraphic:(Graphic *)graphic {
    if ([graphic isKindOfClass:Page.class]) {
        Page *page = (Page *)graphic;
        page.whiteboard = self;
        if (page.didSetBackground == NO) {
            page.background = self.defaultBackground;
        }
        if (_pageInsertType == PageInsertType_Append) {
            [_pages addObject:page];
        } else if (_pageInsertType == PageInsertType_AfterSelectePage) {
            __block NSInteger index = NSNotFound;
            [_pages enumerateObjectsUsingBlock:^(Page * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj.id isEqualToString:self.currentPage.id]) {
                    index = idx+1;
                    *stop = YES;
                }
            }];
            if (_pages.count >= index) {
                [_pages insertObject:page atIndex:index];
            }
        }
        _pagesMap[page.id] = page;
        [self selectePageId:page.id];
        return;
    }
    
    if ([graphic isKindOfClass:Line.class]) {
        Line *line = (Line *)graphic;
        [_currentPage addGraphic:line];
        return;
    }
    
    if ([graphic isKindOfClass:ZPoint.class]) {
        ZPoint *point = (ZPoint *)graphic;
        [self.currentLine addGraphic:point];
        return;
    }
}

- (void)removeGraphic:(Graphic *)graphic {
    if ([graphic isKindOfClass:Page.class]) {
        [self removeGraphicWithId:graphic.id];
        return;
    }
    
    if ([graphic isKindOfClass:Line.class]) {
        Line *line = (Line *)graphic;
        [line.page removeGraphicWithId:graphic.id];
        return;
    }
    
    if ([graphic isKindOfClass:ZPoint.class]) {
        ZPoint *point = (ZPoint *)graphic;
        [point.line removeGraphicWithId:graphic.id];
        return;
    }
}

- (void)removeGraphicWithId:(NSString *)id {
    if (_pagesMap[id]) {
        if (_pages.count <= 1) {
            return;
        }
        BOOL willRemoveCurrentPage = [self.currentPage.id isEqualToString:id];
        NSInteger removeIdx = NSNotFound;
        for (NSInteger i = 0; i < _pages.count; i++) {
            Page *p = _pages[i];
            if ([p.id isEqualToString:id]) {
                removeIdx = i;
                if (willRemoveCurrentPage) {
                    if (i == 0) {
                        [self selectePageId:_pages[i+1].id];
                    } else {
                        [self selectePageId:_pages[i-1].id];
                    }
                }
                break;
            }
        }
        if (removeIdx != NSNotFound) {
            [_pages removeObjectAtIndex:removeIdx];
        }
        [_pagesMap removeObjectForKey:id];
        
        return;
    }
    
    
    if (_currentPage.graphicsMap[id]) {
        [_currentPage removeGraphicWithId:id];
        return;
    }
    
    if (_currentPage.currentLine.graphicsMap[id]) {
        [_currentPage.currentLine removeGraphicWithId:id];
        return;
    }
    
    [_pages enumerateObjectsUsingBlock:^(Page * _Nonnull page, NSUInteger idx, BOOL * _Nonnull stop) {
        if (page.graphicsMap[id]) {
            [page removeGraphicWithId:id];
            *stop = YES;
        } else {
            [page.lines enumerateObjectsUsingBlock:^(Line * _Nonnull line, NSUInteger idx, BOOL * _Nonnull stop) {
                if (line.graphicsMap[id]) {
                    [line removeGraphicWithId:id];
                    *stop = YES;
                }
            }];
        }
    }];
    
}

- (NSInteger)getPageIndex:(NSString *)pageId {
    __block NSInteger res = NSNotFound;
    [_pages enumerateObjectsUsingBlock:^(Page * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.id isEqualToString:pageId]) {
            res = idx;
            *stop = YES;
        }
    }];
    return res;
}

- (BOOL)isCurrentPageOfGraphic:(Graphic *)graphic {
    NSString *id = graphic.id;
    return [self isCurrentPageOfGraphicId:id];
}

- (BOOL)isCurrentPageOfGraphicId:(NSString *)id {
    if ([_currentPage.id isEqualToString:id]) {
        return YES;
    }
    if (_currentPage.graphicsMap[id]) {
        return YES;
    }
    if (_currentPage.currentLine.graphicsMap[id]) {
        return YES;
    }
    return NO;
}

@end
