/// The maximum number of vertices allowed for a polygon-shaped fixture.
extern const NSUInteger kMXMaxPolygonVertices;

/// The minimum number of vertices allowed for a polygon-shaped fixture.
extern const NSUInteger kMXMinPolygonVertices;

@class MXBody;

#pragma mark -
/**
 An ObjC wrapper for a b2Fixture. Length is measured in points, unlike Box2D, which uses meters. Angles are in
 degrees, unlike Box2D, which uses radians. Mass is measured in kilograms, like Box2D.
 */
@interface MXFixture : NSObject

/**
 Friction, in range [0,1].
 */
@property (nonatomic, assign) CGFloat friction;

/**
 Restitution in range [0,1].
 */
@property (nonatomic, assign) CGFloat restitution;

/**
 Density, in kg/point^2.
 */
@property (nonatomic, assign) CGFloat density;

/**
 Collision category, used for collision filtering. This value is typically a single binary bit.
 */
@property (nonatomic, assign) u_int16_t collisionCategory;

/**
 A mask consisting of all the collision categories with which this fixture can collide.
 */
@property (nonatomic, assign) u_int16_t collisionMask;

/**
 Sensors record contact with other fixtures, but cannot collide.
 */
@property (nonatomic, assign, getter = isSensor) BOOL sensor;

/**
 The body to which this fixture is attached.
 */
@property (nonatomic, weak, readonly, nullable) MXBody *body;

/**
 Used by client for anything.
 */
@property (nonatomic, weak, nullable) id userData;

/**
 Initializes a fixture with a hollow edge chain shape.

 @param vertices     The vertices that specify an edge shape.
 @param isClosedLoop If true, a closed loop is created.
 */
+ (nonnull instancetype)fixtureWithEdgeVertices:(nonnull NSArray<NSValue *> *)vertices
                                   isClosedLoop:(BOOL)isClosedLoop;

/**
 Initializes a fixture with a filled polygon shape.
 
 @warning The number of vertices specified must be no greater than kMXMaxPolygonVertices.

 @param vertices The vertices that specify a convex polygon.
 */
+ (nonnull instancetype)fixtureWithPolygonVertices:(nonnull NSArray<NSValue *> *)vertices;

/**
 Initializes a fixture with a circle shape, located at the body's origin.

 @param circleRadius The radius of the circle shape in points.
 */
+ (nonnull instancetype)fixtureWithCircleRadius:(CGFloat)circleRadius;

/**
 Initializes a fixture with a circle shape.

 @param circleRadius The radius of the circle shape in points.
 @param location     Location of the shape, relative to the body.
 */
+ (nonnull instancetype)fixtureWithCircleRadius:(CGFloat)circleRadius atLocation:(CGPoint)location;

/**
 Initializes a fixture with a box shape.

 @param boxSize The size of the box shape in points.
 */
+ (nonnull instancetype)fixtureWithBoxSize:(CGSize)boxSize;

/**
 Initializes a fixture with a box shape.

 @param boxSize  The size of the box shape in points.
 @param location Location of the shape, relative to the body.
 */
+ (nonnull instancetype)fixtureWithBoxSize:(CGSize)boxSize atLocation:(CGPoint)location;

/**
 Initializes a fixture with an oriented box shape.

 @param boxSize  The size of the box shape in points.
 @param location Location of the shape, relative to the body.
 @param angle    Orientation of the box shape, relative to the body, in degrees.
 */
+ (nonnull instancetype)fixtureWithBoxSize:(CGSize)boxSize atLocation:(CGPoint)location angle:(CGFloat)angle;

/**
 Test whether a point is contained within the fixture.

 @param point A point in world coordinates.
 */
- (BOOL)testPoint:(CGPoint)point;

/**
 Removes this fixture from its parent body if it has one.
 */
- (void)removeFromParentBody;

@end
