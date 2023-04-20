//
//  XDFirstLoadRunInjectProtocol.h
//  A
//
//  Created by 0xxxD on 2023/4/18.
//

#ifndef XDFirstLoadRunInjectProtocol_h
#define XDFirstLoadRunInjectProtocol_h

@protocol XDInjectProtocol <NSObject>
+ (void)xd_launch;
@end


#define XDFIRSTLOADRUNINJECT_ANNOTATION_DATA __attribute((used, section("__DATA,XDInjectProtocol")))
#define XDFirstLoadRunInjectDefine(clazz) \
const char *kXDFirstLoadRunInjection_##clazz XDFIRSTLOADRUNINJECT_ANNOTATION_DATA = ""#clazz"";



#endif /* XDFirstLoadRunInjectProtocol_h */
