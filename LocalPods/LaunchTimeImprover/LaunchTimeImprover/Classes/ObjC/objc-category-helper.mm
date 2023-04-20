//
//  objc-category-helper.m
//  LaunchTimeImprover
//
//  Created by 0xxxD on 2023/4/18.
//

#import "objc-category-helper.h"
#import <mach-o/getsect.h>

category_t * const *getDataSection(const mach_header_t *mhdr, const char *sectname,
                                   size_t *outBytes, size_t *outCount) {
    unsigned long byteCount = 0;
    category_t * const *data = (category_t * const *)getsectiondata(mhdr, "__DATA", sectname, &byteCount);
    if (!data) {
        data = (category_t * const *)getsectiondata(mhdr, "__DATA_CONST", sectname, &byteCount);
    }
    if (!data) {
        data = (category_t * const *)getsectiondata(mhdr, "__DATA_DIRTY", sectname, &byteCount);
    }
    if (outBytes) *outBytes = byteCount;
    if (outCount) *outCount = byteCount / sizeof(category_t *);
    return data;
}


category_t * const *getObjc2CategoryList(const mach_header_t *mh, size_t *count) {
    return getDataSection(mh, "__objc_catlist", nil, count);
}
