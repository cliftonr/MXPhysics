#import <QuartzCore/QuartzCore.h>

typedef NS_ENUM(NSUInteger, MXJointType) {
    MXJointTypeDistance,

    // TODO: Implement these joint types:
    MXJointTypeFriction,
    MXJointTypeGear,
    MXJointTypeMouse,
    MXJointTypePrismatic,
    MXJointTypePulley,
	MXJointTypeRevolute,
    MXJointTypeRope,
    MXJointTypeWeld,
    MXJointTypeWheel,
};

@class MXWorld, MXBody, MXJoint;

#pragma mark -
/**
 An MXJointEdge specifies a link between a joint and some body other than the one which maintains the edge
 instance.
 */
@interface MXJointEdge : NSObject

/**
 The other body to which the joint is attached.
 */
@property (nonatomic, weak, readonly) MXBody *otherBody;

/**
 The joint which connects two bodies.
 */
@property (nonatomic, weak, readonly) MXJoint *joint;

@end

#pragma mark -
@interface MXJoint : NSObject

/**
 The joint type.
 */
@property (nonatomic, assign, readonly) MXJointType type;

/**
 The first attached body.
 */
@property (nonatomic, weak, readonly) MXBody *bodyA;

/**
 The second attached body.
 */
@property (nonatomic, weak, readonly) MXBody *bodyB;

/**
 The anchor point on bodyA in world coordinates.
 
 @note This value is only valid while the joint is operational.
 */
@property (nonatomic, assign, readonly) CGPoint anchorA;

/**
 The anchor point on bodyB in world coordinates.
 
 @note This value is only valid while the joint is operational.
 */
@property (nonatomic, assign, readonly) CGPoint anchorB;

/**
 Returns TRUE if both attached bodies are active.
 */
@property (nonatomic, assign, getter = isActive, readonly) BOOL active;

/**
 Whether the joint is operational. A joint is operational if both of its bodies are operational.
 */
@property (nonatomic, assign, getter = isOperational, readonly) BOOL operational;

/**
 Used by client for anything.
 */
@property (nonatomic, weak) id userData;

/**
 Compute the reaction force applied to bodyB at the anchor point.

 @param inverseTimeStep The inverse change in simulation time. This is 1 / timestep.

 @return The reaction force if the joint is operational; CGPointZero otherwise.
 */
- (CGPoint)calculateReactionForce:(CGFloat)inverseTimeStep;

/**
 Compute the reaction torque applied to bodyB at the anchor point.

 @param inverseTimeStep The inverse change in simulation time. This is 1 / timestep.

 @return The reaction torque if the joint is operational; CGPointZero otherwise.
 */
- (CGFloat)calculateReactionTorque:(CGFloat)inverseTimeStep;

@end
