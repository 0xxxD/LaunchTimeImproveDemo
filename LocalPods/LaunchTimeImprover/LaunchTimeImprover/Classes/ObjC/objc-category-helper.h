//
//  objc-category-helper.h
//  LaunchTimeImprover
//
//  Created by 0xxxD on 2023/4/18.
//

#ifndef objc_category_helper_h
#define objc_category_helper_h
#import <Foundation/Foundation.h>
#import "objc-runtime.h"

category_t * const *getObjc2CategoryList(const mach_header_t *mh, size_t *count);
category_t * const *getObjc2CategoryList2(const mach_header_t *mh, size_t *count);

#endif /* objc_category_helper_h */
