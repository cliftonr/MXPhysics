#import <XCTest/XCTest.h>

#import "MXPhysics.h"

#pragma mark -
@interface MXJointTests : XCTestCase

@end

#pragma mark -
@implementation MXJointTests

- (void)testProperties {
    MXBody* bodyA = [MXBody bodyWithType:MXBodyTypeDynamic position:CGPointZero rotation:0];
    MXBody* bodyB = [MXBody bodyWithType:MXBodyTypeDynamic position:CGPointZero rotation:0];
    NSString* const userData = @"My User Data";

    // Construct a joint.
    MXJoint* joint = [bodyA constrainToBody:bodyB withJointType:MXJointTypeDistance];
    [joint setUserData:userData];

    XCTAssertFalse(joint.isOperational);
    XCTAssertEqualObjects(joint.bodyA, bodyA);
    XCTAssertEqualObjects(joint.bodyB, bodyB);
    XCTAssertEqualObjects(joint.userData, userData);

    // Connect the joint to a world by adding its bodies to a world.
    MXWorld* world = [MXWorld worldWithGravity:CGPointZero];
    [world addBody:bodyA];
    [world addBody:bodyB];

    XCTAssertTrue(joint.isOperational);
    XCTAssertEqualObjects(joint.bodyA, bodyA);
    XCTAssertEqualObjects(joint.bodyB, bodyB);
    XCTAssertEqualObjects(joint.userData, userData);

    world = nil;
}

- (void)testOperationalAfterAddingBodiesToWorld {
    MXBody* bodyA = [MXBody bodyWithType:MXBodyTypeDynamic position:CGPointZero rotation:0];
    MXBody* bodyB = [MXBody bodyWithType:MXBodyTypeDynamic position:CGPointZero rotation:0];

    // Construct a joint.
    MXJoint* joint = [bodyA constrainToBody:bodyB withJointType:MXJointTypeDistance];
    XCTAssertFalse(joint.isOperational);

    // Connect the joint to a world by adding its bodies to a world.
    MXWorld* world = [MXWorld worldWithGravity:CGPointZero];

    // Adding only one of the bodies should not cause the joint to be operational.
    [world addBody:bodyA];
    XCTAssertFalse(joint.isOperational);
    [world removeBody:bodyA];
    XCTAssertFalse(joint.isOperational);

    [world addBody:bodyB];
    XCTAssertFalse(joint.isOperational);
    [world removeBody:bodyB];
    XCTAssertFalse(joint.isOperational);

    // Only after adding both bodies should the joint be operational.
    [world addBody:bodyA];
    [world addBody:bodyB];
    XCTAssertTrue(joint.isOperational);
}

- (void)testNotOperationalAfterRemovingOneBody {
    MXBody* bodyA = [MXBody bodyWithType:MXBodyTypeDynamic position:CGPointZero rotation:0];
    MXBody* bodyB = [MXBody bodyWithType:MXBodyTypeDynamic position:CGPointZero rotation:0];

    // Construct a joint.
    MXJoint* joint = [bodyA constrainToBody:bodyB withJointType:MXJointTypeDistance];

    // Connect the joint to a world by adding its bodies to a world.
    MXWorld* world = [MXWorld worldWithGravity:CGPointZero];

    // Only after adding both bodies should the joint be operational.
    [world addBody:bodyA];
    [world addBody:bodyB];
    XCTAssertTrue(joint.isOperational);

    // Remove one of the bodies from the world. This should cause the joint to become non-operational.
    [world removeBody:bodyA];
    XCTAssertFalse(joint.isOperational);

    [world addBody:bodyA];
    XCTAssertTrue(joint.isOperational);

    [world removeBody:bodyB];
    XCTAssertFalse(joint.isOperational);
}

@end
