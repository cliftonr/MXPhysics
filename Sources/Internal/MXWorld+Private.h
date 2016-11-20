#import "MXWorld.h"
#import "MXBox2DInternal.h"

#pragma mark -
/**
 Private interface for MXWorld, implemented in MXWorld.mm.
 */
@interface MXWorld (Private)

/**
 The underlying Box2d world instance.
 */
@property (nonatomic, assign, readonly) b2World *b2World;

/**
 TRUE if the world is locked (it's inside a time-step).
 */
@property (nonatomic, assign, getter = isLocked, readonly) BOOL locked;

/**
 Enqueue a fixture for removal before the current timestep.
 
 @note This method should only be called inside a timestep.

 @param fixture The fixture to remove.
 */
- (void)__removeFixtureAfterTimeStep:(MXFixture *)fixture;

@end
