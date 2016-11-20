#import "MXFixture.h"
#import "MXBox2DInternal.h"

#pragma mark -
/**
 Private interface for MXFixture, implemented in MXFixture.mm.
 */
@interface MXFixture (Private)

/**
 The underlying Box2d fixture instance.
 */
@property (nonatomic, assign, readonly) b2Fixture *b2Fixture;

/**
 The fixture uses its b2FixtureDef to assemble a new b2Fixture.
 */
- (void)__assemble;

/**
 Destroys the underlying b2Fixture such that it may later be reassembled.
 */
- (void)__disassemble;

@end
