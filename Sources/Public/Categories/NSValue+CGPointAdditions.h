#import <Foundation/Foundation.h>

@interface NSValue (CGPointAdditions)

#ifdef __MAC_OS_X_VERSION_MAX_ALLOWED
+ (NSValue *)valueWithCGPoint:(CGPoint)point;
- (CGPoint)CGPointValue;
#endif

@end
