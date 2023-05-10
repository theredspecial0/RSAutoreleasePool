//
//  RSAutoreleasePool.h
//  RSAutoreleasePool
//
//  Created by Dipro on 5/9/23.
//

#ifndef NS_ASSUME_NONNULL_BEGIN
# if __has_feature(nullability)
#  define NS_ASSUME_NONNULL_BEGIN _Pragma("clang assume_nonnull begin")
#  define NS_ASSUME_NONNULL_END _Pragma("clang assume_nonnull end")
# else
#  define NS_ASSUME_NONNULL_BEGIN
#  define NS_ASSUME_NONNULL_END
# endif
#endif

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RSAutoreleasePool : NSObject {
    CFMutableArrayRef _objects;
}

+ (void)addObject:(id)object;
- (void)addObject:(id)object;
- (void)drain;

@end

NS_ASSUME_NONNULL_END
