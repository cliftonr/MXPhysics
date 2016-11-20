#import "MXContact.h"
#import "MXBox2DInternal.h"

#pragma mark -
/**
 Private interface for MXContact, implemented in MXContact.mm.
 */
@interface MXContact (Private)

/**
 Calls contactWithB2Contact:isModifiable: with isModifiable set to FALSE.

 @param b2Contact The Box2D contact object to wrap.
 */
+ (instancetype)__contactWithB2Contact:(b2Contact *)b2Contact;

/**
 Designated (private) initializer.

 @param b2Contact       The Box2D contact object to wrap.
 @param isModifiable    Whether the contact can be modified. Used by the presolver.
 */
+ (instancetype)__contactWithB2Contact:(b2Contact *)b2Contact isModifiable:(BOOL)isModifiable;

/**
 Ends direct modifiability of the b2Contact object.
 */
- (void)__endModifiability;

@end
