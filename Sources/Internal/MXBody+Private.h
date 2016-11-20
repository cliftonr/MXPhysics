#import "MXBody.h"
#import "MXBox2DInternal.h"

@class MXJoint, MXJointEdge;

#pragma mark -
/**
 Private interface for MXBody, implemented in MXBody.mm.
 */
@interface MXBody (Private)

/**
 The underlying Box2d body instance.
 */
@property (nonatomic, assign, readonly) b2Body *b2Body;

/**
 Updates the values for -previousPosition and -previousRotation.
 */
- (void)__recordLastTransform;

/**
 The body uses its b2BodyDef to assemble a new b2Body.
 */
- (void)__assemble;

/**
 Destroys the underlying b2Body such that it may later be reassembled.
 */
- (void)__disassemble;

/**
 Add a joint edge to the body.

 @param jointEdge The joint to add to the body.
 */
- (void)__addJointEdge:(MXJointEdge *)jointEdge;

/**
 Remove a joint edge with the specified joint from the body.

 @param joint The joint which makes up the joint edge to remove.
 */
- (void)__removeJointEdgeWithJoint:(MXJoint *)joint;

@end
