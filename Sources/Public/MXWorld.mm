#import "MXWorld.h"
#import "MXWorld+Private.h"
#import "MXBox2DInternal.h"
#import "MXBody+Private.h"
#import "MXFixture.h"
#import "MXContact+Private.h"
#import "MXRayCastIntersection+Private.h"
#import "MXContactListener.h"
#import "MXRayCastCallback.h"

#pragma mark -
/**
 This category exposes MXBody properties that pertain to the world's add/remove body operations.
 */
@interface MXBody (MXWorldAccess)

@property (nonatomic, weak, readwrite) MXWorld *world;

@end

#pragma mark -
@implementation MXBody (MXWorldAccess)

@dynamic world;

@end

#pragma mark -
@interface MXWorld ()

@property (nonatomic, strong) NSMutableSet *mutableBodies;

@property (nonatomic, strong) NSMutableSet *mutableBodiesToRemove;
@property (nonatomic, strong) NSMutableSet *mutableFixturesToRemove;

@property (nonatomic, assign) MXContactListener *b2ContactListener;

@property (nonatomic, assign, readwrite) b2World *b2World;

- (void)__removeQueuedObjects;

@end

#pragma mark -
@implementation MXWorld

// Relies on MXContactListener::_delegate.
@dynamic delegate;

// Relies on _mutableFixtures.
@dynamic bodies;

// Do not generate ivars for the following properties, as they rely on the underlying Box2d framework.
@dynamic gravity, allowSleep, autoClearForcesEnabled;

+ (instancetype)worldWithGravity:(CGPoint)gravity {
    return [[self alloc] initWithGravity:gravity];
}

- (instancetype)initWithGravity:(CGPoint)gravity {
    if (self = [super init]) {
        _mutableBodies = [NSMutableSet set];
        _mutableBodiesToRemove = [NSMutableSet set];
        _mutableFixturesToRemove = [NSMutableSet set];

        _b2World = new b2World(B2Vec2FromCGPoint(gravity));
        _b2ContactListener = new MXContactListener();
        
        _b2World->SetContactListener(_b2ContactListener);
    }
    
    return self;
}

- (void)dealloc {
    NSParameterAssert(_b2World);
    _b2World->SetContactListener(NULL);

    [self removeAllBodies];
    
    delete _b2World;
    _b2World = NULL;

    delete _b2ContactListener;
    _b2ContactListener = NULL;
}

- (b2World *)b2World {
    // b2World should stay defined for the entire life of the MXWorld.
    NSAssert(NULL != _b2World, @"b2World should never be NULL!");
    return _b2World;
}

- (BOOL)isLocked {
    return self.b2World->IsLocked();
}

- (NSSet *)bodies {
    return [_mutableBodies copy];
}

- (id<MXContactListenerDelegate>)delegate {
    return _b2ContactListener->GetDelegate();
}

- (void)setDelegate:(id<MXContactListenerDelegate>)delegate {
    _b2ContactListener->SetDelegate(delegate);
}

- (CGPoint)gravity {
    return CGPointFromB2Vec2(self.b2World->GetGravity());
}

- (void)setGravity:(CGPoint)gravity {
    self.b2World->SetGravity(B2Vec2FromCGPoint(gravity));
}

- (BOOL)isSleepingAllowed {
    return self.b2World->GetAllowSleeping();
}

- (void)setAllowSleep:(BOOL)allowSleep {
    self.b2World->SetAllowSleeping(allowSleep);
}

- (BOOL)isAutoClearForcesEnabled {
    return self.b2World->GetAutoClearForces();
}

- (void)setAutoClearForcesEnabled:(BOOL)autoClearForcesEnabled {
    self.b2World->SetAutoClearForces(autoClearForcesEnabled);
}

- (void)updateWithTimeStep:(CGFloat)timeStep velocityIterations:(NSInteger)velocityIterations
        positionIterations:(NSInteger)positionIterations
{
    [self.bodies makeObjectsPerformSelector:@selector(__recordLastTransform)];
    self.b2World->Step(timeStep, (int32)velocityIterations, (int32)positionIterations);
    [self __removeQueuedObjects];
}

- (void)clearForces {
    self.b2World->ClearForces();
}

- (void)addBody:(MXBody *)body {
    NSParameterAssert(body);

    if ([self.bodies containsObject:body]) {
        return;
    }

    // Remove body from another world if needed.
    [body.world removeBody:body];

    [self.mutableBodies addObject:body];
    body.world = self;

    [body __assemble];
}

- (void)removeBody:(MXBody *)body {
    NSParameterAssert(body);

    if (![self.bodies containsObject:body]) {
        return;
    } else if (self.isLocked) {
        [self.mutableBodiesToRemove addObject:body];
        return;
    }

    [body __disassemble];

    body.world = nil;
    [self.mutableBodies removeObject:body];
}

- (void)removeAllBodies {
    for (MXBody *body in self.bodies) {
        [self removeBody:body];
    }
}

#pragma mark - Private methods

- (void)__removeQueuedObjects {
    NSParameterAssert(!self.isLocked);

    for (MXBody *body in [self.mutableBodiesToRemove copy]) {
        [self removeBody:body];
    }

    for (MXFixture *fixture in [self.mutableFixturesToRemove copy]) {
        [fixture removeFromParentBody];
    }

    [self.mutableBodiesToRemove removeAllObjects];
    [self.mutableFixturesToRemove removeAllObjects];
}

@end

#pragma mark -
@implementation MXWorld (Private)

@dynamic b2World, locked;

- (void)__removeFixtureAfterTimeStep:(MXFixture *)fixture {
    NSParameterAssert(self.isLocked);
    [self.mutableFixturesToRemove addObject:fixture];
}

@end
