//
//  PagesListView.m
//  DiVoomDemo
//
//  Created by kevin on 2020/5/29.
//  Copyright © 2020 kevin. All rights reserved.
//

#import "PagesListView.h"

@interface PageCell : UICollectionViewCell

@property (weak, nonatomic, readonly) Page *page;
@property (assign, nonatomic, readonly) BOOL isSelecte;
@property (strong, nonatomic, readonly) UIImageView *imgView;
@property (strong, nonatomic, readonly) CAShapeLayer *selecteLayer;

@end

@implementation PageCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _imgView = UIImageView.new;
        self.contentView.backgroundColor = UIColor.clearColor;
        _imgView.backgroundColor = UIColor.blackColor;
        [self.contentView addSubview:_imgView];
        _selecteLayer = CAShapeLayer.layer;
        _selecteLayer.borderColor = UIColor.orangeColor.CGColor;
        _selecteLayer.borderWidth = 4;
        _selecteLayer.hidden = YES;
        [self.contentView.layer insertSublayer:_selecteLayer atIndex:0];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _imgView.frame = CGRectMake(4, 4, CGRectGetWidth(self.contentView.frame)-4*2, CGRectGetHeight(self.contentView.frame)-4*2);
    _selecteLayer.frame = self.contentView.bounds;
}

- (void)setPage:(Page *)page isSelecte:(BOOL)isSelecte {
    _page = page;
    _imgView.image = page.smallSnapshoot;
    _selecteLayer.hidden = !isSelecte;
}

@end

@interface PageEmptyCell : PageCell

@end

@implementation PageEmptyCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.imgView.hidden = YES;
    }
    return self;
}

- (void)setPage:(Page *)page drawer:(Drawer *)drawer isSelecte:(BOOL)isSelecte {
    
}

@end

@interface PagesListView ()
<UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>

@property (strong, nonatomic) UICollectionView *collectionView;
@property (weak, nonatomic) Page *selectePage;
@property (assign, nonatomic) NSInteger rows;
@property (strong, nonatomic) NSMutableArray<NSIndexPath *> *updatingIndexPaths;

@end

@implementation PagesListView

@synthesize pages = _pages;
@synthesize onSelectePageBlock = _onSelectePageBlock;

- (instancetype)init {
    if (self = [super init]) {
        [self collectionView];
        [self updatingIndexPaths];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _collectionView.frame = CGRectMake(0, 0, self.bounds.size.width, 100);
}

- (void)changePage:(Page *)page currenPage:(Page *)currenPage pages:(NSArray<Page *> *)pages isInsert:(BOOL)isInsert {
    NSInteger count = _pages.count > _rows ? (_pages.count-_rows) : (_rows - _pages.count);
    NSMutableArray<NSIndexPath *> *indexPaths = NSMutableArray.array;
    for (NSInteger i = 0; i < count; i ++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:_rows+i inSection:0];
        [indexPaths addObject:indexPath];
    }
    _pages = pages;
    _rows = _pages.count;
    if (indexPaths.count) {
        [_updatingIndexPaths addObjectsFromArray:indexPaths];

        [_collectionView performBatchUpdates:^{
            
            if (isInsert) {
                [self.collectionView insertItemsAtIndexPaths:indexPaths];
            } else {
                [self.collectionView deleteItemsAtIndexPaths:indexPaths];
            }
            
        } completion:^(BOOL finished) {
            
            [self.updatingIndexPaths removeAllObjects];
            [self selectePage:self.selectePage];
            
        }];
    }
}

- (void)updatePage:(Page *)page {
    [_collectionView.indexPathsForVisibleItems enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        Page *p = self.pages[obj.item];
        if ([p.id isEqualToString:page.id]) {
            [self.collectionView reloadItemsAtIndexPaths:@[obj]];
            *stop = YES;
        }
    }];
}

- (void)selectePage:(Page *)page {
    if (self.isUpdating) {
        self.selectePage = page;
        return;
    }
    
    __block NSInteger index = NSNotFound;
    [self.pages enumerateObjectsUsingBlock:^(Page * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([page.id isEqualToString:obj.id]) {
            index = idx;
            *stop = YES;
        }
    }];
    if (index == NSNotFound) {
        return;
    }
    self.selectePage = page;
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    [self.collectionView reloadItemsAtIndexPaths:self.collectionView.indexPathsForVisibleItems];
    [self.collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:(UICollectionViewScrollPositionCenteredHorizontally)];
    
}

//- (void)reloadPages:(NSArray<Page *> *)pages {
//    _pages = pages;
//    [_collectionView reloadData];
//}

- (BOOL)isUpdating {
    return _updatingIndexPaths.count > 0;
}

#pragma mark - UICollectionViewDelegateFlowLayout, UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _rows;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self isUpdating:indexPath]) {
        PageEmptyCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"emptycell" forIndexPath:indexPath];
        return cell;
    }
    
    PageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    Page *page = self.pages[indexPath.item];
    [cell setPage:page isSelecte:[page.id isEqualToString:self.selectePage.id]];
    return cell;
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    Page *page = self.pages[indexPath.item];
    _onSelectePageBlock? _onSelectePageBlock(page): nil;
}

#pragma mark -

- (BOOL)isUpdating:(NSIndexPath *)indexPath {
    __block BOOL res = NO;
    [self.updatingIndexPaths enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.section == indexPath.section && obj.item == indexPath.item) {
            res = YES;
            *stop = YES;
        }
    }];
    return res;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
        collectionViewLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        collectionViewLayout.itemSize = CGSizeMake(100, 100);
        collectionViewLayout.minimumLineSpacing = 0;
        collectionViewLayout.minimumInteritemSpacing = 0;
        collectionViewLayout.sectionInset = UIEdgeInsetsZero;
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:collectionViewLayout];
        collectionView.delegate = self;
        collectionView.dataSource = self;
        [collectionView registerClass:PageCell.class forCellWithReuseIdentifier:@"cell"];
        [collectionView registerClass:PageEmptyCell.class forCellWithReuseIdentifier:@"emptycell"];
        collectionView.backgroundColor = UIColor.clearColor;
        [self addSubview:collectionView];
        _collectionView = collectionView;
    }
    return _collectionView;
}

- (NSMutableArray<NSIndexPath *> *)updatingIndexPaths {
    if (!_updatingIndexPaths) {
        _updatingIndexPaths = NSMutableArray.array;
    }
    return _updatingIndexPaths;
}

@end
