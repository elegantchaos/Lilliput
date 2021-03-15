# Lilliput

Lilliput is a Swift engine for old-school text adventures.

The basic archicture includes:

- objects
- events
- commands
- behaviours

Every entity and location in the game is represented in the engine as a game object. 

## Objects

The basic properties of each object are described by the JSON files that comprise the game definition.

Each object has a unique id, and should have a record with a corresponding id in one of the JSON files. 

This record describes all the static properties of the object, including custom descriptions printed out to the user in response to various commands.

## Behaviours

The optional `traits` property of an object description contains a list of behaviours to attach to the object.

Each behaviour is backed by a Behaviour class. This can add custom properties and storage to the object, custom logic, and can register one or more `Commands` for the object.

## Commands

Commands are attached to objects, and invoked by the parser in response to the user typing some text.

Precisely which command is invoked by any given user input is determined by which objects the user can see - which in turn depends on what they are carrying and what their current location is.

Commands and Behaviours together are what give the user the ability to do things to objects.

Some commands are attached to the player object itself. These handle global things like moving, which are always applicable.

## Events

As the user moves around and does things, they generate certain events.

Other game objects can respond to these events. In particular, other non-player character objects may do things, or speak dialogue to the player, in response to certain events.



# Scene Description

When the user enters a location (or types "look" without specifying an object), the description of the location is printed.

For many locations, this will just be the `detailed` description defined for the location, a list of objects that are present, and a list of exits.

However, as well as the `detailed` description, any objects that are present can contribute to this output, instead of (or as well as) appearing in the list of objects that you can see.

Objects can make this contribution every time, or optionally depending on whether the user has examined them.

This allows a location's description to include a hint about an object at first. 

When the user examines the object, this hint can go away, but some other text might show instead, giving more or different detail that the user now knows. If the user ever removes the object from the location, the description will be removed too.

All of this allows the description of a location to vary subtly depending on which objects are present, without having to 'bake in' descriptions of things that might change over time.  

Objects in the scene can also optionally have their own content listed as part of the scene description, either always, or once they have been examined. 

This is useful for things like shelves, desks, cupboards etc. We often want to treat these as separate objects, so that they can be locked/unlock, opened/closed, or have hidden items in them that only become apparent after being searched or examined. 

In these cases we don't initially want the item's contents to be part of the scene description, as it makes life too easy / reveals things that the user is supposed to discover. Once the user has revealed them though, it is convenient for them to be listed alongside the direct room contents. This saves the user having to repeatedly re-examine container objects to remember what is in them.


## Description Algorithm

If the location has a `detailed` description, this is printed first.

Next, objects directly contained in the location get a chance to add something.

If the object has a `location` description, this is printed.

If the object has a `location-examined` or `location-not-examined` description, one of them is printed - the choice depends on whether the object has ever been examined.

Next 'You can see' is printed, along with the `brief` description of any object that didn't output custom descriptions, unless it has the `skipBrief` flag set.

Finally, the content of each of these objects is potentially printed.

An object's content is printed if:
- it contains something
- its `showContentWhen` mode is set to `always`
- its `showContentWhen` property is set to another value, and the object has a flag of that value set to true; examples of flags used in this way include `examined`, and `open`.


# Traits / Behaviours

## Movable

An object is movable if it has the `movable` trait.

This enables the `take` and `drop` actions.

## Openable

An object can be opened if it has the `openable` trait.

This enables the `open` and `close` actions.

## Lockable

An object can be locked/unlocked if it has the `lockable` trait.

This enables the `lock` and `unlock` actions.

## Location

An object with the `location` trait is a location.

It can have one or more `exits`.

# Portals

The exits for simple locations are described by a simple list of key/value pairs, giving the direction of the exit, and the id of the location it leads to.

Sometimes though, an exit needs to be conditional. It may be closed, or locked, or lead to different locations at different times.

This behaviour is implemented by portal objects. A portal is defined separately from the locations that it links, and is attached to their exits during initialisation.

A portal can define a set of requirements that must be met before the exit(s) can be traversed. Typically this might be something like possessing a certain key.

# NPCs and Dialogue

Game objects can include other "people" (they don't actually have to be people, they might be machines or other entities that the player can interact with).

Any person object can define a set of dialog.

This comprises of one or more sentences that will be triggered in response to events and other conditions.

When the player is present in the same location as an object with dialog, the conditions are evaluated, and the first matching sentence is output.

Sentences can also define responses, which are presented as a list of options to the user. The user can pick a response to continue the conversation (or ignore them all and type another command to just continue with the game).



