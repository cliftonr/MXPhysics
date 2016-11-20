#import "MXJoint.h"
#import "MXBox2DInternal.h"

#pragma mark -
/**
 Private interface for MXJointEdge, implemented in MXJoint.mm.
 */
@interface MXJointEdge (Private)

+ (instancetype)__jointEdgeWithJoint:(MXJoint *)joint otherBody:(MXBody *)body;

@end

#pragma mark -
/**
 Private interface for MXJoint, implemented in MXJoint.mm.
 */
@interface MXJoint (Private)

/**
 Designated initializer.

 @param bodyA The first body in the joint relationship.
 @param bodyB The second body in the joint relationship.
 @param type  The type of relationship represented by the joint.
 */
+ (instancetype)__jointWithBodyA:(MXBody *)bodyA bodyB:(MXBody *)bodyB type:(MXJointType)type;

/**
 The joint uses its b2JointDef to assemble a new b2Joint.
 */
- (void)__assemble;

/**
 Destroys the underlying b2Joint such that it may later be reassembled.
 */
- (void)__disassemble;

/**
 Performs the most suitable operation. If the joint is defined, the joint operation is performed, otherwise,
 the join def operation is performed.

 @param jointOperation    The operation to perform if the joint is defined.
 @param jointDefOperation The operation to perform if the joint isn't defined.
 */
- (void)__performJointOperation:(void (^)(b2Joint *joint))jointOperation
            orJointDefOperation:(void (^)(b2JointDef *jointDef))jointDefOperation;

@end
