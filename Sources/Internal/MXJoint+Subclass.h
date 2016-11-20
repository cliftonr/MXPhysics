#import "MXJoint.h"
#import "MXBox2DInternal.h"

#pragma mark -
/**
 Abstract interface implemented by MXJoint subclasses.
 */
@protocol MXJointDefining

/**
 Subclasses must override this method and return a b2JointDef instance with data specific to the subclass.
 Implementations should only set those attributes which do necessarily pertain to the subclass.

 @warning Subclasses are responsible for creating the b2JointDef instance, however they are NOT responsible 
 for destroying it.

 @return A joint definition suitable for the subclass.
 */
+ (b2JointDef *)__constructJointDefinition;

/**
 Update the specified jointDef's attributes with values from the specified joint.

 @param jointDef    The joint definition to update.
 @param joint       The joint which has the latest data that should be transferred to the specified joint
                    definition.
 */
+ (void)__refreshJointDefinition:(b2JointDef *)jointDef withDataFromJoint:(b2Joint *)joint;

@end
