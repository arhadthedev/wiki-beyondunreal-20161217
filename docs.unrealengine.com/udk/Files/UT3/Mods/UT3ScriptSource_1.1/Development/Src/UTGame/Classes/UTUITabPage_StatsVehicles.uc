﻿/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 *
 * Tab page for a user's vehicle stats.
 */
class UTUITabPage_StatsVehicles extends UTUITabPage_StatsPage
	placeable;

/** Post initialization event - Setup widget delegates.*/
event PostInitialize()
{
	Super.PostInitialize();

	// Set the button tab caption.
	SetDataStoreBinding("<Strings:UTGameUI.Stats.Vehicles>");
}

/** Starts the stats read for this page. */
function ReadStats()
{
	local OnlineSubsystem OnlineSub;
	local OnlineStatsRead ReadObj;

	// Get the read object we will use
	ReadObj = StatsDataStore.GetReadObjectFromType(UTSR_Vehicles);

	if(ReadObj != None)
	{
		OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
		if ( OnlineSub != None )
		{
			OnlineSub.StatsInterface.AddReadOnlineStatsCompleteDelegate(OnStatsReadComplete);
		}

		RefreshingLabel.SetVisibility(true);
		StatsDataStore.AddToReadQueue(ReadObj);
	}
}

defaultproperties
{

}