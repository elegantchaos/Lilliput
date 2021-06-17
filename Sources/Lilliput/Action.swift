// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 27/05/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

struct Action {
    let data: [String:Any]
    
    init(data: [String:Any]) {
        self.data = data
    }
    
    func object(fromKey key: String, in context: EventContext) -> Object? {
        guard let id = data[asString: key], let object = context.engine.objects[id] else { return nil }
        return object
    }
    
    func run(in context: EventContext) {
        if let output = data[asString: "output"] {
            context.engine.output(output)
        } else if let target = data[asString: "move"] {
            handleMove(target: target, in: context)
        } else if let dialog = data[asString: "speak"] {
            handleSpeak(dialog, in: context)
        } else if let key = data[asString: "set"], let value = data["to"], let id = data[asString: "of"], let object = context.engine.objects[id] {
            object.setProperty(withKey: key, to: value)
        } else if let subject = object(fromKey: "startTalking", in: context) {
            handleStartTalking(to: subject, in: context)
        } else if let subject = object(fromKey: "stopTalking", in: context) {
            handleStopTalking(to: subject, in: context)
        }
    }
    
    func handleMove(target targetName: String, in context: EventContext) {
        let target: Object?
        let locationName: String

        if let destination = data[asString: "to"] {
            // we were supplied a target and a destination
            target = context.engine.objects[targetName]
            locationName = destination
        } else {
            // we were just supplied a destination
            // so the target defaults to the player
            target = context.player
            locationName = targetName
        }
        
        guard let location = context.engine.objects[locationName] else {
            context.engine.warning("Missing location for move command: \(locationName)")
            return
        }
        
        guard let object = target else {
            context.engine.warning("Missing target for move command: \(targetName)")
            return
        }
        
        if let inVehicle = data[asBool: "inVehicle"], inVehicle, let vehicle = object.location {
            vehicle.move(to: location)
            object.move(to: location)
        } else {
            object.move(to: location, quiet: true)
        }

    }
    
    func handleSpeak(_ sentenceID: String, in context: EventContext) {
        let speaker = context.receiver
        if let sentence = speaker.definition.dialogue?.sentence(withID: sentenceID) {
            sentence.speak(as: speaker, engine: context.engine)
        }
    }
 
    func handleStartTalking(to subject: Object, in context: EventContext) {
        context.receiver.joinConversation(with: [context.player])
    }

    func handleStopTalking(to subject: Object, in context: EventContext) {
        context.receiver.leaveConversation(with: [context.player])
    }

}
