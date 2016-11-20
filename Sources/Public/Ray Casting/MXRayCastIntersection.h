#import <QuartzCore/QuartzCore.h>

@class MXFixture;

/**
 Specifies the result expected from a raycast operation.

 - MXRayIntersectionTypeAny:      Find any object hit by the ray. (fastest)
 - MXRayIntersectionTypeAll:      Find all objects hit by the ray. (slowest)
 - MXRayIntersectionTypeClosest:  Find the closest object hit by the ray.
 - MXRayIntersectionTypeFarthest: Find the farthest object hit by the ray.
 */
typedef NS_ENUM(NSUInteger, MXRayIntersectionType) {
    MXRayIntersectionTypeAny,
    MXRayIntersectionTypeAll,
    MXRayIntersectionTypeClosest,
    MXRayIntersectionTypeFarthest
};

#pragma mark -
/**
 Describes the intersection of a ray and a single fixture.
 */
@interface MXRayCastIntersection : NSObject

/**
 The fixture that was hit by the ray.
 */
@property (nonatomic, weak, readonly) MXFixture *fixture;

/**
 The initial point of intersection.
 */
@property (nonatomic, assign, readonly) CGPoint intersectionPoint;

/**
 Normal vector at the point of intersection.
 */
@property (nonatomic, assign, readonly) CGPoint normalVector;

/**
 A value between [0, 1] representing a fraction of the distance at the intersection between the ray's start
 and end points.
 */
@property (nonatomic, assign, readonly) CGFloat fraction;

@end
