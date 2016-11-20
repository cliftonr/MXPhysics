#import <QuartzCore/QuartzCore.h>

@class MXWorld, MXBody, MXFixture;
@protocol MXContactListenerDelegate;

#pragma mark -
/**
 An ObjC wrapper for a b2World. Length is measured in points, unlike Box2D, which uses meters. Angles are 
 measured in degrees, unlike Box2D, which uses radians. Mass is measured in kilograms, just like Box2D.
 */
@interface MXWorld : NSObject

/**
 The contact listener receives updates whenever objects come in contact with each other.
 */
@property (nonatomic, weak, nullable) id<MXContactListenerDelegate> delegate;

/**
 The bodies which have been added to the world.
 */
@property (nonatomic, copy, readonly, nonnull) NSSet<MXBody *> *bodies;

/**
 The world gravity vector, in pnts / s^2.
 */
@property (nonatomic, assign) CGPoint gravity;

/**
 Allow bodies to sleep.
 */
@property (nonatomic, assign, getter = isSleepingAllowed) BOOL allowSleep;

/**
 Automatically clears forces after each update when enabled.
 */
@property (nonatomic, assign, getter = isAutoClearForcesEnabled) BOOL autoClearForcesEnabled;

/**
 Designated initializer.

 @param gravity The world gravity vector, in pnts / s^2
 */
+ (nonnull instancetype)worldWithGravity:(CGPoint)gravity;

/**
 Update the simulation.

 @param timeStep           The amount of time to simulate. Box2D recommends a fixed time step.
 @param velocityIterations ...
 @param positionIterations ...
 */
- (void)updateWithTimeStep:(CGFloat)timeStep velocityIterations:(NSInteger)velocityIterations
        positionIterations:(NSInteger)positionIterations;

/**
 Manually clears the force buffer on all bodies. By default, forces are cleared automatically, but that
 behavior can be changed by setting the autoClearForcesEnabled property.
 */
- (void)clearForces;

/**
 Add a body to the world.

 @param body The body to add.
 */
- (void)addBody:(nonnull MXBody *)body;

/**
 Remove a body from the world. If the world is locked (it's inside a time-step) then the body shall be removed
 after the time step.

 @param body The body to remove.
 */
- (void)removeBody:(nonnull MXBody *)body;

/**
 Remove all bodies from the world.
 */
- (void)removeAllBodies;

@end
