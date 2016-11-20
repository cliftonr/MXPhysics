#import "MXBox2DInternal.h"
#import "MXRayCastIntersection.h"

#pragma mark -
class MXRayCastCallback : public b2RayCastCallback {
public:
    MXRayCastCallback();
    MXRayCastCallback(const MXRayIntersectionType &type);

    float32 ReportFixture(b2Fixture *fixture, const b2Vec2 &point, const b2Vec2 &normal, float32 fraction);

    /**
     Return the results that were gathered during the ray-cast.

     @return A set containing the resulting intersections.
     */
    NSSet *GetResults();

private:
    MXRayIntersectionType _intersectionType;
    NSMutableArray *_results;

    void Construct(const MXRayIntersectionType &type);
};
