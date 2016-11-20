#import "MXJoint.h"
#import "MXJoint+Private.h"
#import "MXJoint+Subclass.h"
#import "MXBox2DInternal.h"
#import "MXBody+Private.h"

// Include all of the joint subclasses here.
#import "MXDistanceJoint.h"

#define kDefaultMXJointType MXJointTypeDistance
#define kDefaultB2JointType e_distanceJoint

MXJointType MXJointTypeFromB2JointType(b2JointType type) {
    assert(((type == e_revoluteJoint) ||
            (type == e_prismaticJoint) ||
            (type == e_distanceJoint) ||
            (type == e_pulleyJoint) ||
            (type == e_mouseJoint) ||
            (type == e_gearJoint) ||
            (type == e_wheelJoint) ||
            (type == e_weldJoint) ||
            (type == e_frictionJoint) ||
            (type == e_ropeJoint)) && "Unrecognized joint type.");
    return (type == e_revoluteJoint ? MXJointTypeRevolute:
            type == e_prismaticJoint ? MXJointTypePrismatic :
            type == e_pulleyJoint ? MXJointTypePulley :
            type == e_mouseJoint ? MXJointTypeMouse :
            type == e_gearJoint ? MXJointTypeGear :
            type == e_wheelJoint ? MXJointTypeWheel :
            type == e_weldJoint ? MXJointTypeWeld :
            type == e_frictionJoint ? MXJointTypeFriction :
            type == e_ropeJoint ? MXJointTypeRope : MXJointTypeDistance);
}

b2JointType B2JointTypeFromMXJointType(MXJointType type) {
    assert(((type == MXJointTypeRevolute) ||
            (type == MXJointTypePrismatic) ||
            (type == MXJointTypeDistance) ||
            (type == MXJointTypePulley) ||
            (type == MXJointTypeMouse) ||
            (type == MXJointTypeGear) ||
            (type == MXJointTypeWheel) ||
            (type == MXJointTypeWeld) ||
            (type == MXJointTypeFriction) ||
            (type == MXJointTypeRope)) && "Unrecognized joint type.");
    return (type == MXJointTypeRevolute ? e_revoluteJoint :
            type == MXJointTypePrismatic ? e_prismaticJoint :
            type == MXJointTypePulley ? e_pulleyJoint :
            type == MXJointTypeMouse ? e_mouseJoint :
            type == MXJointTypeGear ? e_gearJoint :
            type == MXJointTypeWheel ? e_wheelJoint :
            type == MXJointTypeWeld ? e_weldJoint :
            type == MXJointTypeFriction ? e_frictionJoint :
            type == MXJointTypeRope ? e_ropeJoint : e_distanceJoint);
}

#pragma mark -
@interface MXJointEdge ()

@property (nonatomic, weak, readwrite) MXJoint *joint;

@end

#pragma mark -
@implementation MXJointEdge

- (instancetype)initWithJoint:(MXJoint *)joint otherBody:(MXBody *)body {
    if (self = [super init]) {
        _joint = joint;
        _otherBody = body;
    }
    
    return self;
}

@end

#pragma mark -
@implementation MXJointEdge (Private)

+ (instancetype)__jointEdgeWithJoint:(MXJoint *)joint otherBody:(MXBody *)body {
    return [[self alloc] initWithJoint:joint otherBody:body];
}

@end

#pragma mark -
@interface MXJoint ()

@property (nonatomic, assign) b2JointDef *b2JointDef;

@property (nonatomic, assign, readwrite) MXJointType type;
@property (nonatomic, assign, readwrite) b2Joint *b2Joint;
@property (nonatomic, weak, readwrite) MXBody *bodyA;
@property (nonatomic, weak, readwrite) MXBody *bodyB;

@end

#pragma mark -
@implementation MXJoint

// Do not generate ivars for the following properties, as they rely on the underlying Box2d framework.
@dynamic anchorA, anchorB, active, operational;

- (void)dealloc {
    [self.bodyA __removeJointEdgeWithJoint:self];
    [self.bodyB __removeJointEdgeWithJoint:self];
    
    NSParameterAssert(_b2JointDef);
    _b2JointDef->userData = NULL;
    delete _b2JointDef;
    _b2JointDef = NULL;
    
    if (_b2Joint) {
        _b2Joint->GetBodyA()->GetWorld()->DestroyJoint(_b2Joint);
        _b2Joint = NULL;
    }
}

- (CGPoint)anchorA {
    __block b2Vec2 b2AnchorPoint;
    
    [self __performJointOperation:^(b2Joint *joint) {
        b2AnchorPoint = joint->GetAnchorA();
    } orJointDefOperation:^(b2JointDef *jointDef) {
        b2AnchorPoint = b2Vec2_zero;
    }];
    
    return CGPointFromB2Vec2(b2AnchorPoint);
}

- (CGPoint)anchorB {
    __block b2Vec2 b2AnchorPoint;
    
    [self __performJointOperation:^(b2Joint *joint) {
        b2AnchorPoint = joint->GetAnchorB();
    } orJointDefOperation:^(b2JointDef *jointDef) {
        b2AnchorPoint = b2Vec2_zero;
    }];
    
    return CGPointFromB2Vec2(b2AnchorPoint);
}

- (BOOL)isActive {
    return self.bodyA.isActive && self.bodyB.isActive;
}

- (BOOL)isOperational {
    return NULL != self.b2Joint;
}

- (CGPoint)calculateReactionForce:(CGFloat)inverseTimeStep {
    __block b2Vec2 b2ReactionForce;

    [self __performJointOperation:^(b2Joint *joint) {
        b2ReactionForce = joint->GetReactionForce(inverseTimeStep);
    } orJointDefOperation:^(b2JointDef *jointDef) {
        b2ReactionForce = b2Vec2_zero;
    }];
    
    return CGPointFromB2Vec2(b2ReactionForce);
}

- (CGFloat)calculateReactionTorque:(CGFloat)inverseTimeStep {
    __block float32 b2ReactionTorque;
    
    [self __performJointOperation:^(b2Joint *joint) {
        b2ReactionTorque = joint->GetReactionTorque(inverseTimeStep);
    } orJointDefOperation:^(b2JointDef *jointDef) {
        b2ReactionTorque = 0.0;
    }];
    
    return (CGFloat)b2ReactionTorque;
}

@end

#pragma mark -
@implementation MXJoint (Private)

+ (instancetype)__jointWithBodyA:(MXBody *)bodyA bodyB:(MXBody *)bodyB type:(MXJointType)type {
    Class jointClass = Nil;
    
    switch (type) {
        case MXJointTypeRevolute:
            break;
        case MXJointTypePrismatic:
            break;
        case MXJointTypeDistance:
            jointClass = [MXDistanceJoint class];
            break;
        case MXJointTypePulley:
            break;
        case MXJointTypeMouse:
            break;
        case MXJointTypeGear:
            break;
        case MXJointTypeWheel:
            break;
        case MXJointTypeWeld:
            break;
        case MXJointTypeFriction:
            break;
        case MXJointTypeRope:
            break;
        default:
            NSAssert1(0, @"Invalid joint type specified: %i", (int)type);
            break;
    }
    
    MXJoint *joint = [[jointClass alloc] initWithBodyA:bodyA bodyB:bodyB];
    [joint setType:type];
    return joint;
}

- (instancetype)initWithBodyA:(MXBody *)bodyA bodyB:(MXBody *)bodyB {
    NSParameterAssert(bodyA);
    NSParameterAssert(bodyB);

    if (self = [super init]) {
        _bodyA = bodyA;
        _bodyB = bodyB;

        NSAssert([self conformsToProtocol:@protocol(MXJointDefining)],
                 @"MXJoint subclasses must conform to MXJointDefining.");

        b2JointDef *b2JointDef = [[self class] __constructJointDefinition];
        b2JointDef->userData = (__bridge void *)self;
        _b2JointDef = b2JointDef;
    }
    
    return self;
}

- (void)__assemble {
    if (self.b2Joint || !self.bodyA.isOperational || !self.bodyB.isOperational) {
        return;
    }

    NSParameterAssert(self.b2JointDef);
    NSAssert(self.bodyA.world == self.bodyB.world, @"Jointed bodies must belong to the same world.");

    // Add the bodies to the joint definition.
    b2JointDef *b2JointDef = self.b2JointDef;
    b2JointDef->bodyA = self.bodyA.b2Body;
    b2JointDef->bodyB = self.bodyB.b2Body;

    // Create the joint.
    self.b2Joint = self.bodyA.b2Body->GetWorld()->CreateJoint(self.b2JointDef);
}

- (void)__disassemble {
    // Disassemble this joint.
    b2Joint *b2Joint = self.b2Joint;
    if (!b2Joint) {
        return;
    }

    NSParameterAssert(self.b2JointDef);

    // Update the joint definition with the joint data.
    b2JointDef *b2JointDef = self.b2JointDef;
    b2JointDef->bodyA = NULL;
    b2JointDef->bodyB = NULL;
    b2JointDef->userData = b2Joint->GetUserData();
    b2JointDef->collideConnected = b2Joint->GetCollideConnected();

    // Have subclass update its related fields in the joint definition.
    [[self class] __refreshJointDefinition:b2JointDef withDataFromJoint:b2Joint];

    // Destroy the old joint.
    b2Joint->GetBodyA()->GetWorld()->DestroyJoint(b2Joint);
    self.b2Joint = NULL;
}

- (void)__performJointOperation:(void (^)(b2Joint *joint))jointOperation
            orJointDefOperation:(void (^)(b2JointDef *jointDef))jointDefOperation
{
    NSParameterAssert(jointOperation);
    NSParameterAssert(jointDefOperation);

    self.b2Joint != NULL ? jointOperation(self.b2Joint) : jointDefOperation(self.b2JointDef);
}

@end
