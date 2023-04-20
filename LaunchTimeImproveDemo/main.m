//
//  main.m
//  LaunchTimeImproveDemo
//
//  Created by 0xxxD on 2023/4/18.
//

#import <UIKit/UIKit.h>

@import ApplicationModule;
@import LaunchTimeMeasurer;
@import A;

int main(int argc, char * argv[]) {
    [LaunchTimeMeasurer recordMainStart];
    [LaunchTimeMeasurer recordLoadStart:A.loadStartTime];
    [LaunchTimeMeasurer recordForkStart:A.forkStartTime];
    
    NSString * appDelegateClassName;
    @autoreleasepool {
        // Setup code that might create autoreleased objects goes here.
        appDelegateClassName = NSStringFromClass([AppDelegate class]);
    }
    return UIApplicationMain(argc, argv, nil, appDelegateClassName);
}
