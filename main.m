//
//  main.m
//  RSAutoreleasePool
//
//  Created by Dipro on 5/9/23.
//

#import <Foundation/Foundation.h>

#import "RSAutoreleasePool.h"

int main(int argc, const char **argv) {
    @autoreleasepool {
        RSAutoreleasePool *pool = [[RSAutoreleasePool alloc] init];
        
        NSString *helloString = [NSString stringWithUTF8String:"Hello World!"];
        printf("Reference count: %lu\n", [helloString retainCount]);
        
        [pool addObject:helloString];
        [pool retain];
        printf("Reference count: %lu\n", [helloString retainCount]);
        
        [pool drain];
        printf("Reference count: %lu\n", [helloString retainCount]); // segfault
    }
}
