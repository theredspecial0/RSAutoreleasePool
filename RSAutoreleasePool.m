//
//  RSAutoreleasePool.m
//  RSAutoreleasePool
//
//  Created by Dipro on 5/9/23.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

#import "RSAutoreleasePool.h"


@implementation RSAutoreleasePool

+ (CFMutableArrayRef)_threadPoolStack {
    static CFMutableArrayRef threadLocalStack = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        threadLocalStack = CFArrayCreateMutable(NULL, 0, NULL);
        CFRunLoopObserverRef observer = CFRunLoopObserverCreateWithHandler(NULL, kCFRunLoopBeforeWaiting, true, 0, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
            CFIndex count = CFArrayGetCount(threadLocalStack);
            for (CFIndex index = 0; index < count; index++) {
                id obj = (__bridge id)(CFArrayGetValueAtIndex(threadLocalStack, index));
                if (obj != nil) {
                    CFArrayRemoveValueAtIndex(threadLocalStack, index);
                    [obj release];
                    index--; count--;
                }
            }
        });
        CFRunLoopAddObserver(CFRunLoopGetMain(), observer, kCFRunLoopCommonModes);
        CFRelease(observer);
    });
    return threadLocalStack;
}

- (instancetype)init {
    if (self = [super init]) {
        _objects = CFArrayCreateMutable(NULL, 0, NULL);
        CFArrayAppendValue([self.class _threadPoolStack], (__bridge void *)self);
    }
    return self;
}

+ (void)addObject:(id)object {
    CFArrayRef array = [self _threadPoolStack];
    if (CFArrayGetCount(array) == 0) {
        fprintf(stderr, "Object of class %s autoreleased with no pool", class_getName(object_getClass(object)));
    } else {
        RSAutoreleasePool *pool = (__bridge RSAutoreleasePool *)CFArrayGetValueAtIndex(array, (CFArrayGetCount(array) - 1));
        [pool addObject:object];
    }
}

- (void)addObject:(id)object {
    [(NSMutableArray *)_objects addObject:object];
}

- (void)dealloc {
    CFMutableArrayRef stack = [[self class] _threadPoolStack];
    CFIndex index = CFArrayGetCount(stack);
    
    while (index-- > 0) {
        RSAutoreleasePool *pool = (RSAutoreleasePool *)CFArrayGetValueAtIndex(stack, index);
        if (pool == self) {
            CFArrayGetValueAtIndex(stack, index);
            break;
        } else {
            [pool release];
        }
    }
    [super dealloc];
}

- (void)drain {
    for (id object in (id)_objects) {
        [object release];
        CFArrayRemoveAllValues(_objects);
    }
}

@end
