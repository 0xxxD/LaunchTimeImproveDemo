//
//  LaunchManager.m
//  LaunchManager
//
//  Created by ChenChoi on 2023/4/18.
//

#import "LaunchManager.h"
@import LaunchTimeImprover;

@implementation LaunchManager {
    CFRunLoopObserverRef _mainThreadRunLoopObserever;
}

+ (instancetype)shared {
    static LaunchManager *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[LaunchManager alloc] init];
    });
    return _instance;
}

- (void)handle {
    NSLog(@"Runloop Observer called");
    [self removeObserver];
    [LaunchLoadTimeImprover callLoad];
}

- (void)addIdleObserver {
    __weak typeof(self) weakSelf = self;
    _mainThreadRunLoopObserever = CFRunLoopObserverCreateWithHandler(kCFAllocatorDefault,
                                                    kCFRunLoopBeforeWaiting | kCFRunLoopExit,
                                                    true,
                                                    INT_MAX,
                                                    ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
        [weakSelf handle];
    });
    if (_mainThreadRunLoopObserever) {
        CFRunLoopAddObserver(CFRunLoopGetMain(), _mainThreadRunLoopObserever, kCFRunLoopCommonModes);
    }
}


- (void)removeObserver {
    if (_mainThreadRunLoopObserever) {
        CFRunLoopRemoveObserver(CFRunLoopGetMain(), _mainThreadRunLoopObserever, kCFRunLoopCommonModes);
        CFRelease(_mainThreadRunLoopObserever);
        _mainThreadRunLoopObserever = NULL;
    }
}

@end
