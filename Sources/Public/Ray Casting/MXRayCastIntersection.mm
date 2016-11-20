#import "MXRayCastIntersection.h"
#import "MXRayCastIntersection+Private.h"
#import "MXBox2DInternal.h"

#pragma mark -
@interface MXRayCastIntersection ()

@property (nonatomic, weak, readwrite) MXFixture *fixture;
@property (nonatomic, assign, readwrite) CGPoint intersectionPoint;
@property (nonatomic, assign, readwrite) CGPoint normalVector;
@property (nonatomic, assign, readwrite) CGFloat fraction;

@end

#pragma mark -
@implementation MXRayCastIntersection

+ (instancetype)intersectionWithB2Fixture:(b2Fixture *)b2Fixture
                        intersectionPoint:(const b2Vec2 *)intersectionPoint
                             normalVector:(const b2Vec2 *)normalVector
                                 fraction:(const float32 *)fraction
{
    return [[self alloc] initWithB2Fixture:b2Fixture intersectionPoint:intersectionPoint normalVector:normalVector fraction:fraction];
}

- (instancetype)initWithB2Fixture:(b2Fixture *)b2Fixture
                intersectionPoint:(const b2Vec2 *)intersectionPoint
                     normalVector:(const b2Vec2 *)normalVector
                         fraction:(const float32 *)fraction
{
    NSParameterAssert(b2Fixture);

    if (self = [super init]) {
        _fixture = (__bridge id)b2Fixture->GetUserData();
        NSAssert(_fixture, @"No fixture information!");
        
        _intersectionPoint = CGPointFromB2Vec2(*intersectionPoint);
        _normalVector = CGPointFromB2Vec2(*normalVector);
        _fraction = *fraction;
    }
    
    return self;
}

@end
