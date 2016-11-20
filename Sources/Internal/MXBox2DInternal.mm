#import "MXBox2DInternal.h"
#import "MXWorld.h"

// Used to convert between points and meters.
const CGFloat kMXPointsPerMeter = 32;

CGPoint CGPointFromB2Vec2(const b2Vec2 point) {
    return CGPointMake((float32)(point.x * kMXPointsPerMeter), (float32)(point.y * kMXPointsPerMeter));
}

b2Vec2 B2Vec2FromCGPoint(const CGPoint point) {
    return b2Vec2((float32)(point.x / kMXPointsPerMeter), (float32)(point.y / kMXPointsPerMeter));
}
