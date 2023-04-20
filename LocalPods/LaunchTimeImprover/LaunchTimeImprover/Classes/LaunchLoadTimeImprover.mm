//
//  LaunchTimeImprover.m
//  LaunchTimeImprover
//
//  Created by 0xxxD on 2023/4/18.
//

#import "LaunchLoadTimeImprover.h"
#import <A/XDInjectProtocol.h>
#import <mach-o/ldsyms.h>
#import <mach-o/dyld.h>
#import <objc/runtime.h>
#import "objc-runtime.h"
#import "objc-category-helper.h"
#import <list>
#include <iostream>
#import <unordered_set>
#import <map>

using namespace std;

typedef void(*imp_t)(id, SEL);

typedef struct {
    imp_t imp;
    Class cls;
} load_cache_t;

typedef struct {
    Class cls;
    char const *name;
} category_info_t;

category_info_t CategoryInfoConstructor(Class cls, char const *name) {
    return (category_info_t) {
        .cls = cls,
        .name = name
    };
}
string CategoryGetID(category_info_t cat) {
    return string(class_getName(cat.cls)) + string(cat.name);
}


XDFirstLoadRunInjectDefine(LaunchLoadTimeImprover)
@interface LaunchLoadTimeImprover() <XDInjectProtocol>

@end

@implementation LaunchLoadTimeImprover

+ (void)xd_launch {
    [self processCategoryLoad];
    [self processClzLoad];
}

+ (void)processClzLoad {
    Method fakeMethod = class_getClassMethod(self.class, @selector(fakeLoad));
    IMP fakeLoadIMP = method_getImplementation(fakeMethod);

    auto list = embeddingLoad();
    for (auto it = list.begin(); it != list.end(); it++) {
        auto cls = objc_getClass(it->c_str());
        assert(cls != nil);
        if (cls == nil) {
            continue;
        }
        Method loadMethod = class_getClassMethod(cls, @selector(load));
        if (loadMethod == nil) {
            continue;
        }
        
        IMP imp = method_getImplementation(loadMethod);
        store((imp_t)imp, cls);
        method_setImplementation(loadMethod, fakeLoadIMP);
    }

}

+ (void)processCategoryLoad {
    unordered_set<string> targetLoadIds = targetCategoryLoadIDs();
    if (targetLoadIds.empty()) {
        return;
    }

    const mach_header_t *mhdr = &_mh_execute_header;

    size_t count;
    Method fakeMethod = class_getClassMethod(self.class, @selector(fakeLoad));
    IMP fakeLoadIMP = method_getImplementation(fakeMethod);

    auto processCategoryList = [&](category_t * const *catlist) {
        for (int i = 0; i < count; i++) {
            category_t *cat = catlist[i];
            if (cat == NULL) {
                continue;
            }

            Class cls = (__bridge Class)cat->cls;
            method_list_t *classMethods = cat->classMethods;
            
            if (cls == NULL || classMethods == NULL) {
                continue;
            }
            string identifier = CategoryGetID(CategoryInfoConstructor(cls, cat->name));
            if (targetLoadIds.find(identifier) == targetLoadIds.end()) {
                continue;
            }
            
            for (auto it = classMethods->begin(); it != classMethods->end(); it++) {
                if(strcmp(sel_getName(it->name), "load") == 0) {
                    store((imp_t)it->imp, cls);
                    cout << "processCategoryLoad success\n";
                    method_setImplementation((Method)it.element, fakeLoadIMP);
                    targetLoadIds.erase(identifier);
                    break;
                }
            }
            if (targetLoadIds.empty()) {
                break;
            }
        }
    };

    processCategoryList(getObjc2CategoryList(mhdr, &count));
}

#pragma mark - Helper Func
NS_INLINE list<string> embeddingLoad() {
    return list<string>(
   {
       "QCloudAbstractRequest",
       "QCloudQCloudCOSXMLLoad",
       "QCloudQCloudCoreLoad",
       "QCloudCOSXMLService",
       "QCloudRequestData",
    }
                                  );
}

unordered_set<string> targetCategoryLoadIDs() {
    unordered_set<string> targetLoadIds;

    category_info_t rawList[] = {
        CategoryInfoConstructor(UINavigationController.class, "FDFullscreenPopGesture"),
        CategoryInfoConstructor(UIViewController.class, "FDFullscreenPopGesturePrivate"),
    };
    list<category_info_t> list(rawList, rawList + sizeof(rawList) / sizeof(category_info_t));

    for (auto it = list.begin(); it != list.end(); it++) {
        targetLoadIds.insert(CategoryGetID(*it));
    }

    return targetLoadIds;
}


void store(imp_t imp, Class cls) {
    impStore().push_back((load_cache_t){ imp, cls });
}


static list<load_cache_t> & impStore() {
    static list<load_cache_t> _imp_map;
    return _imp_map;
}

#pragma mark - callLoad
+ (void)callLoad {
    for (auto it = impStore().begin(); it != impStore().end(); it++) {
        ((*it).imp)((*it).cls, @selector(load));
    }
}


#pragma mark - fakeIMP
+ (void)fakeLoad {
    NSLog(@"fakeLoad");
}

@end
