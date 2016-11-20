#import <XCTest/XCTest.h>

#import "MXPhysics.h"

static const CGFloat kMXMaxVariation = 0.00001;

static NSString * const kKillPhrase = @"Destroy Me!";

#pragma mark -
@interface MXFixtureDestroyer : NSObject <MXContactListenerDelegate>

@property (nonatomic, assign) BOOL hitDetected;

@end

#pragma mark -
@implementation MXFixtureDestroyer

- (void)contactBegan:(MXContact *)contact {
    if (contact.isTouching) {
        NSArray *fixtures = @[contact.fixtureA, contact.fixtureB];
        
        // Remove the fixture if it contains the kill-phrase.
        for (MXFixture *fixture in fixtures) {
            if ([fixture.userData isEqualToString:kKillPhrase]) {
                [fixture.body removeFixture:fixture];
            }
        }
        
        self.hitDetected = TRUE;
    }
}

@end

#pragma mark -
@interface MXBodyTests : XCTestCase

@end

#pragma mark -
@implementation MXBodyTests

- (void)testProperties {
    const MXBodyType type = MXBodyTypeKinematic;
    const CGPoint position = CGPointMake(1.23f, 6.78);
    const CGFloat rotation = 5.67;
    const CGPoint linearVelocity = CGPointMake(3.45, 7.89);
    const CGFloat angularVelocity = 5.67;
    const CGFloat linearDamping = 2.34;
    const CGFloat angularDamping = 8.91;
    const CGFloat gravityScale = 1.0;
    const BOOL allowSleep = TRUE;
    const BOOL awake = FALSE;
    const BOOL active = FALSE;
    const BOOL fixedRotation = TRUE;
    const BOOL bullet = FALSE;
    NSString * const userData = @"My User Data";

    // Construct a body.
    MXBody *body = [MXBody bodyWithType:MXBodyTypeDynamic position:CGPointZero rotation:0];
    [body setType:type];
    [body setPosition:position];
    [body setRotation:rotation];
    [body setLinearVelocity:linearVelocity];
    [body setAngularVelocity:angularVelocity];
    [body setLinearDamping:linearDamping];
    [body setAngularDamping:angularDamping];
    [body setGravityScale:gravityScale];
    [body setAllowSleep:allowSleep];
    [body setAwake:awake];
    [body setActive:active];
    [body setFixedRotation:fixedRotation];
    [body setBullet:bullet];
    [body setUserData:userData];

    XCTAssertEqualWithAccuracy(body.position.x, position.x, kMXMaxVariation);
    XCTAssertEqualWithAccuracy(body.position.y, position.y, kMXMaxVariation);
    XCTAssertEqualWithAccuracy(body.rotation, rotation, kMXMaxVariation);
    XCTAssertEqualWithAccuracy(body.linearVelocity.x, linearVelocity.x, kMXMaxVariation);
    XCTAssertEqualWithAccuracy(body.linearVelocity.y, linearVelocity.y, kMXMaxVariation);
    XCTAssertEqualWithAccuracy(body.angularVelocity, angularVelocity, kMXMaxVariation);
    XCTAssertEqualWithAccuracy(body.linearDamping, linearDamping, kMXMaxVariation);
    XCTAssertEqualWithAccuracy(body.angularDamping, angularDamping, kMXMaxVariation);
    XCTAssertEqualWithAccuracy(body.gravityScale, gravityScale, kMXMaxVariation);
    XCTAssertEqual(body.type, type);
    XCTAssertEqual(body.allowSleep, allowSleep);
    XCTAssertEqual(body.awake, awake);
    XCTAssertEqual(body.active, active);
    XCTAssertEqual(body.fixedRotation, fixedRotation);
    XCTAssertEqual(body.bullet, bullet);
    XCTAssertEqual(body.userData, userData);

    // Add body to world.
    MXWorld *world = [MXWorld worldWithGravity:CGPointZero];
    [world addBody:body];

    XCTAssertEqualWithAccuracy(body.position.x, position.x, kMXMaxVariation);
    XCTAssertEqualWithAccuracy(body.position.y, position.y, kMXMaxVariation);
    XCTAssertEqualWithAccuracy(body.rotation, rotation, kMXMaxVariation);
    XCTAssertEqualWithAccuracy(body.linearVelocity.x, linearVelocity.x, kMXMaxVariation);
    XCTAssertEqualWithAccuracy(body.linearVelocity.y, linearVelocity.y, kMXMaxVariation);
    XCTAssertEqualWithAccuracy(body.angularVelocity, angularVelocity, kMXMaxVariation);
    XCTAssertEqualWithAccuracy(body.linearDamping, linearDamping, kMXMaxVariation);
    XCTAssertEqualWithAccuracy(body.angularDamping, angularDamping, kMXMaxVariation);
    XCTAssertEqualWithAccuracy(body.gravityScale, gravityScale, kMXMaxVariation);
    XCTAssertEqual(body.type, type);
    XCTAssertEqual(body.allowSleep, allowSleep);
    XCTAssertEqual(body.awake, awake);
    XCTAssertEqual(body.active, active);
    XCTAssertEqual(body.fixedRotation, fixedRotation);
    XCTAssertEqual(body.bullet, bullet);
    XCTAssertEqual(body.userData, userData);
}

- (void)testAddAndRemoveFixture {
    // Construct a body.
    MXBody *body = [MXBody bodyWithType:MXBodyTypeDynamic position:CGPointZero rotation:0];
    XCTAssertEqual(body.fixtures.count, 0);

    // Construct a fixture.
    MXFixture *fixture = [MXFixture fixtureWithBoxSize:CGSizeMake(1, 1) atLocation:CGPointZero];
    XCTAssertNil(fixture.body);

    // Add fixture to body.
    [body addFixture:fixture];
    XCTAssertEqualObjects(fixture.body, body);
    XCTAssertEqual(body.fixtures.count, 1);
    XCTAssertEqualObjects([body.fixtures anyObject], fixture);

    // Add body to world.
    MXWorld *world = [MXWorld worldWithGravity:CGPointZero];
    [world addBody:body];

    // Remove the fixture.
    [body removeFixture:fixture];
    XCTAssertEqual(body.fixtures.count, 0);
    XCTAssertNil(fixture.body);
}

- (void)testAddAndRemoveMultipleFixtures {
    // Construct a body.
    MXBody *body = [MXBody bodyWithType:MXBodyTypeDynamic position:CGPointZero rotation:0];
    XCTAssertEqual(body.fixtures.count, 0);

    // Add multiple fixtures to the body.
    for (int i = 0; i < 32; i++) {
        // Construct a fixture.
        MXFixture *fixture = [MXFixture fixtureWithBoxSize:CGSizeMake(1, 1) atLocation:CGPointZero];
        XCTAssertNil(fixture.body);

        // Add fixture to body.
        [body addFixture:fixture];
        XCTAssertEqualObjects(fixture.body, body);
        XCTAssertEqual(body.fixtures.count, i + 1);
        XCTAssertTrue([body.fixtures containsObject:fixture]);
    }

    // Hold onto the fixtures for a later test.
    NSSet *fixtures = body.fixtures;

    // Add body to world.
    MXWorld *world = [MXWorld worldWithGravity:CGPointZero];
    [world addBody:body];

    // Remove all fixtures.
    [body removeAllFixtures];
    XCTAssertEqual(body.fixtures.count, 0);

    // Make sure the body references are nil.
    for (MXFixture *fixture in fixtures) {
        XCTAssertNil(fixture.body);
    }
}

- (void)testMoveFixtureBetweenBodies {
    // Construct world and first body.
    MXWorld *world = [MXWorld worldWithGravity:CGPointZero];
    MXBody *body1 = [MXBody bodyWithType:MXBodyTypeDynamic position:CGPointZero rotation:0];
    [world addBody:body1];

    // Construct a fixture.
    MXFixture *fixture = [MXFixture fixtureWithBoxSize:CGSizeMake(1, 1) atLocation:CGPointZero];

    // Add fixture to first body.
    [body1 addFixture:fixture];
    XCTAssertEqualObjects(fixture.body, body1);
    XCTAssertEqual(body1.fixtures.count, 1);
    XCTAssertEqualObjects([body1.fixtures anyObject], fixture);

    // Construct a second body and move fixture over to it.
    MXBody *body2 = [MXBody bodyWithType:MXBodyTypeDynamic position:CGPointZero rotation:0];
    [body2 addFixture:fixture];
    [world addBody:body1];

    // Fixture should now belong to second body.
    XCTAssertEqualObjects(fixture.body, body2);
    XCTAssertEqual(body2.fixtures.count, 1);
    XCTAssertEqualObjects([body2.fixtures anyObject], fixture);

    // First body should not maintain ownership of fixture.
    XCTAssertEqual(body1.fixtures.count, 0);
    XCTAssertNil([body1.fixtures anyObject]);
}

- (void)testRemoveFixturesInsideTimeStep {
    // Construct a world.
    MXWorld *world = [MXWorld worldWithGravity:CGPointZero];
    MXFixtureDestroyer *delegate = [[MXFixtureDestroyer alloc] init];
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

    XCTAssertEqualObjects(fixture1.body, body1);
    XCTAssertEqualObjects(fixture2.body, body2);

    // Set the kill phrase on fixture1. This will direct our delegate tester to destroy fixture1.
    fixture1.userData = kKillPhrase;

    // Update the world.
    [world updateWithTimeStep:1 velocityIterations:5 positionIterations:5];

    XCTAssertTrue(delegate.hitDetected);
    XCTAssertNil(fixture1.body);
    XCTAssertEqualObjects(fixture2.body, body2);
}

@end
