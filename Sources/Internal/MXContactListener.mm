#import "MXContactListener.h"
#import "MXContact+Private.h"

#pragma mark - Public

MXContactListener::MXContactListener() {
    _delegateFlags.respondsToContactBegan =
    _delegateFlags.respondsToContactEnded =
    _delegateFlags.respondsToContactPreSolve = 0;
}

id<MXContactListenerDelegate> MXContactListener::GetDelegate() const {
    return _delegate;
}

void MXContactListener::SetDelegate(id<MXContactListenerDelegate> delegate) {
    if (_delegate != delegate) {
        _delegate = delegate;
        _delegateFlags.respondsToContactBegan = [_delegate respondsToSelector:@selector(contactBegan:)];
        _delegateFlags.respondsToContactEnded = [_delegate respondsToSelector:@selector(contactEnded:)];
        _delegateFlags.respondsToContactPreSolve = [_delegate respondsToSelector:@selector(contactPreSolve:)];
    }
}

#pragma mark - Private

void MXContactListener::BeginContact(b2Contact *b2Contact) {
    if (_delegateFlags.respondsToContactBegan) {
        MXContact *contact = [MXContact __contactWithB2Contact:b2Contact];
        [_delegate contactBegan:contact];
    }
}

void MXContactListener::EndContact(b2Contact *b2Contact) {
    if (_delegateFlags.respondsToContactEnded) {
        MXContact *contact = [MXContact __contactWithB2Contact:b2Contact];
        [_delegate contactEnded:contact];
    }
}

void MXContactListener::PreSolve(b2Contact *b2Contact, const b2Manifold *oldManifold) {
    if (_delegateFlags.respondsToContactPreSolve) {
        MXContact *contact = [MXContact __contactWithB2Contact:b2Contact isModifiable:TRUE];
        [_delegate contactPreSolve:contact];
        [contact __endModifiability];
    }
}
