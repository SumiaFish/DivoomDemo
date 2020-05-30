//
//  PagesListView.h
//  DiVoomDemo
//
//  Created by kevin on 2020/5/29.
//  Copyright © 2020 kevin. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "WhiteboardManager.h"

NS_ASSUME_NONNULL_BEGIN

@protocol PagesListViewProtocol <NSObject>

@property (weak, nonatomic) NSArray<Page *> *pages;

@property (copy, nonatomic) void (^ onSelectePageBlock) (Page *page);

- (void)changePage:(Page *)page currenPage:(Page *)currenPage pages:(NSArray<Page *> *)pages isInsert:(BOOL)isInsert;
- (void)updatePage:(Page *)page;
- (void)selectePage:(Page *)page;

@end

@interface PagesListView : UIView
<PagesListViewProtocol>

@end

NS_ASSUME_NONNULL_END
