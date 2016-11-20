#import <UIKit/UIKit.h>
#import <Box2D/Box2D.h>

#define MX_DEGREES_TO_RADIANS(__DEGREES__) ((__DEGREES__) * (M_PI / 180.0))
#define MX_RADIANS_TO_DEGREES(__RADIANS__) ((__RADIANS__) * (180.0 / M_PI))

/**
 Convert a Box2D vector measured in meters to a CGPoint measured in pnts.

 @param point The point to convert.

 @return A CGPoint, with values measured in pnts.
 */
extern CGPoint CGPointFromB2Vec2(const b2Vec2 point);

/**
 Convert a CGPoint measured in points to a Box2D vector measured in meters.

 @param point The point to convert.

 @return A b2Vec2 with values measured in meters.
 */
extern b2Vec2 B2Vec2FromCGPoint(const CGPoint point);

/**
 Used to convert between points and meters.
 */
extern const CGFloat kMXPointsPerMeter;
