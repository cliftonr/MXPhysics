#import "MXBox2DInternal.h"

@protocol MXContactListenerDelegate;

#pragma mark -
/**
 The contact listener forwards contact events to its delegate.
 */
class MXContactListener : public b2ContactListener {
public:
    MXContactListener();

    /**
     Retrieve the delegate that handles contact events.

     @return The object which serves as the delegate.
     */
    id<MXContactListenerDelegate> GetDelegate() const;

    /**
     Set the delegate, which handles contact events.

     @param delegate The object that shall serve as the contact delegate.
     */
    void SetDelegate(id<MXContactListenerDelegate> delegate);

private:
    void BeginContact(b2Contact *b2Contact);
    void EndContact(b2Contact *b2Contact);
    void PreSolve(b2Contact *b2Contact, const b2Manifold *oldManifold);

    id<MXContactListenerDelegate> __weak _delegate;
    struct {
        unsigned int respondsToContactBegan:1;
        unsigned int respondsToContactEnded:1;
        unsigned int respondsToContactPreSolve:1;
    } _delegateFlags;
};
