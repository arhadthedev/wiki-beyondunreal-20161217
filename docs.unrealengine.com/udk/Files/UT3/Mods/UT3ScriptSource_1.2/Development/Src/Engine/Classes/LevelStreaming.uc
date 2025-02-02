﻿/**
 * LevelStreaming
 *
 * Abstract base class of container object encapsulating data required for streaming and providing 
 * interface for when a level should be streamed in and out of memory.
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class LevelStreaming extends Object
	abstract
	editinlinenew
	native;

/** Name of the level package name used for loading.																		*/
var() editconst const name							PackageName;

/** Pointer to Level object if currently loaded/ streamed in.																*/
var transient const	level							LoadedLevel;

/** Offset applied to actors after loading.																					*/
var() const			vector							Offset;

/** Current/ old offset required for changing the offset at runtime, e.g. in the Editor.									*/
var const			vector							OldOffset;	

/** Whether the level is currently visible/ associated with the world														*/
var const transient bool							bIsVisible;

/** Whether we currently have a load request pending.																		*/
var const transient	bool							bHasLoadRequestPending;

/** Whether we currently have an unload request pending.																	*/
var const transient bool							bHasUnloadRequestPending;

/** Whether this level should be visible in the Editor																		*/
var() const			bool							bShouldBeVisibleInEditor;

/** Whether this level's bounding box should be visible in the Editor.														*/
var const			bool							bBoundingBoxVisible;

/** Whether this level is locked; that is, its actors are read-only.														*/
var() const			bool							bLocked;

/** Whether this level is fully static - if it is, then assumptions can be made about it, ie it doesn't need to be reloaded since nothing could have changed */
var() const			bool							bIsFullyStatic;

/** Whether the level should be loaded																						*/
var	const transient bool bShouldBeLoaded;

/** Whether the level should be visible if it is loaded																		*/
var const transient bool bShouldBeVisible;

/** Whether we want to force a blocking load																				*/
var transient		bool							bShouldBlockOnLoad;

/** The level's color; used to make the level easily identifiable in the level browser, for actor level visulization, etc.	*/
var() const			color							DrawColor;

/** The level streaming volumes bound to this level.																		*/
var() const editconst array<LevelStreamingVolume>	EditorStreamingVolumes;

/** Cooldown time in seconds between volume-based unload requests.  Used in preventing spurious unload requests.			*/
var() float											MinTimeBetweenVolumeUnloadRequests;

/** Time of last volume unload request.  Used in preventing spurious unload requests.										*/
var const transient float							LastVolumeUnloadRequestTime;

/** Whether this level streaming object's level should be unloaded and the object be removed from the level list.			*/
var const transient bool							bIsRequestingUnloadAndRemoval;



defaultproperties
{
	bShouldBeVisibleInEditor=TRUE
	DrawColor=(R=255,G=255,B=255,A=255)

	MinTimeBetweenVolumeUnloadRequests=2.0
}
