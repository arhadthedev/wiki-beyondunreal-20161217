﻿/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

/**
 * This class is responsible for retrieving the friends list from the online
 * subsystem and populating the UI with that data.
 */
class UIDataProvider_OnlinePlayerDataBase extends UIDataProvider
	native(inherit)
	transient
	abstract;

/** Holds the player that this provider is getting friends for */
var LocalPlayer Player;



/**
 * Binds the player to this provider
 *
 * @param InPlayer the player that is being bound to the provider
 */
event OnRegister(LocalPlayer InPlayer)
{
	Player = InPlayer;
}

/**
 * Tells the provider that the player is no longer valid
 */
event OnUnregister()
{
	Player = None;
}
