//
//  A.m
//  A
//
//  Created by 0xxxD on 2023/4/18.
//

#import "A.h"
#include <sys/sysctl.h>
#include <mach-o/getsect.h>
#include <mach-o/dyld.h>
#include <mach-o/loader.h>
#import <mach-o/ldsyms.h>
#include <mach/mach.h>
#import "XDInjectProtocol.h"

@implementation A
@dynamic loadStartTime, forkStartTime;

static double _loadStartTime = -1;
static double _forkStartTime = -1;

+ (void)load {
    printf("A load called\n");
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _loadStartTime = CACurrentMediaTime();
        _forkStartTime = _loadStartTime - [self getSysctlCurrentTime] + [self getPidForkTime];
        _dyld_register_func_for_add_image(auto_register);
    });
}

+ (double)loadStartTime {
    if (_loadStartTime <= 0) {
        NSAssert(NO, @"_loadStartTime value error or need init");
        return 0;
    }
    return _loadStartTime;
}

+ (double)forkStartTime {
    if (_forkStartTime <= 0) {
        NSAssert(NO, @"_forkStartTIme value error or needs init");
        return 0;
    }
    return _forkStartTime;
}

#pragma mark - time
+ (double)getSysctlCurrentTime {
        struct timeval now_tv;
        gettimeofday(&now_tv,NULL);
        return (double)now_tv.tv_sec + (double)now_tv.tv_usec / USEC_PER_SEC;
}

+ (double)getPidForkTime {
        double pidStartTimeSec;
        pid_t pid = [[NSProcessInfo processInfo] processIdentifier];
        int mib[4] = { CTL_KERN, KERN_PROC, KERN_PROC_PID, pid };
        struct kinfo_proc proc;
        size_t size = sizeof(proc);
        if (sysctl(mib, 4, &proc, &size, NULL, 0) < 0) {
            NSAssert(NO, @"getPidForkTime sysctl fail");
            pidStartTimeSec = -1;
        } else {
            pidStartTimeSec = (double)proc.kp_proc.p_starttime.tv_sec +
            (double)proc.kp_proc.p_starttime.tv_usec / USEC_PER_SEC;
        }
        return pidStartTimeSec;
}

#pragma mark - read macho data section
static void auto_register(const struct mach_header *mhp, intptr_t vmaddr_slide) {
    NSArray *classInfos = _readInjectableRegisterSection("XDInjectProtocol", mhp);
    for (NSString *item in classInfos) {
        Class class = NSClassFromString(item);
        if (class && [class conformsToProtocol:@protocol(XDInjectProtocol)]) {
            [class xd_launch];
        } else {
            NSCAssert(NO, @"register class:%@ not exit or not conform XDFirstLoadRunInjectProtocol", item);
        }
    }
}


NSArray<NSString *>* _readInjectableRegisterSection(char *sectionName,const struct mach_header *mhp) {
    
    NSMutableArray *registerClasses = [NSMutableArray array];
    unsigned long size = 0;
#ifdef __LP64__
    const struct mach_header_64 *mhp64 = (const struct mach_header_64 *)mhp;
    uintptr_t *memory = (uintptr_t*)getsectiondata(mhp64, SEG_DATA, sectionName, &size);
#else
    uintptr_t *memory = (uintptr_t*)getsectiondata(mhp, SEG_DATA, sectionName, &size);
#endif
    
    unsigned long counter = size / sizeof(void*);
    for(int idx = 0; idx < counter; ++idx){
        char *string = (char*)memory[idx];
        NSString *str = [NSString stringWithUTF8String:string];
        if(!str)continue;
        
        if(str) [registerClasses addObject:str];
    }
    
    return registerClasses;
}
@end
