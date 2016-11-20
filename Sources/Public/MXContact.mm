#import <UIKit/UIKit.h>

#import "MXContact.h"
#import "MXContact+Private.h"
#import "MXBox2DInternal.h"

#pragma mark -
@interface MXContact ()

@property (nonatomic, assign) b2Contact *b2Contact;
@property (nonatomic, assign, getter = isModifiable) BOOL modifiable;

@property (nonatomic, strong, readwrite) MXFixture *fixtureA;
@property (nonatomic, strong, readwrite) MXFixture *fixtureB;
@property (nonatomic, assign, getter = isTouching, readwrite) BOOL touching;

- (void)__performContactModification:(nonnull void (^)(b2Contact *contact))contactModification;

@end

#pragma mark -
@implementation MXContact

- (void)setEnabled:(BOOL)enabled {
    [self __performContactModification:^(b2Contact *contact) {
        if (_enabled != enabled) {
            _enabled = enabled;
            contact->SetEnabled(_enabled);
        }
    }];
}

- (void)setModifiable:(BOOL)modifiable {
    // Modifiability may only be turned off.
    if (modifiable || _modifiable == modifiable) {
        return;
    }

    _modifiable = false;
    self.b2Contact = NULL;
}

- (CGPoint)center {
    NSArray *points = self.intersectionPoints;

    if (points.count == 1) {
        return [[points lastObject] CGPointValue];
    } else if (points.count == 2) {
        CGPoint p1 = [[points objectAtIndex:0] CGPointValue];
        CGPoint p2 = [[points objectAtIndex:1] CGPointValue];
        // (p1 + p2) / 2
        return CGPointMake((p1.x + p2.x) * 0.5, (p1.y + p2.y) * 0.5);
    } else {
        return CGPointZero;
    }
}

#pragma mark - Private methods

- (void)__performContactModification:(void (^)(b2Contact *contact))contactModification {
    if (!self.isModifiable) {
        return;
    }

    NSAssert(NULL != self.b2Contact,
             @"A b2Contact reference must exist while contact is modifiable.");

    contactModification(self.b2Contact);
}

@end

#pragma mark -
@implementation MXContact (Private)

+ (instancetype)__contactWithB2Contact:(b2Contact *)b2Contact isModifiable:(BOOL)isModifiable {
    return [[self alloc] __initWithB2Contact:b2Contact isModifiable:isModifiable];
}

+ (instancetype)__contactWithB2Contact:(b2Contact *)b2Contact {
    return [[self alloc] __initWithB2Contact:b2Contact isModifiable:FALSE];
}

- (instancetype)__initWithB2Contact:(b2Contact *)b2Contact isModifiable:(BOOL)isModifiable {
    NSParameterAssert(b2Contact);

    if (self = [super init]) {
        _touching = b2Contact->IsTouching();
        _fixtureA = (__bridge id)b2Contact->GetFixtureA()->GetUserData();
        _fixtureB = (__bridge id)b2Contact->GetFixtureB()->GetUserData();
        NSAssert(_fixtureA && _fixtureB, @"Contact had invalid fixture data!");
        
        // Extract contact information.
        b2WorldManifold worldManifold;
        b2Contact->GetWorldManifold(&worldManifold);
        NSMutableArray *points = [NSMutableArray arrayWithCapacity:b2Contact->GetManifold()->pointCount];
        for (int i = 0; i < b2Contact->GetManifold()->pointCount; i++) {
            CGPoint p = CGPointFromB2Vec2(worldManifold.points[i]);
            [points addObject:[NSValue valueWithCGPoint:p]];
        }

        NSAssert1(points.count >= 0 && points.count <= 2,
                  @"Unexpected point count: %lu", (unsigned long)points.count);

        _intersectionPoints = [points copy];
        _normal = CGPointFromB2Vec2(worldManifold.normal);

        // Contacts are enabled by default.
        _enabled = TRUE;
        
        // If modifiable, store reference to b2Contact until modifications are disabled.
        _modifiable = isModifiable;
        _b2Contact = _modifiable ? b2Contact : NULL;

        NSAssert(_modifiable == (NULL != self.b2Contact),
                 @"A b2Contact reference must exist, and may only exist, while contact is modifiable.");
    }
    
    return self;
}

- (void)__endModifiability {
    [self setModifiable:FALSE];
}

@end
