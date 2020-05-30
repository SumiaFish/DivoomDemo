//
//  WhiteboardViewController.m
//  DiVoomDemo
//
//  Created by kevin on 2020/5/28.
//  Copyright © 2020 kevin. All rights reserved.
//

#import "UIViewController+SimpleAlert.h"
#import "WhiteboardViewController.h"

#import "WhiteboardManager.h"

#import "DrawView.h"
#import "ColorPickerView.h"
#import "PagesListView.h"
#import "PlayerView.h"

#define Rows (32)

@interface WhiteboardViewController ()
<UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (strong, nonatomic) WhiteboardManager *whiteboardManager;

@property (strong, nonatomic) ColorPickerView *colorPickerView;
@property (strong, nonatomic) DrawView *drawArea;
@property (strong, nonatomic) PlayerView *player;
@property (strong, nonatomic) PagesListView *listView;
@property (strong, nonatomic) UIButton *undoButton;
@property (strong, nonatomic) UIButton *redoButton;
@property (strong, nonatomic) UIButton *saveButton;
@property (strong, nonatomic) UIButton *playButton;
@property (strong, nonatomic) UIButton *imagePickerButton;

@end

@implementation WhiteboardViewController

- (void)dealloc {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initWhiteboard];
    
    [self initRightBar];

    [self initDrawView];

    [self initListView];
    
    [self initButtons];
    
    [self initColorPickerView];
    
    [self initPlayer];
}

- (void)initWhiteboard {
    __weak typeof(self) ws = self;
    CGSize size = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.width);
    _whiteboardManager = [[WhiteboardManager alloc] initWithSize:size defaultBackground:nil];
    
    [_whiteboardManager setDrawer:[Drawer drawWithSize:size scale:CGSizeMake(1, 1) pixellateRows:Rows]];
    
    [_whiteboardManager setSmallDrawer:[Drawer drawWithSize:CGSizeMake(100, 100) scale:CGSizeMake(100/size.width, 100/size.height)]];
    
    _whiteboardManager.pageInsertType = PageInsertType_AfterSelectePage;
    
//    _whiteboardManager.pixellate = [KVPixellate pixellateWithSize:size scale:size.width / Rows];
    
    _whiteboardManager.onGetLineWidthBlock = ^CGFloat(id<WhiteboardManagerProtocol>  _Nonnull object) {
        return 8;
    };
    
    _whiteboardManager.onGetColorBlock = ^UIColor * _Nonnull(id<WhiteboardManagerProtocol>  _Nonnull object) {
        return ws.colorPickerView.color;
    };
    
    _whiteboardManager.onWhitebaordChangeBlock = ^(id<WhiteboardManagerProtocol>  _Nonnull object, WhiteboardManagerPayload * _Nonnull payload) {
        
        ws.drawArea.content = payload.page.snapshoot;
        
        PageChangeType type = payload.type;
        if (type == PageChangeType_AddPage ||
            type == PageChangeType_RemovePage) {
            ws.undoButton.enabled = object.canUndo;
            ws.redoButton.enabled = object.canRedo;
            [ws.listView changePage:payload.page currenPage:payload.currentPage pages:payload.pages isInsert:type == PageChangeType_AddPage];
        } else if (type == PageChangeType_UpdatePage) {
            if (object.isDrawing == NO) {
                ws.undoButton.enabled = object.canUndo;
                ws.redoButton.enabled = object.canRedo;
            }
            [ws.listView updatePage:payload.page];
        } else if (type == PageChangeType_SelectePage) {
            ws.undoButton.enabled = object.canUndo;
            ws.redoButton.enabled = object.canRedo;
            [ws.listView selectePage:payload.page];
        }

    };
}

- (void)initRightBar {
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"ColorPick" style:(UIBarButtonItemStylePlain) target:self action:@selector(pickColor)];
    self.navigationItem.rightBarButtonItem = item;
}

- (void)initDrawView {
    __weak typeof(self) ws = self;
    CGSize size = _whiteboardManager.size;
    DrawView *drawArea = [[DrawView alloc] init];
    [self.view addSubview:drawArea];
    drawArea.background = [Drawer drawBackgroundWithSize:size rows:Rows];
    drawArea.frame = CGRectMake(0, 0, size.width, size.width);
    _drawArea = drawArea;
    
    _drawArea.onDrawBeginBlock = ^(CGPoint point) {
        [ws.whiteboardManager beginDraw:point];
    };
    
    _drawArea.onDrawMoveBlock = ^(CGPoint point) {
        [ws.whiteboardManager drawPoint:point];
    };
    
    _drawArea.onDrawEndBlock = ^(CGPoint point) {
        [ws.whiteboardManager endDraw];
    };
}

- (void)initColorPickerView {
    ColorPickerView *colorPickerView = [[ColorPickerView alloc] init];
    [self.view addSubview:colorPickerView];
    colorPickerView.frame = self.view.bounds;
    [colorPickerView display:NO animate:NO];
    _colorPickerView = colorPickerView;
}

- (void)initPlayer {
    PlayerView *player = [PlayerView new];
    [self.view addSubview:player];
    player.frame = self.view.bounds;
    [player display:NO animate:NO];
    _player = player;
}

- (void)initListView {
    __weak typeof(self) ws = self;
    CGSize size = CGSizeMake(100, 100);
    PagesListView *listView = [[PagesListView alloc] init];
    [self.view addSubview:listView];
    listView.frame = CGRectMake(0, CGRectGetMaxY(self.drawArea.frame) + 10, self.view.bounds.size.width, size.height);
    listView.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.2];
    
    listView.onSelectePageBlock = ^(Page * _Nonnull page) {
        [ws.whiteboardManager selectePageId:page.id];
    };
    
    [listView changePage:_whiteboardManager.currentPage currenPage:_whiteboardManager.currentPage pages:_whiteboardManager.pages isInsert:NO];
    [listView selectePage:_whiteboardManager.currentPage];
    
    _listView = listView;
}

- (void)initButtons {
    //
    UIButton *undoButton = [UIButton buttonWithType:(UIButtonTypeSystem)];
    [self.view addSubview:undoButton];
    undoButton.frame = CGRectMake(0, CGRectGetMaxY(self.listView.frame) + 10, 100, 44);
    [undoButton setTitle:@"后退" forState:(UIControlStateNormal)];
    [undoButton addTarget:self action:@selector(undo) forControlEvents:(UIControlEventTouchUpInside)];
    undoButton.enabled = NO;
    _undoButton = undoButton;
    
    UIButton *redoButton = [UIButton buttonWithType:(UIButtonTypeSystem)];
    [self.view addSubview:redoButton];
    redoButton.frame = CGRectMake(self.view.bounds.size.width - 100, undoButton.frame.origin.y, 100, 44);
    [redoButton setTitle:@"前进" forState:(UIControlStateNormal)];
    [redoButton addTarget:self action:@selector(redo) forControlEvents:(UIControlEventTouchUpInside)];
    redoButton.enabled = NO;
    _redoButton = redoButton;
    
    UIButton *saveButton = [UIButton buttonWithType:(UIButtonTypeSystem)];
    [self.view addSubview:saveButton];
    saveButton.frame = CGRectMake(0, CGRectGetMaxY(undoButton.frame)+10, 80, 44);
    [saveButton setTitle:@"新建" forState:(UIControlStateNormal)];
    [saveButton addTarget:self action:@selector(createNewPage) forControlEvents:(UIControlEventTouchUpInside)];
//    redoButton.enabled = NO;
    _saveButton = saveButton;
    
    //
    UIButton *imagePickerButton = [UIButton buttonWithType:(UIButtonTypeSystem)];
    [self.view addSubview:imagePickerButton];
    imagePickerButton.frame = CGRectMake(100, saveButton.frame.origin.y, 100, 44);
    [imagePickerButton setTitle:@"图片" forState:(UIControlStateNormal)];
    [imagePickerButton addTarget:self action:@selector(pickImage) forControlEvents:(UIControlEventTouchUpInside)];
//    redoButton.enabled = NO;
    _imagePickerButton = imagePickerButton;
    
    //
    UIButton *playButton = [UIButton buttonWithType:(UIButtonTypeSystem)];
    [self.view addSubview:playButton];
    playButton.frame = CGRectMake(self.view.bounds.size.width - 100, saveButton.frame.origin.y, 100, 44);
    [playButton setTitle:@"播放" forState:(UIControlStateNormal)];
    [playButton addTarget:self action:@selector(play) forControlEvents:(UIControlEventTouchUpInside)];
//    redoButton.enabled = NO;
    _playButton = playButton;
}

#pragma mark - KVUIViewDisplayDelegate

- (void)onView:(UIView *)view display:(BOOL)isDisplay animate:(BOOL)animate {
    if (view == _colorPickerView ||
        view == _player) {
        [UIView animateWithDuration:animate? 0.8: 0 animations:^{
            view.alpha = isDisplay ? 1 : 0;
        }];
    }
}

#pragma mark - UINavigationControllerDelegate, UIImagePickerControllerDelegate

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //获取源图像（未经裁剪）
    UIImage *originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
//    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
//        UIImageWriteToSavedPhotosAlbum(originalImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
//    }

    //
    __weak typeof(self) ws = self;
    [picker dismissViewControllerAnimated:YES completion:^{
        UIImage *image = [Drawer customImageWith:originalImage toSize:ws.whiteboardManager.size];
        [ws.whiteboardManager setBackground:image toPage:ws.whiteboardManager.currentPage.id];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)image:(UIImage*)image didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo {
    if (!error) {
        NSLog(@"存储成功");
    } else {
        NSLog(@"存储失败：%@", error);
    }
}

#pragma mark -

- (void)undo {
    [_whiteboardManager undo];
}

- (void)redo {
    [_whiteboardManager redo];
}

- (void)pickColor {
    [_colorPickerView display:YES animate:YES];
}

- (void)createNewPage {
    [_whiteboardManager createNewPage];
}

- (void)play {
    [_player playImages:[_whiteboardManager getImages] animationDuration:3 animationRepeatCount:0];
}

- (void)pickImage {
    [self actionSheetAlertWithTitle:@"选取图片" msg:@"" ops:@[@"相机", @"相册"] ConformBlock:^(NSInteger idx) {
        UIImagePickerController* imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.modalPresentationStyle = UIModalPresentationFullScreen;
        if (idx == 0) {
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        } else {
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
        [self presentViewController:imagePicker animated:YES completion:nil];
    } cancelBlock:^{
        
    }];
}

@end
