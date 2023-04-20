//
//  LaunchManager.h
//  LaunchManager
//
//  Created by ChenChoi on 2023/4/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LaunchManager : NSObject
+ (instancetype)shared;
- (void)addIdleObserver;
@end

NS_ASSUME_NONNULL_END
