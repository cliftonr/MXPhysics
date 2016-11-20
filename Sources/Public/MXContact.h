#import <QuartzCore/QuartzCore.h>

@class MXFixture, MXContact;

#pragma mark -
/**
 The contact listener handles contact events.
 */
@protocol MXContactListenerDelegate <NSObject>

@optional

/**
 Contact began between two fixtures.

 @param contact Information about the contact.
 */
- (void)contactBegan:(nonnull MXContact *)contact;

/**
 Contact ended between two fixtures.

 @param contact Information about the contact.
 */
- (void)contactEnded:(nonnull MXContact *)contact;

/**
 Called after contact is updated, but before it is sent to the solver.

 @param contact Information about the contact.
 */
- (void)contactPreSolve:(nonnull MXContact *)contact;

@end

#pragma mark -
/**
 An ObjC wrapper for a b2Contact.
 */
@interface MXContact : NSObject

/**
 The first fixture in the contact event.
 */
@property (nonatomic, strong, readonly, nonnull) MXFixture *fixtureA;

/**
 The other fixture in the contact event.
 */
@property (nonatomic, strong, readonly, nonnull) MXFixture *fixtureB;

/**
 Normal vector in world coordinates pointing from A to B.
 */
@property (nonatomic, assign, readonly) CGPoint normal;

/**
 The points of intersection. May have size 0, 1, or 2, depending on the type of contact.
 */
@property (nonatomic, copy, readonly, nonnull) NSArray<NSValue *> *intersectionPoints;

/**
 True if the fixtures are physically touching.
 */
@property (nonatomic, assign, getter = isTouching, readonly) BOOL touching;

/**
 Whether the contact is enabled. Contacts are enabled by default. 
 
 @note May only be changed within the scope of -[MXContactDelegate contactPreSolve:]
 */
@property (nonatomic, assign, getter = isEnabled) BOOL enabled;

/**
 Determine the center of the intersection points.

 @return If one or more intersection points exist, returns their average. Otherwise return CGPointZero.
 */
- (CGPoint)center;

@end
