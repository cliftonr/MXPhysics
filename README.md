# MXPhysics

MXPhysics is an Objective-C wrapper around Box2D.

## Requirements
- Objective-C, Xcode 8

## Installation

#### With [CocoaPods](https://github.com/CocoaPods/CocoaPods)

```
use_frameworks!
pod 'MXPhysics', :git => 'https://github.com/cliftonr/MXPhysics.git'
```

## Overview

Though the underlying Box2D functionality is unchanged, MXPhysics attempts to improve the interface for 
system-component based architectures by reducing the apparent coupling between objects.

- Worlds, bodies and fixtures may be created independently of one another.
- After initialization, fixtures may be associated with bodies, and bodies with worlds.
- Even during a time-step, fixtures may be dissociated from bodies, and bodies from worlds.
- Collisions are handled by a delegate conforming to `MXContactListenerDelegate`.
- Length is measured in screen points rather than Box2D meters. Angles are in degrees, rather than Box2D radians. Mass is still measured in kilograms.
- MXPhysics is not yet a complete wrapper. Feel free to submit a feature request or PR.

## License

MXPhysics is maintained by [Clifton Roberts](mailto:clifton.roberts@me.com) and released
under the MIT license. See LICENSE for details.

MXPhysics redistributes the original, unaltered [Box2D library](http://www.box2d.org),
which is authored and copyright (c) by [Erin Catto](https://github.com/erincatto).
