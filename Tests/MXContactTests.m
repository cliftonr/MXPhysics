#import <XCTest/XCTest.h>

#import "MXPhysics.h"

typedef void (^MXContactBlock)(MXContact *contact);

#pragma mark -
@interface MXContactTester : NSObject <MXContactListenerDelegate>

@property (nonatomic, copy) MXContactBlock beganBlock;
@property (nonatomic, copy) MXContactBlock endedBlock;
@property (nonatomic, copy) MXContactBlock preSolveBlock;

@end

#pragma mark -
@implementation MXContactTester

- (instancetype)init {
    if (self = [super init]) {
        _beganBlock = nil;
        _endedBlock = nil;
        _preSolveBlock = nil;
    }

    return self;
}

- (void)contactBegan:(MXContact *)contact {
    if (_beganBlock) {
        _beganBlock(contact);
    }
}

- (void)contactEnded:(MXContact *)contact {
    if (_endedBlock) {
        _endedBlock(contact);
    }
}

- (void)contactPreSolve:(MXContact *)contact {
    if (_preSolveBlock) {
        _preSolveBlock(contact);
    }
}

@end

#pragma mark -
@interface MXContact (ExposedForTesting)

/**
 Whether the contact is modifiable. This should only be TRUE during a pre-solve contact listener block.
 */
@property (nonatomic, assign, getter = isModifiable, readonly) BOOL modifiable;

@end

#pragma mark -
@interface MXContactTests : XCTestCase

@end

#pragma mark -
@implementation MXContactTests

- (void)testContactModifiableDuringPreSolve {
    // Construct a world and contact tester.
    MXWorld *world = [MXWorld worldWithGravity:CGPointZero];
    MXContactTester *contactTester = [[MXContactTester alloc] init];
    world.delegate = contactTester;

    // Add a couple of overlapping bodies and fixtures.
    MXBody *body1 = [MXBody bodyWithType:MXBodyTypeDynamic position:CGPointMake(10, 10) rotation:0];
    MXFixture *fixture1 = [MXFixture fixtureWithBoxSize:CGSizeMake(10, 10) atLocation:CGPointZero];
    [body1 addFixture:fixture1];

    MXBody *body2 = [MXBody bodyWithType:MXBodyTypeDynamic position:CGPointMake(15, 15) rotation:0];
    MXFixture *fixture2 = [MXFixture fixtureWithBoxSize:CGSizeMake(10, 10) atLocation:CGPointZero];
    [body2 addFixture:fixture2];

    [world addBody:body1];
    [world addBody:body2];

    __block MXContact *preSolveContact = nil;

    // The contact should be modifiable inside the pre-solve block.
    [contactTester setPreSolveBlock:^(MXContact *contact) {
        preSolveContact = contact;
        XCTAssertNotNil(preSolveContact);
        XCTAssertTrue(preSolveContact.isModifiable);
    }];

    // Update the world.
    [world updateWithTimeStep:1 velocityIterations:5 positionIterations:5];

    // The contact should not be modifiable outside the pre-solve block.
    XCTAssertNotNil(preSolveContact);
    XCTAssertFalse(preSolveContact.isModifiable);
}

- (void)testContactNotModifiableOutsidePreSolve {
    // Construct a world and contact tester.
    MXWorld *world = [MXWorld worldWithGravity:CGPointZero];
    MXContactTester *contactTester = [[MXContactTester alloc] init];
    world.delegate = contactTester;

    // Add a couple of overlapping bodies and fixtures.
    MXBody *body1 = [MXBody bodyWithType:MXBodyTypeDynamic position:CGPointMake(10, 10) rotation:0];
    MXFixture *fixture1 = [MXFixture fixtureWithBoxSize:CGSizeMake(10, 10) atLocation:CGPointZero];
    [body1 addFixture:fixture1];

    MXBody *body2 = [MXBody bodyWithType:MXBodyTypeDynamic position:CGPointMake(15, 15) rotation:0];
    MXFixture *fixture2 = [MXFixture fixtureWithBoxSize:CGSizeMake(10, 10) atLocation:CGPointZero];
    [body2 addFixture:fixture2];

    [world addBody:body1];
    [world addBody:body2];

    __block MXContact *beganContact = nil;

    // The contact should not be modifiable inside the began block.
    [contactTester setBeganBlock:^(MXContact *contact) {
        beganContact = contact;
        XCTAssertNotNil(beganContact);
        XCTAssertFalse(beganContact.isModifiable);
    }];

    // Update the world.
    [world updateWithTimeStep:1 velocityIterations:5 positionIterations:5];

    // The contact should not be modifiable outside the block either.
    XCTAssertNotNil(beganContact);
    XCTAssertFalse(beganContact.isModifiable);

    // Reposition body2 such that neither object overlaps the other.
    [body2 setPosition:CGPointMake(100, 100)];

    __block MXContact *endedContact = nil;

    // The contact should not be modifiable inside the ended block.
    [contactTester setEndedBlock:^(MXContact *contact) {
        endedContact = contact;
        XCTAssertNotNil(endedContact);
        XCTAssertFalse(endedContact.isModifiable);
    }];

    // Update the world.
    [world updateWithTimeStep:1 velocityIterations:5 positionIterations:5];

    // Again, the contact should not be modifiable outside the block either.
    XCTAssertNotNil(endedContact);
    XCTAssertFalse(endedContact.isModifiable);
}

@end
