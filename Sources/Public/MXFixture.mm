#import <UIKit/UIKit.h>

#import "MXFixture.h"
#import "MXFixture+Private.h"
#import "MXBox2DInternal.h"
#import "MXWorld.h"
#import "MXBody+Private.h"
#import "DLog.h"

const NSUInteger kMXMaxPolygonVertices = b2_maxPolygonVertices;
const NSUInteger kMXMinPolygonVertices = 3;

#pragma mark -
@interface MXFixture ()

@property (nonatomic, assign) b2FixtureDef *b2FixtureDef;

@property (nonatomic, assign, readwrite) b2Fixture *b2Fixture;
@property (nonatomic, weak, readwrite) MXBody *body;

- (instancetype)__initWithShape:(b2Shape *)shape;

- (void)__performFixtureOperation:(void (^)(b2Fixture *fixture))fixtureOperation
            orFixtureDefOperation:(void (^)(b2FixtureDef *fixtureDef))fixtureDefOperation;

@end

#pragma mark -
@implementation MXFixture

// Do not generate ivars for the following properties, as they rely on the underlying Box2d framework.
@dynamic friction, restitution, density, collisionCategory, collisionMask, sensor;

+ (instancetype)fixtureWithEdgeVertices:(NSArray *)vertices isClosedLoop:(BOOL)isClosedLoop {
    return [[self alloc] initWithEdgeVertices:vertices isClosedLoop:isClosedLoop];
}

+ (instancetype)fixtureWithPolygonVertices:(NSArray *)vertices {
    return [[self alloc] initWithPolygonVertices:vertices];
}

+ (instancetype)fixtureWithCircleRadius:(CGFloat)circleRadius {
    return [[self alloc] initWithCircleRadius:circleRadius atLocation:CGPointZero];
}

+ (instancetype)fixtureWithCircleRadius:(CGFloat)circleRadius atLocation:(CGPoint)location {
    return [[self alloc] initWithCircleRadius:circleRadius atLocation:location];
}

+ (instancetype)fixtureWithBoxSize:(CGSize)boxSize {
    return [[self alloc] initWithBoxSize:boxSize atLocation:CGPointZero angle:0];
}

+ (instancetype)fixtureWithBoxSize:(CGSize)boxSize atLocation:(CGPoint)location {
    return [[self alloc] initWithBoxSize:boxSize atLocation:location angle:0];
}

+ (instancetype)fixtureWithBoxSize:(CGSize)boxSize atLocation:(CGPoint)location angle:(CGFloat)angle {
    return [[self alloc] initWithBoxSize:boxSize atLocation:location angle:angle];
}

- (instancetype)initWithEdgeVertices:(NSArray *)vertices isClosedLoop:(BOOL)isClosedLoop {
    b2Vec2 cverts[kMXMaxPolygonVertices];
    
    // Convert vertices to world coordinates.
    for (NSUInteger i = 0; i < vertices.count; i++) {
        CGPoint point = [(NSValue *)[vertices objectAtIndex:i] CGPointValue];
        cverts[i] = B2Vec2FromCGPoint(point);
    }
    
    b2ChainShape *chainShape = new b2ChainShape();
    if (isClosedLoop) {
        chainShape->CreateLoop(cverts, (int32)vertices.count);
    } else {
        chainShape->CreateChain(cverts, (int32)vertices.count);
    }
    
    return [self __initWithShape:chainShape];
}

- (instancetype)initWithPolygonVertices:(NSArray *)vertices {
    NSAssert1(vertices.count <= kMXMaxPolygonVertices, @"Too many polygon vertices specified: %lu",
              (unsigned long)vertices.count);
    NSAssert1(vertices.count >= kMXMinPolygonVertices, @"Too few polygon vertices specified: %lu",
              (unsigned long)vertices.count);
    
    b2Vec2 cverts[kMXMaxPolygonVertices];
    
    // Convert vertices to world coordinates.
    for (NSUInteger i = 0; i < vertices.count; i++) {
        CGPoint point = [(NSValue *)[vertices objectAtIndex:i] CGPointValue];
        cverts[i] = B2Vec2FromCGPoint(point);
    }
    
    b2PolygonShape *polygonShape = new b2PolygonShape();
    polygonShape->Set(cverts, (int32)vertices.count);
    return [self __initWithShape:polygonShape];
}

- (instancetype)initWithCircleRadius:(CGFloat)circleRadius atLocation:(CGPoint)location {
    b2CircleShape *circleShape = new b2CircleShape();
	circleShape->m_radius = circleRadius / kMXPointsPerMeter;
	circleShape->m_p = B2Vec2FromCGPoint(location);
	return [self __initWithShape:circleShape];
}

- (instancetype)initWithBoxSize:(CGSize)boxSize atLocation:(CGPoint)location angle:(CGFloat)angle {
    b2PolygonShape *boxShape = new b2PolygonShape();
	boxShape->SetAsBox((boxSize.width * 0.5) / kMXPointsPerMeter, (boxSize.height * 0.5) / kMXPointsPerMeter,
                       B2Vec2FromCGPoint(location), MX_DEGREES_TO_RADIANS(angle));
	return [self __initWithShape:boxShape];
}

- (void)dealloc {
    NSParameterAssert(_b2FixtureDef);
    _b2FixtureDef->userData = NULL;

    delete _b2FixtureDef->shape;
    _b2FixtureDef->shape = NULL;

    delete _b2FixtureDef;
    _b2FixtureDef = NULL;
    
    // Destroy fixture.
    if (_b2Fixture) {
        _b2Fixture->GetBody()->DestroyFixture(_b2Fixture);
        _b2Fixture = NULL;
    }
}

- (CGFloat)friction {
    __block float32 b2Friction;
    
    [self __performFixtureOperation:^(b2Fixture *fixture) {
         b2Friction = fixture->GetFriction();
     } orFixtureDefOperation:^(b2FixtureDef *fixtureDef) {
         b2Friction = fixtureDef->friction;
     }];
    
    return b2Friction;
}

- (void)setFriction:(CGFloat)friction {
    [self __performFixtureOperation:^(b2Fixture *fixture) {
         fixture->SetFriction(friction);
     } orFixtureDefOperation:^(b2FixtureDef *fixtureDef) {
         fixtureDef->friction = friction;
     }];
}

- (CGFloat)restitution {
    __block float32 b2Restitution;
    
    [self __performFixtureOperation:^(b2Fixture *fixture) {
         b2Restitution = fixture->GetRestitution();
     } orFixtureDefOperation:^(b2FixtureDef *fixtureDef) {
         b2Restitution = fixtureDef->restitution;
     }];
    
    return b2Restitution;
}

- (void)setRestitution:(CGFloat)restitution {
    [self __performFixtureOperation:^(b2Fixture *fixture) {
         fixture->SetRestitution(restitution);
     } orFixtureDefOperation:^(b2FixtureDef *fixtureDef) {
         fixtureDef->restitution = restitution;
     }];
}

- (CGFloat)density {
    __block float32 b2Density;
    
    [self __performFixtureOperation:^(b2Fixture *fixture) {
         b2Density = fixture->GetDensity();
     } orFixtureDefOperation:^(b2FixtureDef *fixtureDef) {
         b2Density = fixtureDef->density;
     }];
    
    return b2Density / (kMXPointsPerMeter * kMXPointsPerMeter);
}

- (void)setDensity:(CGFloat)density {
    __block const float32 b2Density = density * (kMXPointsPerMeter * kMXPointsPerMeter);
    
    [self __performFixtureOperation:^(b2Fixture *fixture) {
         fixture->SetDensity(b2Density);
     } orFixtureDefOperation:^(b2FixtureDef *fixtureDef) {
         fixtureDef->density = b2Density;
     }];
}

- (u_int16_t)collisionCategory {
    __block u_int16_t collisionCategory = 0;
    
    [self __performFixtureOperation:^(b2Fixture *fixture) {
         collisionCategory = fixture->GetFilterData().categoryBits;
     } orFixtureDefOperation:^(b2FixtureDef *fixtureDef) {
         collisionCategory = fixtureDef->filter.categoryBits;
     }];
    
    return collisionCategory;
}

- (void)setCollisionCategory:(u_int16_t)collisionCategory {
    [self __performFixtureOperation:^(b2Fixture *fixture) {
         b2Filter filter = fixture->GetFilterData();
         filter.categoryBits = collisionCategory;
         fixture->SetFilterData(filter);
     } orFixtureDefOperation:^(b2FixtureDef *fixtureDef) {
         fixtureDef->filter.categoryBits = collisionCategory;
     }];
}

- (u_int16_t)collisionMask {
    __block u_int16_t collisionMask = 0;
    
    [self __performFixtureOperation:^(b2Fixture *fixture) {
         collisionMask = fixture->GetFilterData().maskBits;
     } orFixtureDefOperation:^(b2FixtureDef *fixtureDef) {
         collisionMask = fixtureDef->filter.maskBits;
     }];
    
    return collisionMask;
}

- (void)setCollisionMask:(u_int16_t)collisionMask {
    [self __performFixtureOperation:^(b2Fixture *fixture) {
         b2Filter filter = fixture->GetFilterData();
         filter.maskBits = collisionMask;
         fixture->SetFilterData(filter);
     } orFixtureDefOperation:^(b2FixtureDef *fixtureDef) {
         fixtureDef->filter.maskBits = collisionMask;
     }];
}

- (BOOL)isSensor {
    __block BOOL isSensor = FALSE;
    
    [self __performFixtureOperation:^(b2Fixture *fixture) {
         isSensor = fixture->IsSensor();
     } orFixtureDefOperation:^(b2FixtureDef *fixtureDef) {
         isSensor = fixtureDef->isSensor;
     }];
    
    return isSensor;
}

- (void)setSensor:(BOOL)sensor {
    [self __performFixtureOperation:^(b2Fixture *fixture) {
         fixture->SetSensor(sensor);
     } orFixtureDefOperation:^(b2FixtureDef *fixtureDef) {
         fixtureDef->isSensor = sensor;
     }];
}

- (BOOL)testPoint:(CGPoint)point {
    __block BOOL isContained = FALSE;
    __block const b2Vec2 b2Point = B2Vec2FromCGPoint(point);

    [self __performFixtureOperation:^(b2Fixture *fixture) {
         isContained = fixture->TestPoint(b2Point);
     } orFixtureDefOperation:^(b2FixtureDef *fixtureDef) {
         b2Transform identity = b2Transform(); identity.SetIdentity();
         isContained = fixtureDef->shape->TestPoint(identity, b2Point);
     }];
    
    return isContained;
}

- (void)removeFromParentBody {
    [self.body removeFixture:self];
}

#pragma mark - Private methods

- (instancetype)__initWithShape:(b2Shape *)shape {
    NSParameterAssert(shape);

    if (self = [super init]) {
        b2FixtureDef *fixtureDef = new b2FixtureDef();
        fixtureDef->shape = shape;
        fixtureDef->userData = (__bridge void *)self;
        _b2FixtureDef = fixtureDef;

        // This will be defined after the receiver is added to an MXBody.
        _b2Fixture = NULL;
    }

    return self;
}

- (void)__performFixtureOperation:(void (^)(b2Fixture *fixture))fixtureOperation
            orFixtureDefOperation:(void (^)(b2FixtureDef *fixtureDef))fixtureDefOperation
{
    NSParameterAssert(fixtureOperation);
    NSParameterAssert(fixtureDefOperation);
    
    if (self.b2Fixture) {
        fixtureOperation(self.b2Fixture);
    } else {
        fixtureDefOperation(self.b2FixtureDef);
    }
}

@end

#pragma mark -
@implementation MXFixture (Private)

@dynamic b2Fixture;

- (void)__assemble {
    if (self.b2Fixture || !self.body.isOperational) {
        return;
    }

    NSParameterAssert(self.b2FixtureDef);
    self.b2Fixture = self.body.b2Body->CreateFixture(self.b2FixtureDef);
}

- (void)__disassemble {
    b2Fixture *b2Fixture = self.b2Fixture;
    if (!b2Fixture) {
        return;
    }

    NSParameterAssert(self.b2FixtureDef);

    // Update the fixture definition with the fixture data.
    b2FixtureDef *fixtureDef = self.b2FixtureDef;
    fixtureDef->friction = b2Fixture->GetFriction();
    fixtureDef->restitution = b2Fixture->GetRestitution();
    fixtureDef->density = b2Fixture->GetDensity();
    fixtureDef->isSensor = b2Fixture->IsSensor();
    fixtureDef->filter.categoryBits = b2Fixture->GetFilterData().categoryBits;
    fixtureDef->filter.maskBits = b2Fixture->GetFilterData().maskBits;
    fixtureDef->userData = b2Fixture->GetUserData();

    // Destroy the old fixture.
    b2Fixture->GetBody()->DestroyFixture(b2Fixture);
    self.b2Fixture = NULL;
}

@end
