#import <XCTest/XCTest.h>

#import "MXPhysics.h"

static const CGFloat kMXMaxVariation = 0.00001;

#pragma mark -
@interface MXFixtureTests : XCTestCase

@end

#pragma mark -
@implementation MXFixtureTests

- (void)testProperties {
    const CGFloat friction = 0.1234;
    const CGFloat restitution = 0.2345;
    const CGFloat density = 5.67;
    const u_int16_t collisionCategory = 0x0001;
    const u_int16_t collisionMask = 0x0101;
    const BOOL sensor = TRUE;
    NSString* const userData = @"My User Data";

    // Construct a fixture with a non-zero mass.
    MXFixture* fixture = [MXFixture fixtureWithBoxSize:CGSizeMake(1, 1) atLocation:CGPointZero];
    [fixture setFriction:friction];
    [fixture setRestitution:restitution];
    [fixture setDensity:density];
    [fixture setCollisionCategory:collisionCategory];
    [fixture setCollisionMask:collisionMask];
    [fixture setSensor:sensor];
    [fixture setUserData:userData];

    XCTAssertEqualWithAccuracy(fixture.friction, friction, kMXMaxVariation);
    XCTAssertEqualWithAccuracy(fixture.restitution, restitution, kMXMaxVariation);
    XCTAssertEqualWithAccuracy(fixture.density, density, kMXMaxVariation);
    XCTAssertEqual(fixture.collisionCategory, collisionCategory);
    XCTAssertEqual(fixture.collisionMask, collisionMask);
    XCTAssertEqual(fixture.sensor, sensor);
    XCTAssertEqual(fixture.userData, userData);

    // Connect the fixture to a body.
    MXBody* body = [MXBody bodyWithType:MXBodyTypeDynamic position:CGPointZero rotation:0];
    [body addFixture:fixture];

    XCTAssertEqualWithAccuracy(fixture.friction, friction, kMXMaxVariation);
    XCTAssertEqualWithAccuracy(fixture.restitution, restitution, kMXMaxVariation);
    XCTAssertEqualWithAccuracy(fixture.density, density, kMXMaxVariation);
    XCTAssertEqual(fixture.collisionCategory, collisionCategory);
    XCTAssertEqual(fixture.collisionMask, collisionMask);
    XCTAssertEqual(fixture.sensor, sensor);
    XCTAssertEqual(fixture.userData, userData);

    // Connect the body to a world.
    MXWorld* world = [MXWorld worldWithGravity:CGPointZero];
    [world addBody:body];

    XCTAssertEqualWithAccuracy(fixture.friction, friction, kMXMaxVariation);
    XCTAssertEqualWithAccuracy(fixture.restitution, restitution, kMXMaxVariation);
    XCTAssertEqualWithAccuracy(fixture.density, density, kMXMaxVariation);
    XCTAssertEqual(fixture.collisionCategory, collisionCategory);
    XCTAssertEqual(fixture.collisionMask, collisionMask);
    XCTAssertEqual(fixture.sensor, sensor);
    XCTAssertEqual(fixture.userData, userData);
}

- (void)testContainsPoint {
    // Test fixture before it is added to a world.
    MXFixture* fixture = [MXFixture fixtureWithBoxSize:CGSizeMake(10, 10) atLocation:CGPointZero];

    XCTAssertTrue([fixture testPoint:CGPointMake(-5, -5)]);
    XCTAssertTrue([fixture testPoint:CGPointMake(-1, -1)]);
    XCTAssertTrue([fixture testPoint:CGPointMake(0, 0)]);
    XCTAssertTrue([fixture testPoint:CGPointMake(1, 1)]);
    XCTAssertTrue([fixture testPoint:CGPointMake(5, 5)]);

    XCTAssertFalse([fixture testPoint:CGPointMake(-6, -5)]);
    XCTAssertFalse([fixture testPoint:CGPointMake(-1, -6)]);
    XCTAssertFalse([fixture testPoint:CGPointMake(0, 5.1)]);
    XCTAssertFalse([fixture testPoint:CGPointMake(-5.1, 1)]);
    XCTAssertFalse([fixture testPoint:CGPointMake(5, 5.1)]);

    // Test fixture after it is added to a world.
    MXBody* body = [MXBody bodyWithType:MXBodyTypeDynamic position:CGPointZero rotation:0];
    MXWorld* world = [MXWorld worldWithGravity:CGPointZero];
    [body addFixture:fixture];
    [world addBody:body];

    XCTAssertTrue([fixture testPoint:CGPointMake(-5, -5)]);
    XCTAssertTrue([fixture testPoint:CGPointMake(-1, -1)]);
    XCTAssertTrue([fixture testPoint:CGPointMake(0, 0)]);
    XCTAssertTrue([fixture testPoint:CGPointMake(1, 1)]);
    XCTAssertTrue([fixture testPoint:CGPointMake(5, 5)]);

    XCTAssertFalse([fixture testPoint:CGPointMake(-6, -5)]);
    XCTAssertFalse([fixture testPoint:CGPointMake(-1, -6)]);
    XCTAssertFalse([fixture testPoint:CGPointMake(0, 5.1)]);
    XCTAssertFalse([fixture testPoint:CGPointMake(-5.1, 1)]);
    XCTAssertFalse([fixture testPoint:CGPointMake(5, 5.1)]);
}

@end
