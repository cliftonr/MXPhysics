#import "MXRayCastCallback.h"
#import "MXRayCastIntersection+Private.h"

#pragma mark - Public

MXRayCastCallback::MXRayCastCallback() {
    Construct(MXRayIntersectionTypeAll);
};

MXRayCastCallback::MXRayCastCallback(const MXRayIntersectionType &type) {
    Construct(type);
};

float32 MXRayCastCallback::ReportFixture(b2Fixture *fixture,
                                         const b2Vec2 &point,
                                         const b2Vec2 &normal,
                                         float32 fraction)
{
    [_results addObject:[MXRayCastIntersection intersectionWithB2Fixture:fixture
                                                         intersectionPoint:&point
                                                              normalVector:&normal
                                                                  fraction:&fraction]];

    switch (_intersectionType) {
        case MXRayIntersectionTypeFarthest:
        case MXRayIntersectionTypeAll:
            return 1;

        case MXRayIntersectionTypeClosest:
            return fraction;

        case MXRayIntersectionTypeAny:
            return 0;
    }
}

NSSet *MXRayCastCallback::GetResults() {
    if (_results.count == 0) {
        return [NSSet set];
    }

    switch (_intersectionType) {
        case MXRayIntersectionTypeAny:
        case MXRayIntersectionTypeAll:
            return [NSSet setWithArray:_results];

        case MXRayIntersectionTypeClosest:
            // The closest object is the last object in the array.
            return [NSSet setWithObject:[_results lastObject]];

        case MXRayIntersectionTypeFarthest: {
            // The farthest intersection is that with the greatest fraction.
            MXRayCastIntersection *farthestIntersection = nil;
            for (MXRayCastIntersection *intersection in _results) {
                // Update farthestIntersection if it's nil or if its fraction is less than intersection's.
                if (!farthestIntersection || (intersection.fraction > farthestIntersection.fraction)) {
                    farthestIntersection = intersection;
                }
            }

            return [NSSet setWithObject:farthestIntersection];
        }
    }
}

#pragma mark - Private

void MXRayCastCallback::Construct(const MXRayIntersectionType &type) {
    _intersectionType = type;
    _results = [NSMutableArray array];
}
