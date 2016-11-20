#import "MXRayCastIntersection.h"
#import "MXBox2DInternal.h"

#pragma mark -
/**
 Private interface for MXRayCastHit, implemented in MXRayCastIntersection.mm.
 */
@interface MXRayCastIntersection (Private)

/**
 Designated (private) initializer.

 @param b2Fixture         The fixture that was hit by the ray.
 @param intersectionPoint The initial point of intersection.
 @param normalVector      Normal vector to the edge at the point of intersection.
 @param fraction          A value between [0, 1] representing a fraction of the distance at the intersection
                          between the ray's start and end points.
 */
+ (instancetype)intersectionWithB2Fixture:(b2Fixture *)b2Fixture
                        intersectionPoint:(const b2Vec2 *)intersectionPoint
                             normalVector:(const b2Vec2 *)normalVector
                                 fraction:(const float32 *)fraction;

@end
