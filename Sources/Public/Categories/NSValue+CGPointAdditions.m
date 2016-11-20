#import "NSValue+CGPointAdditions.h"

@implementation NSValue (CGPointAdditions)

#ifdef __MAC_OS_X_VERSION_MAX_ALLOWED
+ (NSValue *)valueWithCGPoint:(CGPoint)point {
    return [NSValue valueWithPoint:NSPointFromCGPoint(point)];
}

- (CGPoint)CGPointValue {
    return NSPointToCGPoint([self pointValue]);
}
#endif

@end
