#import "MXWorld.h"
#import "MXRayCastIntersection.h"

#pragma mark -
@interface MXWorld (RayCasting)

/**
 Cast a ray against the world. This method is equivalent to calling
 -castRayFromStartPoint:toEndPoint:intersectionType: with MXRayIntersectionTypeAll as the intersectionType.

 @param startPoint The start of a finite portion of the ray.
 @param endPoint   The end of a finite portion of the ray.

 @return A set which contains MXRayCastIntersection objects. nil if no intersections occur.
 */
- (nonnull NSSet *)castRayFromStartPoint:(CGPoint)startPoint toEndPoint:(CGPoint)endPoint;

/**
 Cast a ray against the world.

 @param startPoint The start of a finite portion of the ray.
 @param endPoint   The end of a finite portion of the ray.

 @param intersectionType Determines how the ray cast method handles intersections. For example,
                         MXRayIntersectionTypeClosest will cause only the closest objects to be considered.

 @return A set which contains MXRayCastIntersection objects. nil if no intersections occur.
 */
- (nonnull NSSet *)castRayFromStartPoint:(CGPoint)startPoint toEndPoint:(CGPoint)endPoint
                        intersectionType:(MXRayIntersectionType)intersectionType;

@end
