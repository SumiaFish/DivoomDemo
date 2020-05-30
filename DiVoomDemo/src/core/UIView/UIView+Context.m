//
//  UIView+Context.m
//  kvtemplate
//
//  Created by kevin on 2020/5/27.
//  Copyright © 2020 kevin. All rights reserved.
//

#import "UIView+Context.h"

#import <objc/runtime.h>

@interface _KVUIViewContext : NSObject

@property (weak, nonatomic) id context;

@property (weak, nonatomic) id<KVUIViewDisplayDelegate> displayContext;

@end

@implementation _KVUIViewContext

@end

@implementation UIView (Context)

static void* UIViewContextObjectKey = @"UIViewContextObjectKey";

- (void)setContextObj:(_KVUIViewContext *)contextObj {
    objc_setAssociatedObject(self, UIViewContextObjectKey, contextObj, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (_KVUIViewContext *)contextObj {
    return objc_getAssociatedObject(self, UIViewContextObjectKey);
}

@end

@implementation UIView (DisplayContext)

- (void)setDisplayContext:(id<KVUIViewDisplayDelegate>)displayContext {
    if (!self.contextObj) {
        self.contextObj = _KVUIViewContext.new;
    }
    self.contextObj.displayContext = displayContext;
}

- (id<KVUIViewDisplayDelegate>)displayContext {
    return self.contextObj.displayContext;
}

- (void)display:(BOOL)isDisplay {
    [self display:isDisplay animate:NO];
}

- (void)display:(BOOL)isDisplay animate:(BOOL)animate {
    if (self.isDisplay == isDisplay) {
        return;
    }
    if ([self.displayContext respondsToSelector:@selector(onView:display:animate:)]) {
        [self.displayContext onView:self display:isDisplay animate:animate];
    } else {
        self.alpha = isDisplay ? 1 : 0;
    }
}

- (BOOL)isDisplay {
    return self.alpha == 1;
}

@end
