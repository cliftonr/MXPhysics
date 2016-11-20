#import "MXDistanceJoint.h"
#import "MXJoint+Private.h"
#import "MXJoint+Subclass.h"
#import "MXBox2DInternal.h"

#pragma mark -
@interface MXDistanceJoint () <MXJointDefining>

@end

#pragma mark -
@implementation MXDistanceJoint

@dynamic length;

- (CGFloat)length {
    __block float32 b2Length;
    
    [self __performJointOperation:^(b2Joint *joint) {
        b2Length = ((b2DistanceJoint *)joint)->GetLength();
    } orJointDefOperation:^(b2JointDef *jointDef) {
        b2Length = ((b2DistanceJointDef *)jointDef)->length;
    }];
    
    return (CGFloat)b2Length;
}

- (void)setLength:(CGFloat)length {
    const float32 b2Length = (float32)length;
    
    [self __performJointOperation:^(b2Joint *joint) {
        ((b2DistanceJoint *)joint)->SetLength(b2Length);
    } orJointDefOperation:^(b2JointDef *jointDef) {
        ((b2DistanceJointDef *)jointDef)->length = b2Length;
    }];
}

+ (b2JointDef *)__constructJointDefinition {
    return new b2DistanceJointDef();
}

+ (void)__refreshJointDefinition:(b2JointDef *)jointDef withDataFromJoint:(b2Joint *)joint {
    b2DistanceJointDef *distanceJointDef = (b2DistanceJointDef *)jointDef;
    b2DistanceJoint *distanceJoint = (b2DistanceJoint *)joint;
    distanceJointDef->localAnchorA = distanceJoint->GetLocalAnchorA();
    distanceJointDef->localAnchorB = distanceJoint->GetLocalAnchorB();
    distanceJointDef->length = distanceJoint->GetLength();
    distanceJointDef->frequencyHz = distanceJoint->GetFrequency();
    distanceJointDef->dampingRatio = distanceJoint->GetDampingRatio();
}

@end
