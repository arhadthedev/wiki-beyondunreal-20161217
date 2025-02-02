﻿/**
 * Abstract base class for UI events.
 * A UIEvent is some event that a widget can respond to.  It could be an input event such as a button press, or a system
 * event such as receiving data from a remote system.  UIEvents are generally not bound to a particular type of widget;
 * programmers choose which events are available to widgets, and artists decide which events to implement.
 *
 * Features:
 *	Able to execute multiple actions when the event is called.
 *	Able to operate on multiple widgets simultaneously.
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class UIEvent extends SequenceEvent
	native(UISequence)
	abstract
	placeable;

/** the widget that contains this event */
var	noimport	UIScreenObject	EventOwner;

/** the object that initiated this event; specific to each event */
var				Object			EventActivator;

/** the name that is displayed for this event in the list of widget events in the editor */
// superseced by SequenceObject.ObjName
//var	localized	string			DisplayName;

/**
 * a short description of what this event does - displayed as a tooltip in the editor when the user hovers over this
 * event in the editor
 */
var	localized	string			Description;

/**
 * Indicates whether this event should be added to widget sequences.  Used for special-case handling of certain types
 * of events.
 */
var	bool						bShouldRegisterEvent;

/**
 * Indicates whether this activation of this event type should be propagated up the parent chain.
 */
var	bool						bPropagateEvent;




/* == Delegates == */
/**
 * Allows script-only child classes or other objects to include additional logic for determining whether this event is eligible for activation.
 *
 * @param	ControllerIndex			the index of the player that activated this event
 * @param	InEventOwner			the widget that owns this UIEvent
 * @param	InEventActivator		an optional object that can be used for various purposes in UIEvents;  typically the widget
 *									that triggered the event activation.
 * @param	bActivateImmediately	TRUE if the caller wishes to perform immediate activation.
 * @param	IndicesToActivate		indexes of the elements [into the Output array] that are going to be activated.  If empty,
 *									all output links will be activated
 *
 * @return	TRUE if this event can be activated
 */
delegate bool AllowEventActivation( int ControllerIndex, UIScreenObject InEventOwner, Object InEventActivator, bool bActivateImmediately, out const array<int> IndicesToActivate );

/* == Natives == */
/**
 * Returns the widget that contains this UIEvent.
 */
native final function UIScreenObject GetOwner() const;

/**
 * Returns the scene that contains this UIEvent.
 */
native final function UIScene GetOwnerScene() const;

/**
 * Determines whether this UIAction can be activated.
 *
 * @param	ControllerIndex			the index of the player that activated this event
 * @param	InEventOwner			the widget that contains this UIEvent
 * @param	InEventActivator		an optional object that can be used for various purposes in UIEvents
 * @param	bActivateImmediately	specify true to indicate that we'd like to know whether this event can be activated immediately
 * @param	IndicesToActivate		Indexes into this UIEvent's Output array to activate.  If not specified, all output links
 *									will be activated
 *
 * @return	TRUE if this event can be activated
 *
 * @note: noexport so that the native function header can take a TArray<INT> pointer as the last parameter
 */
native final noexport function bool CanBeActivated( int ControllerIndex, UIScreenObject InEventOwner, optional Object InEventActivator, optional bool bActivateImmediately, optional out const array<int> IndicesToActivate );

/**
 * Activates this event if CanBeActivated returns TRUE.
 *
 * @param	ControllerIndex			the index of the player that activated this event
 * @param	InEventOwner			the widget that contains this UIEvent
 * @param	InEventActivator		an optional object that can be used for various purposes in UIEvents
 * @param	bActivateImmediately	if TRUE, the event will be activated immediately, rather than deferring activation until the next tick
 * @param	IndicesToActivate		Indexes into this UIEvent's Output array to activate.  If not specified, all output links
 *									will be activated
 *
 * @return	TRUE if this event was successfully activated
 *
 * @note: noexport so that the native function header can take a TArray<INT> pointer as the last parameter
 */
native final noexport function bool ConditionalActivateUIEvent( int ControllerIndex, UIScreenObject InEventOwner, optional Object InEventActivator, optional bool bActivateImmediately, optional out const array<int> IndicesToActivate );

/**
 * Activates this UIEvent, adding it the list of active sequence operations in the owning widget's EventProvider
 *
 * @param	ControllerIndex			the index of the player that activated this event
 * @param	InEventOwner			the widget that contains this UIEvent
 * @param	InEventActivator		an optional object that can be used for various purposes in UIEvents
 * @param	bActivateImmediately	if TRUE, the event will be activated immediately, rather than deferring activation until the next tick
 * @param	IndicesToActivate		Indexes into this UIEvent's Output array to activate.  If not specified, all output links
 *									will be activated
 *
 * @return	TRUE if this event was successfully activated
 *
 * @note: noexport so that the native function header can take a TArray<INT> pointer as the last parameter
 */
native final noexport function bool ActivateUIEvent( int ControllerIndex, UIScreenObject InEventOwner, optional Object InEventActivator, optional bool bActivateImmediately, optional out const array<int> IndicesToActivate );

/* == Events == */
/**
 * Determines whether this class should be displayed in the list of available ops in the level kismet editor.
 *
 * @return	TRUE if this sequence object should be available for use in the level kismet editor
 */
event bool IsValidLevelSequenceObject()
{
	return false;
}

/**
 * Determines whether this class should be displayed in the list of available ops in the UI's kismet editor.
 *
 * @param	TargetObject	the widget that this SequenceObject would be attached to.
 *
 * @return	TRUE if this sequence object should be available for use in the UI kismet editor
 */
event bool IsValidUISequenceObject( optional UIScreenObject TargetObject )
{
	return true;
}

/**
 * Allows events to override the default behavior of not instancing event templates during the game (@see UIComp_Event::InstanceEventTemplates); by default, events templates
 * declared in widget defaultproperties are only instanced if the template definition contains linked ops.  If your event class performs some other actions which affect the game
 * when it's activated, you can use this function to force the UI to instance this event for widgets created at runtime in the game.
 *
 * @return	return TRUE to force the UI to always instance event templates of this event type, even if there are no linked ops.
 */
event bool ShouldAlwaysInstance()
{
	return false;
}

/* == UnrealScript == */

DefaultProperties
{
	ObjClassVersion=2

	ObjCategory="UI"
	MaxTriggerCount=0
	bShouldRegisterEvent=true
	bClientSideOnly=true

	bPropagateEvent=true

	VariableLinks(0)=(ExpectedType=class'SeqVar_Object',LinkDesc="Activator",bWriteable=true)

	// the index for the player that activated this event
	VariableLinks(1)=(ExpectedType=class'SeqVar_Int',LinkDesc="Player Index",bWriteable=true,bHidden=true)

	// the gamepad id for the player that activated this event
	VariableLinks.Add((ExpectedType=class'SeqVar_Int',LinkDesc="Gamepad Id",bWriteable=true,bHidden=true))
}
