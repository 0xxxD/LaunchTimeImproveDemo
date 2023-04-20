//
//  A.h
//  A
//
//  Created by 0xxxD on 2023/4/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface A : NSObject
@property (nonatomic, assign, readonly, class) double loadStartTime;
@property (nonatomic, assign, readonly, class) double forkStartTime;

@end

NS_ASSUME_NONNULL_END
