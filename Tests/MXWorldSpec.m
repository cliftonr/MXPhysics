#import <XCTest/XCTest.h>

#import "MXPhysics.h"

static const CGFloat kMXMaxVariation = 0.00001;

static NSString * const kKillPhrase = @"Destroy Me!";

#pragma mark -
@interface MXContactListenerDelegateTester : NSObject <MXContactListenerDelegate>

@property (nonatomic, strong, readonly) id fixtureA;
@property (nonatomic, strong, readonly) id fixtureB;
@property (nonatomic, assign, readonly) BOOL didReceivePreSolve;

@end

#pragma mark -
@implementation MXContactListenerDelegateTester

- (instancetype)init {
    if (self = [super init]) {
        _didReceivePreSolve = FALSE;
    }

    return self;
}

- (void)contactBegan:(MXContact *)contact {
    _fixtureA = contact.fixtureA;
    _fixtureB = contact.fixtureB;
}

- (void)contactEnded:(MXContact *)contact {
    _fixtureA = nil;
    _fixtureB = nil;
}

- (void)contactPreSolve:(MXContact *)contact {
    _didReceivePreSolve = TRUE;
}

@end

#pragma mark -
@interface MXBodyDestroyer : NSObject <MXContactListenerDelegate>

@property (nonatomic, assign) BOOL hitDetected;

@end

#pragma mark -
@implementation MXBodyDestroyer

- (void)contactBegan:(MXContact *)contact {
    if (contact.isTouching) {
        NSArray *bodies = @[contact.fixtureA.body, contact.fixtureB.body];

        // Remove the body if it contains the kill-phrase.
        for (MXBody *body in bodies) {
            if ([body.userData isEqualToString:kKillPhrase]) {
                [body.world removeBody:body];
            }
        }

        self.hitDetected = TRUE;
    }
}

@end

#pragma mark -
@interface MXWorldTests : XCTestCase

@end

#pragma mark -
@implementation MXWorldTests

- (void)testProperties {
    const CGPoint gravity = CGPointMake(1.23f, 6.78);
    const BOOL allowSleep = TRUE;
    const id delegate = [[NSObject alloc] init];

    // Construct a world.
    MXWorld *world = [MXWorld worldWithGravity:gravity];
    [world setAllowSleep:allowSleep];
    [world setDelegate:delegate];

    XCTAssertEqualWithAccuracy(world.gravity.x, gravity.x, kMXMaxVariation);
    XCTAssertEqualWithAccuracy(world.gravity.y, gravity.y, kMXMaxVariation);
    XCTAssertEqual(world.isSleepingAllowed, allowSleep);
    XCTAssertEqualObjects(world.delegate, delegate);
}

- (void)testAddAndRemoveBodies {
    // Construct a world.
    MXWorld *world = [MXWorld worldWithGravity:CGPointZero];
    XCTAssertEqual(world.bodies.count, 0);

    // Construct a body.
    MXBody *body = [MXBody bodyWithType:MXBodyTypeDynamic position:CGPointZero rotation:0];
    XCTAssertNil(body.world);

    // Add body to world.
    [world addBody:body];
    XCTAssertEqualObjects(body.world, world);
    XCTAssertEqual(world.bodies.count, 1);
    XCTAssertEqualObjects([world.bodies anyObject], body);

    // Remove the body.
    [world removeBody:body];
    XCTAssertEqual(world.bodies.count, 0);
    XCTAssertNil(body.world);
}

- (void)testAddAndRemoveMultipleBodies {
    // Construct a world.
    MXWorld *world = [MXWorld worldWithGravity:CGPointZero];
    XCTAssertEqual(world.bodies.count, 0);

    // Add multiple bodies to the world.
    for (int i = 0; i < 32; i++) {
        // Construct a body.
        MXBody *body = [MXBody bodyWithType:MXBodyTypeDynamic position:CGPointZero rotation:0];
        XCTAssertNil(body.world);

        // Add body to world.
        [world addBody:body];
        XCTAssertEqualObjects(body.world, world);
        XCTAssertEqual(world.bodies.count, i + 1);
        XCTAssertTrue([world.bodies containsObject:body]);
    }

    // Hold onto the bodies for a later test.
    NSSet *bodies = world.bodies;

    // Remove all bodies.
    [world removeAllBodies];
    XCTAssertEqual(world.bodies.count, 0);

    // Make sure the world references are nil.
    for (MXBody *body in bodies) {
        XCTAssertNil(body.world);
    }
}

- (void)testMoveBodyBetweenWorlds {
    // Construct a world.
    MXWorld* world1 = [MXWorld worldWithGravity:CGPointZero];

    // Construct a body.
    MXBody* body = [MXBody bodyWithType:MXBodyTypeDynamic position:CGPointZero rotation:0];
    XCTAssertNil(body.world);

    // Add body to first world.
    [world1 addBody:body];
    XCTAssertEqualObjects(body.world, world1);
    XCTAssertEqual(world1.bodies.count, 1);
    XCTAssertEqualObjects([world1.bodies anyObject], body);

    // Construct a second world.
    MXWorld* world2 = [MXWorld worldWithGravity:CGPointZero];

    // Body should now belong to second world.
    [world2 addBody:body];
    XCTAssertEqualObjects(body.world, world2);
    XCTAssertEqual(world2.bodies.count, 1);
    XCTAssertEqualObjects([world2.bodies anyObject], body);

    // First world should not maintain ownership of body.
    XCTAssertEqual(world1.bodies.count, 0);
    XCTAssertNil([world1.bodies anyObject]);
}

- (void)testDetectOverlappingFixtures {
    // Construct a world.
    MXWorld* world = [MXWorld worldWithGravity:CGPointZero];
    MXContactListenerDelegateTester* delegate = [[MXContactListenerDelegateTester alloc] init];
    world.delegate = delegate;

    XCTAssertNil(delegate.fixtureA);
    XCTAssertNil(delegate.fixtureB);
    XCTAssertFalse(delegate.didReceivePreSolve);

    // Add a couple of overlapping bodies and fixtures.
    MXBody* body1 = [MXBody bodyWithType:MXBodyTypeDynamic position:CGPointMake(10, 10) rotation:0];
    MXFixture* fixture1 = [MXFixture fixtureWithBoxSize:CGSizeMake(10, 10) atLocation:CGPointZero];
    [body1 addFixture:fixture1];

    MXBody* body2 = [MXBody bodyWithType:MXBodyTypeDynamic position:CGPointMake(15, 15) rotation:0];
    MXFixture* fixture2 = [MXFixture fixtureWithBoxSize:CGSizeMake(10, 10) atLocation:CGPointZero];
    [body2 addFixture:fixture2];

    [world addBody:body1];
    [world addBody:body2];

    // Update the world.
    [world updateWithTimeStep:1 velocityIterations:5 positionIterations:5];

    XCTAssertNotNil(delegate.fixtureA);
    XCTAssertNotNil(delegate.fixtureB);
    XCTAssertNotEqualObjects(delegate.fixtureA, delegate.fixtureB);
    XCTAssertTrue(delegate.didReceivePreSolve);

    // Reposition body2 such that neither object overlaps the other.
    [body2 setPosition:CGPointMake(100, 100)];

    // Update the world.
    [world updateWithTimeStep:1 velocityIterations:5 positionIterations:5];

    XCTAssertNil(delegate.fixtureA);
    XCTAssertNil(delegate.fixtureB);
}

- (void)testRemoveBodiesInsideTimeStep {
    // Construct a world.
    MXWorld *world = [MXWorld worldWithGravity:CGPointZero];
    MXBodyDestroyer *delegate = [[MXBodyDestroyer alloc] init];
    world.delegate = delegate;

    XCTAssertFalse(delegate.hitDetected);

    // Add a couple of bodies with fixtures to the world.
    MXBody *body1 = [MXBody bodyWithType:MXBodyTypeDynamic position:CGPointMake(10, 10) rotation:0];
    MXFixture *fixture1 = [MXFixture fixtureWithBoxSize:CGSizeMake(10, 10) atLocation:CGPointZero];
    [body1 addFixture:fixture1];

    MXBody *body2 = [MXBody bodyWithType:MXBodyTypeDynamic position:CGPointMake(15, 15) rotation:0];
    MXFixture *fixture2 = [MXFixture fixtureWithBoxSize:CGSizeMake(10, 10) atLocation:CGPointZero];
    [body2 addFixture:fixture2];

    [world addBody:body1];
    [world addBody:body2];

    XCTAssertEqualObjects(body1.world, world);
    XCTAssertEqualObjects(body2.world, world);

    // Set the kill phrase on body2. This will direct our delegate tester to destroy body2.
    body2.userData = kKillPhrase;

    // Update the world.
    [world updateWithTimeStep:1 velocityIterations:5 positionIterations:5];

    XCTAssertTrue(delegate.hitDetected);
    XCTAssertEqualObjects(body1.world, world);
    XCTAssertNil(body2.world);
}

- (void)testAddBodiesInsideTimeStep {
    // TODO: This is not yet possible.
}

- (void)testRaycastIntersections {
    // Construct a world.
    MXWorld *world = [MXWorld worldWithGravity:CGPointZero];

    // Add a couple of bodies with fixtures to the world.
    MXBody *body1 = [MXBody bodyWithType:MXBodyTypeDynamic position:CGPointMake(10, 10) rotation:0];
    MXFixture *fixture1 = [MXFixture fixtureWithBoxSize:CGSizeMake(10, 10)];
    [body1 addFixture:fixture1];

    MXBody *body2 = [MXBody bodyWithType:MXBodyTypeDynamic position:CGPointMake(200, 200) rotation:0];
    MXFixture *fixture2 = [MXFixture fixtureWithBoxSize:CGSizeMake(10, 10)];
    [body2 addFixture:fixture2];

    [world addBody:body1];
    [world addBody:body2];

    // Cast a ray such that neither object is touched.
    NSSet *intersections = [world castRayFromStartPoint:CGPointMake(50, 50)
                                             toEndPoint:CGPointMake(75, 75)];
    XCTAssertEqual(intersections.count, 0);

    // Cast a ray that will only touch one of the objects.
    NSSet *intersections2 = [world castRayFromStartPoint:CGPointMake(-20, -20)
                                              toEndPoint:CGPointMake(20, 20)];
    XCTAssertEqual(intersections2.count, 1);

    // Cast a ray that will touch both of the objects.
    NSSet *intersections3 = [world castRayFromStartPoint:CGPointMake(-1, -1)
                                              toEndPoint:CGPointMake(300, 300)];
    XCTAssertEqual(intersections3.count, 2);
}

@end
