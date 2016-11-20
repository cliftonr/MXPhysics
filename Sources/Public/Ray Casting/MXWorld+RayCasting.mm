#import "MXWorld+RayCasting.h"
#import "MXWorld+Private.h"
#import "MXRayCastCallback.h"

#pragma mark -
@implementation MXWorld (RayCasting)

- (NSSet *)castRayFromStartPoint:(CGPoint)startPoint toEndPoint:(CGPoint)endPoint {
    return [self castRayFromStartPoint:startPoint toEndPoint:endPoint
                      intersectionType:MXRayIntersectionTypeAll];
}

- (NSSet *)castRayFromStartPoint:(CGPoint)startPoint toEndPoint:(CGPoint)endPoint
                intersectionType:(MXRayIntersectionType)intersectionType
{
    MXRayCastCallback callback = MXRayCastCallback(intersectionType);
    self.b2World->RayCast(&callback, B2Vec2FromCGPoint(startPoint), B2Vec2FromCGPoint(endPoint));
    return callback.GetResults();
}

@end
