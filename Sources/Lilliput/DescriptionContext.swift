// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 28/02/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

enum DescriptionContext: String {
    case contained                              /// description when being listed as content of something else
    case containedRecursively                   /// description when being listed as content of content
    case container                              /// alternate description when viewed from another container (eg of a room when sitting in a chair)
    case contentEmpty                           /// additional description when something is empty
    case contentPrefix                          /// prefix for the contents of something (eg "The desk contains")
    case detailed                               /// detailed description (shown when examined/searched)
    case definite                               /// brief description with definite article (eg "the pen")
    case excessMass                             /// player is carrying too much weight
    case excessVolume                           /// player is carrying too much volume
    case exit                                   /// description of a portal used when listing exits
    case indefinite                             /// brief description with indefinite article (eg "a pen")
    case load                                   /// shown when the object is loaded
    case location                               /// description of a location
    case locationContent                        /// description of a location's content
    case locationSuffix = "location.suffix"
    case locked                                 /// description when locked
    case none
    case outside                                /// prefix for describing view from a location (eg when sitting in a chair)
    case play                                   /// shown when the object is played
    case push                                   /// shown when the object is pushed
    case tooHeavy                               /// object is too heavy to carry
    case tooLarge                               /// object is too large
    case unlocks                                /// description of a thing needed to unlock something
    case use                                    /// shown when the object is used
}
