#import "MXBody.h"
#import "MXBody+Private.h"
#import "MXBox2DInternal.h"
#import "MXWorld+Private.h"
#import "MXFixture+Private.h"
#import "MXJoint+Private.h"

MXBodyType MXBodyTypeFromB2BodyType(b2BodyType type) {
    assert(((type == b2_staticBody) || (type == b2_kinematicBody) || (type == b2_dynamicBody))
           && "Unrecognized body type.");
    return (type == b2_staticBody ? MXBodyTypeStatic :
            type == b2_kinematicBody ? MXBodyTypeKinematic : MXBodyTypeDynamic);
}

b2BodyType B2BodyTypeFromMXBodyType(MXBodyType type) {
    assert(((type == MXBodyTypeStatic) || (type == MXBodyTypeKinematic) || (type == MXBodyTypeDynamic))
           && "Unrecognized body type.");
    return (type == MXBodyTypeStatic ? b2_staticBody :
            type == MXBodyTypeKinematic ? b2_kinematicBody : b2_dynamicBody);
}

#pragma mark -
/**
 This category exposes MXFixture properties that pertain to the body's add/remove fixture operations.
 */
@interface MXFixture (MXBodyAccess)

@property (nonatomic, weak, readwrite) MXBody *body;

@end

#pragma mark -
@implementation MXFixture (MXBodyAccess)

@dynamic body;

@end

#pragma mark -
@interface MXBody ()

@property (nonatomic, assign) b2BodyDef *b2BodyDef;

@property (nonatomic, strong) NSMutableSet *mutableFixtures;
@property (nonatomic, strong) NSMutableSet *mutableJointEdges;

@property (nonatomic, assign) b2Body *b2Body;
@property (nonatomic, weak, readwrite) MXWorld *world;
@property (nonatomic, assign, readwrite) CGPoint previousPosition;
@property (nonatomic, assign, readwrite) CGFloat previousRotation;

- (void)__performBodyOperation:(void (^)(b2Body *body))bodyOperation
            orBodyDefOperation:(void (^)(b2BodyDef *bodyDef))bodyDefOperation;

- (void)__removeAllJointEdges;

@end

#pragma mark -
@implementation MXBody

// Relies on _mutableFixtures.
@dynamic fixtures;

// Relies on _mutableJointEdges.
@dynamic jointEdges;

// Do not generate ivars for the following properties, as they rely on the underlying Box2d framework.
@dynamic type, position, rotation, linearVelocity, angularVelocity, linearDamping, angularDamping,
gravityScale, allowSleep, awake, active, fixedRotation, bullet, mass, operational;

+ (instancetype)bodyWithType:(MXBodyType)type position:(CGPoint)position rotation:(CGFloat)rotation {
    return [[self alloc] initWithType:type position:position rotation:rotation];
}

- (instancetype)initWithType:(MXBodyType)type position:(CGPoint)position rotation:(CGFloat)rotation {
    self = [super init];
    
    if (self) {
        _mutableFixtures = [NSMutableSet set];
        _mutableJointEdges = [NSMutableSet set];

        b2BodyDef *bodyDef = new b2BodyDef();
        bodyDef->type = B2BodyTypeFromMXBodyType(type);
        bodyDef->position = B2Vec2FromCGPoint(position);
        bodyDef->angle = MX_DEGREES_TO_RADIANS(rotation);
        bodyDef->userData = (__bridge void*)self;
        _b2BodyDef = bodyDef;
        
        // These will be defined after the MXBody is added to an MXWorld.
        _b2Body = NULL;
        _world = nil;
    }
    
    return self;
}

- (void)dealloc {
    [self __removeAllJointEdges];
    [self removeAllFixtures];
    
    NSParameterAssert(_b2BodyDef);
    _b2BodyDef->userData = NULL;

    delete _b2BodyDef;
    _b2BodyDef = NULL;
    
    if (_b2Body) {
        _b2Body->GetWorld()->DestroyBody(_b2Body);
        _b2Body = NULL;
    }
}

- (NSSet *)fixtures {
    return [_mutableFixtures copy];
}

- (NSSet *)jointEdges {
    return [_mutableJointEdges copy];
}

- (MXBodyType)type {
    __block b2BodyType b2Type;
    
    [self __performBodyOperation:^(b2Body *body) {
        b2Type = body->GetType();
    } orBodyDefOperation:^(b2BodyDef *bodyDef) {
        b2Type = bodyDef->type;
    }];
        
    return MXBodyTypeFromB2BodyType(b2Type);
}

- (void)setType:(MXBodyType)type {
    __block const b2BodyType b2Type = B2BodyTypeFromMXBodyType(type);
    
    [self __performBodyOperation:^(b2Body *body) {
        body->SetType(b2Type);
    } orBodyDefOperation:^(b2BodyDef *bodyDef) {
        bodyDef->type = b2Type;
    }];
}

- (CGPoint)position {
    __block b2Vec2 b2Position;
    
    [self __performBodyOperation:^(b2Body *body) {
        b2Position = body->GetPosition();
    } orBodyDefOperation:^(b2BodyDef *bodyDef) {
        b2Position = bodyDef->position;
    }];
        
    return CGPointFromB2Vec2(b2Position);
}

- (void)setPosition:(CGPoint)position {
    __block const b2Vec2 b2Position = B2Vec2FromCGPoint(position);
    
    [self __performBodyOperation:^(b2Body *body) {
        body->SetTransform(b2Position, body->GetAngle());
    } orBodyDefOperation:^(b2BodyDef *bodyDef) {
        bodyDef->position = b2Position;
    }];
}

- (CGFloat)rotation {
    __block float32 b2Angle;
    
    [self __performBodyOperation:^(b2Body *body) {
        b2Angle = body->GetAngle();
    } orBodyDefOperation:^(b2BodyDef *bodyDef) {
        b2Angle = bodyDef->angle;
    }];
        
    return MX_RADIANS_TO_DEGREES(b2Angle);
}

- (void)setRotation:(CGFloat)rotation {
    __block const float32 b2Angle = MX_DEGREES_TO_RADIANS(rotation);
        
    [self __performBodyOperation:^(b2Body *body) {
        body->SetTransform(body->GetPosition(), b2Angle);
    } orBodyDefOperation:^(b2BodyDef *bodyDef) {
        bodyDef->angle = b2Angle;
    }];
}

- (CGPoint)linearVelocity {
    __block b2Vec2 b2LinearVelocity;
    
    [self __performBodyOperation:^(b2Body *body) {
        b2LinearVelocity = body->GetLinearVelocity();
    } orBodyDefOperation:^(b2BodyDef *bodyDef) {
        b2LinearVelocity = bodyDef->linearVelocity;
    }];
        
    return CGPointFromB2Vec2(b2LinearVelocity);
}

- (void)setLinearVelocity:(CGPoint)linearVelocity {
    __block const b2Vec2 b2LinearVelocity = B2Vec2FromCGPoint(linearVelocity);
    
    [self __performBodyOperation:^(b2Body *body) {
        body->SetLinearVelocity(b2LinearVelocity);
    } orBodyDefOperation:^(b2BodyDef *bodyDef) {
        bodyDef->linearVelocity = b2LinearVelocity;
    }];
}

- (CGFloat)angularVelocity {
    __block CGFloat angularVelocity;
    
    [self __performBodyOperation:^(b2Body *body) {
        angularVelocity = body->GetAngularVelocity();
    } orBodyDefOperation:^(b2BodyDef *bodyDef) {
        angularVelocity = bodyDef->angularVelocity;
    }];
        
    return -MX_RADIANS_TO_DEGREES(angularVelocity);
}

- (void)setAngularVelocity:(CGFloat)angularVelocity {
    __block const float32 b2AngularVelocity = MX_DEGREES_TO_RADIANS(-angularVelocity);

    [self __performBodyOperation:^(b2Body *body) {
        body->SetAngularVelocity(b2AngularVelocity);
    } orBodyDefOperation:^(b2BodyDef *bodyDef) {
        bodyDef->angularVelocity = b2AngularVelocity;
    }];
}

- (CGFloat)linearDamping {
    __block CGFloat linearDamping;
    
    [self __performBodyOperation:^(b2Body *body) {
        linearDamping = body->GetLinearDamping();
    } orBodyDefOperation:^(b2BodyDef *bodyDef) {
        linearDamping = bodyDef->linearDamping;
    }];
    
    return linearDamping;
}

- (void)setLinearDamping:(CGFloat)linearDamping {
    [self __performBodyOperation:^(b2Body *body) {
        body->SetLinearDamping(linearDamping);
    } orBodyDefOperation:^(b2BodyDef *bodyDef) {
        bodyDef->linearDamping = linearDamping;
    }];
}

- (CGFloat)angularDamping {
    __block CGFloat angularDamping;
    
    [self __performBodyOperation:^(b2Body *body) {
        angularDamping = body->GetAngularDamping();
    } orBodyDefOperation:^(b2BodyDef *bodyDef) {
        angularDamping = bodyDef->angularDamping;
    }];
    
    return angularDamping;
}

- (void)setAngularDamping:(CGFloat)angularDamping {
    [self __performBodyOperation:^(b2Body *body) {
        body->SetAngularDamping(angularDamping);
    } orBodyDefOperation:^(b2BodyDef *bodyDef) {
        bodyDef->angularDamping = angularDamping;
    }];
}

- (CGFloat)gravityScale {
    __block CGFloat gravityScale;
    
    [self __performBodyOperation:^(b2Body *body) {
        gravityScale = body->GetGravityScale();
    } orBodyDefOperation:^(b2BodyDef *bodyDef) {
        gravityScale = bodyDef->gravityScale;
    }];
    
    return gravityScale;
}

- (void)setGravityScale:(CGFloat)gravityScale {
    [self __performBodyOperation:^(b2Body *body) {
        body->SetGravityScale(gravityScale);
    } orBodyDefOperation:^(b2BodyDef *bodyDef) {
        bodyDef->gravityScale = gravityScale;
    }];
}

- (BOOL)isSleepingAllowed {
    __block BOOL isSleepingAllowed;
    
    [self __performBodyOperation:^(b2Body *body) {
        isSleepingAllowed = body->IsSleepingAllowed();
    } orBodyDefOperation:^(b2BodyDef *bodyDef) {
        isSleepingAllowed = bodyDef->allowSleep;
    }];
    
    return isSleepingAllowed;
}

- (void)setAllowSleep:(BOOL)allowSleep {
    [self __performBodyOperation:^(b2Body *body) {
        body->SetSleepingAllowed(allowSleep);
    } orBodyDefOperation:^(b2BodyDef *bodyDef) {
        bodyDef->allowSleep = allowSleep;
    }];
}

- (BOOL)isAwake {
    __block BOOL isAwake;
    
    [self __performBodyOperation:^(b2Body *body) {
        isAwake = body->IsAwake();
    } orBodyDefOperation:^(b2BodyDef *bodyDef) {
        isAwake = bodyDef->awake;
    }];
    
    return isAwake;
}

- (void)setAwake:(BOOL)awake {
    [self __performBodyOperation:^(b2Body *body) {
        body->SetAwake(awake);
    } orBodyDefOperation:^(b2BodyDef *bodyDef) {
        bodyDef->awake = awake;
    }];
}

- (BOOL)isActive {
    __block BOOL isActive;
    
    [self __performBodyOperation:^(b2Body *body) {
        isActive = body->IsActive();
    } orBodyDefOperation:^(b2BodyDef *bodyDef) {
        isActive = bodyDef->active;
    }];
    
    return isActive;
}

- (void)setActive:(BOOL)active {
    [self __performBodyOperation:^(b2Body *body) {
        body->SetActive(active);
    } orBodyDefOperation:^(b2BodyDef *bodyDef) {
        bodyDef->active = active;
    }];
}

- (BOOL)isFixedRotation {
    __block BOOL isFixedRotation;
    
    [self __performBodyOperation:^(b2Body *body) {
        isFixedRotation = body->IsFixedRotation();
    } orBodyDefOperation:^(b2BodyDef *bodyDef) {
        isFixedRotation = bodyDef->fixedRotation;
    }];
    
    return isFixedRotation;
}

- (void)setFixedRotation:(BOOL)fixedRotation {
    [self __performBodyOperation:^(b2Body *body) {
        body->SetFixedRotation(fixedRotation);
    } orBodyDefOperation:^(b2BodyDef *bodyDef) {
        bodyDef->fixedRotation = fixedRotation;
    }];
}

- (BOOL)isBullet {
    __block BOOL isBullet;
    
    [self __performBodyOperation:^(b2Body *body) {
        isBullet = body->IsBullet();
    } orBodyDefOperation:^(b2BodyDef *bodyDef) {
        isBullet = bodyDef->bullet;
    }];
    
    return isBullet;
}

- (void)setBullet:(BOOL)bullet {
    [self __performBodyOperation:^(b2Body *body) {
        body->SetBullet(bullet);
    } orBodyDefOperation:^(b2BodyDef *bodyDef) {
        bodyDef->bullet = bullet;
    }];
}

- (CGFloat)mass {
    CGFloat mass = 1;
    
    if (self.isOperational) {
        mass = self.b2Body->GetMass();
    }
    
    return mass;
}

- (BOOL)isOperational {
    return NULL != self.b2Body;
}

- (void)addFixture:(MXFixture *)fixture {
    NSParameterAssert(fixture);

    if ([self.fixtures containsObject:fixture]) {
        return;
    }

    // Remove from other body.
    [fixture.body removeFixture:fixture];

    [self.mutableFixtures addObject:fixture];
    fixture.body = self;

    [fixture __assemble];
}

- (void)removeFixture:(MXFixture *)fixture {
    NSParameterAssert(fixture);

    if (![self.fixtures containsObject:fixture]) {
        return;
    } else if (self.world.isLocked) {
        [self.world __removeFixtureAfterTimeStep:fixture];
        return;
    }

    [fixture __disassemble];

    fixture.body = nil;
    [self.mutableFixtures removeObject:fixture];
}

- (void)removeAllFixtures {
    for (MXFixture *fixture in self.fixtures) {
        [self removeFixture:fixture];
    }
}

- (void)applyLinearImpulse:(CGPoint)impulse {
    if (self.isOperational) {
        self.b2Body->ApplyLinearImpulse(B2Vec2FromCGPoint(impulse), self.b2Body->GetWorldCenter());
    }
}

- (void)applyLinearImpulse:(CGPoint)impulse atPoint:(CGPoint)point {
    if (self.isOperational) {
        self.b2Body->ApplyLinearImpulse(B2Vec2FromCGPoint(impulse), B2Vec2FromCGPoint(point));
    }
}

- (MXJoint *)constrainToBody:(MXBody *)body withJointType:(MXJointType)jointType {
    MXJoint *joint = [MXJoint __jointWithBodyA:self bodyB:body type:jointType];
    [self __addJointEdge:[MXJointEdge __jointEdgeWithJoint:joint otherBody:body]];
    [body __addJointEdge:[MXJointEdge __jointEdgeWithJoint:joint otherBody:self]];
    return joint;
}

- (void)breakConstraintToBody:(MXBody *)body {
    // TODO: Implement me!
}


- (void)removeFromParentWorld {
    [self.world removeBody:self];
}

#pragma mark - Private methods

- (void)__performBodyOperation:(void (^)(b2Body *body))bodyOperation
            orBodyDefOperation:(void (^)(b2BodyDef *bodyDef))bodyDefOperation
{
    NSParameterAssert(bodyOperation);
    NSParameterAssert(bodyDefOperation);
    
    if (self.b2Body) {
        bodyOperation(self.b2Body);
    } else {
        bodyDefOperation(self.b2BodyDef);
    }
}

- (void)__removeAllJointEdges {
    for (MXJointEdge *jointEdge in self.jointEdges) {
        [self __removeJointEdgeWithJoint:jointEdge.joint];
    }
}

@end

#pragma mark -
@implementation MXBody (Private)

@dynamic b2Body;

- (void)__recordLastTransform {
    self.previousPosition = self.position;
    self.previousRotation = self.rotation;
}

- (void)__assemble {
    if (self.b2Body || !self.world || !self.world.b2World) {
        return;
    }

    NSParameterAssert(self.b2BodyDef);

    self.b2Body = self.world.b2World->CreateBody(self.b2BodyDef);

    [self.fixtures makeObjectsPerformSelector:@selector(__assemble)];

    for (MXJointEdge *jointEdge in self.jointEdges) {
        [jointEdge.joint __assemble];
    }
}

- (void)__disassemble {
    for (MXJointEdge *jointEdge in self.jointEdges) {
        [jointEdge.joint __disassemble];
    }
    
    [self.fixtures makeObjectsPerformSelector:@selector(__disassemble)];
    
    b2Body *b2Body = self.b2Body;
    if (!b2Body) {
        return;
    }

    NSParameterAssert(self.b2BodyDef);
    
    b2BodyDef *bodyDef = self.b2BodyDef;
    bodyDef->position = b2Body->GetPosition();
    bodyDef->angle = b2Body->GetAngle();
    bodyDef->linearVelocity = b2Body->GetLinearVelocity();
    bodyDef->angularVelocity = b2Body->GetAngularVelocity();
    bodyDef->linearDamping = b2Body->GetLinearDamping();
    bodyDef->angularDamping = b2Body->GetAngularDamping();
    bodyDef->allowSleep = b2Body->IsSleepingAllowed();
    bodyDef->awake = b2Body->IsAwake();
    bodyDef->fixedRotation = b2Body->IsFixedRotation();
    bodyDef->bullet = b2Body->IsBullet();
    bodyDef->type = b2Body->GetType();
    bodyDef->active = b2Body->IsActive();
    bodyDef->gravityScale = b2Body->GetGravityScale();
    bodyDef->userData = b2Body->GetUserData();

    b2Body->GetWorld()->DestroyBody(b2Body);
    self.b2Body = NULL;
}

- (void)__addJointEdge:(MXJointEdge *)jointEdge {
    for (MXJointEdge *edge in self.jointEdges) {
        if (edge.joint == jointEdge.joint) {
            return;
        }
    }
    
    [self.mutableJointEdges addObject:jointEdge];
    [jointEdge.joint __assemble];
}

- (void)__removeJointEdgeWithJoint:(MXJoint *)joint {
    for (MXJointEdge *edge in self.jointEdges) {
        if (edge.joint == joint) {
            [edge.joint __disassemble];
            [self.mutableJointEdges removeObject:edge];
            return;
        }
    }
}

@end
