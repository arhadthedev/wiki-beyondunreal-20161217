﻿/**
 * Specialization type of sequence used to store the events associated with a single widget.
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class UISequence extends Sequence
	native(UISequence)
	implements(UIEventContainer);



/**
 * List of UIEvent objects contained by this UISequence.
 */
var	private{private}	const	transient	noimport	init	array<UIEvent>	UIEvents;

/**
 * Return the UIScreenObject that owns this sequence.
 */
native final function UIScreenObject GetOwner() const;

/* == UIEventContainer interface == */
/**
 * Retrieves the UIEvents contained by this container.
 *
 * @param	out_Events	will be filled with the UIEvent instances stored in by this container
 * @param	LimitClass	if specified, only events of the specified class (or child class) will be added to the array
 */
native final function GetUIEvents( out array<UIEvent> out_Events, optional class<UIEvent> LimitClass );

/**
 * Adds a new SequenceObject to this containers's list of ops
 *
 * @param	NewObj		the sequence object to add.
 * @param	bRecurse	if TRUE, recursively add any sequence objects attached to this one
 *
 * @return	TRUE if the object was successfully added to the sequence.
 */
native final noexport function bool AddSequenceObject( SequenceObject NewObj, optional bool bRecurse );

/**
 * Removes the specified SequenceObject from this container's list of ops.
 *
 * @param	ObjectToRemove	the sequence object to remove
 */
native final function RemoveSequenceObject( SequenceObject ObjectToRemove );

/**
 * Removes the specified SequenceObjects from this container's list of ops.
 *
 * @param	ObjectsToRemove		the objects to remove from this sequence
 */
native final function RemoveSequenceObjects( const out array<SequenceObject> ObjectsToRemove );

DefaultProperties
{
	ObjName="Widget Events"

	ObjPosX=904
	ObjPosY=64
}
