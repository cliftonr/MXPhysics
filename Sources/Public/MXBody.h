#import "MXJoint.h"

/**
 The type of simulation performed on a body.

 - MXBodyTypeStatic:    Zero mass, zero velocity. No movement simulated.
 - MXBodyTypeKinematic: Zero mass, velocity set by user, simulated movement.
 - MXBodyTypeDynamic:   Positive mass, velocity determined by forces, simulated movement.
 */
typedef NS_ENUM(NSUInteger, MXBodyType) {
    MXBodyTypeStatic,
    MXBodyTypeKinematic,
    MXBodyTypeDynamic
};

@class MXWorld, MXFixture;

#pragma mark -
/**
 An ObjC wrapper for a b2Body. Length is measured in points, unlike Box2D, which uses meters. Angles are in
 degrees, unlike Box2D, which uses radians. Mass is measured in kilograms, same as Box2D.
 */
@interface MXBody : NSObject

/**
 The fixtures which have been added to the body.
 */
@property (nonatomic, copy, readonly, nonnull) NSSet<MXFixture *> *fixtures;

/**
 Joint edges, each referencing a joint to which this body is connected.
 
 @note A joint edge also references the other body that is connected to the joint.
 */
@property (nonatomic, copy, readonly, nonnull) NSSet<MXJointEdge *> *jointEdges;

/**
 The type of simulation performed on the body.
 */
@property (nonatomic, assign) MXBodyType type;

/**
 Position in points.
 */
@property (nonatomic, assign) CGPoint position;

/**
 Rotation in degrees.
 */
@property (nonatomic, assign) CGFloat rotation;

/**
 Velocity in points per second.
 */
@property (nonatomic, assign) CGPoint linearVelocity;

/**
 Angular velocity in degrees.
 */
@property (nonatomic, assign) CGFloat angularVelocity;

/**
 Reduces linear velocity. Generally between [0.0, 1.0].
 */
@property (nonatomic, assign) CGFloat linearDamping;

/**
 Reduces angular velocity. Generally between [0.0, 1.0].
 */
@property (nonatomic, assign) CGFloat angularDamping;

/**
 Scales the world's gravity upon this body.
 */
@property (nonatomic, assign) CGFloat gravityScale;

/**
 Allow body to sleep, conserving CPU usage.
 */
@property (nonatomic, assign, getter = isSleepingAllowed) BOOL allowSleep;

/**
 The initial state of the body: awake or sleeping.
 */
@property (nonatomic, assign, getter = isAwake) BOOL awake;

/**
 Whether the body is an active participant in the simulation.
 */
@property (nonatomic, assign, getter = isActive) BOOL active;

/**
 If TRUE, prevents body's rotation from changing.
 */
@property (nonatomic, assign, getter = isFixedRotation) BOOL fixedRotation;

/**
 If TRUE, increases precision at the cost of processing time.
 */
@property (nonatomic, assign, getter = isBullet) BOOL bullet;

/**
 The position before the last time step. If the simulation is updated with a fixed time step, but the graphics
 are rendered at a different rate, then this may lead to jittery animations. The client can smooth the
 animation by interpolating between previousPosition and position.
 See http://gafferongames.com/game-physics/fix-your-timestep/
 
 @note Only valid after the first time step.
 */
@property (nonatomic, assign, readonly) CGPoint previousPosition;

/**
 The rotation before the last time step. If the simulation is updated with a fixed time step, but the graphics
 are rendered at a different rate, then this may lead to jittery animations. The client can smooth the
 animation by interpolating between previousRotation and rotation.
 See http://gafferongames.com/game-physics/fix-your-timestep/

 @note Only valid after the first time step.
 */
@property (nonatomic, assign, readonly) CGFloat previousRotation;

/**
 The mass of the body.

 @note This property is valid only while the body is operational. See: isOperational.
 */
@property (nonatomic, assign, readonly) CGFloat mass;

/**
 The world in which the body resides.
 
 @note This property is defined while the body is operational.
 */
@property (nonatomic, weak, readonly, nullable) MXWorld *world;

/**
 Whether the body is operational. A body is operational if it is connected to an MXWorld.
 */
@property (nonatomic, assign, getter = isOperational, readonly) BOOL operational;

/**
 Used by client for anything.
 */
@property (nonatomic, weak, nullable) id userData;

/**
 Initialize a body.

 @param type     How the body is simulated.
 @param position The body's starting position.
 @param rotation The body's starting rotation.
 */
+ (nonnull instancetype)bodyWithType:(MXBodyType)type position:(CGPoint)position rotation:(CGFloat)rotation;

/**
 Add a fixture to the body.

 @param fixture The fixture to add.
 */
- (void)addFixture:(nonnull MXFixture *)fixture;

/**
 Remove a fixture from the body.

 @param fixture The fixture to remove.
 */
- (void)removeFixture:(nonnull MXFixture *)fixture;

/**
 Remove all fixtures from the body.
 */
- (void)removeAllFixtures;

/**
 Apply an impulse at a the body's center-point.
 
 @note This method only functions if the body is operational.

 @param impulse The impulse to apply.
 */
- (void)applyLinearImpulse:(CGPoint)impulse;

/**
 Apply an impulse at a point relative to the world.
 
 @note This method only functions if the body is operational.

 @param impulse The impulse to apply.
 @param point   The point at which to apply the impulse.
 */
- (void)applyLinearImpulse:(CGPoint)impulse atPoint:(CGPoint)point;

/**
 Constrains the receiving body to the specified body via a joint.

 @param body      The body to which the receiver shall be constrained.
 @param jointType The type of joint used to constrain the receiver and the specified body.

 @return A joint representing the constraint between the receiving body and the specified body.
 */
- (nonnull MXJoint *)constrainToBody:(nonnull MXBody *)body withJointType:(MXJointType)jointType;

/**
 Remove the constraint between the receiver and the specified body.

 @param body The body to which the receiver is currently constrained.
 */
- (void)breakConstraintToBody:(nonnull MXBody *)body;

/**
 Remove the receiver from its parent world if it has one.
 */
- (void)removeFromParentWorld;

@end
