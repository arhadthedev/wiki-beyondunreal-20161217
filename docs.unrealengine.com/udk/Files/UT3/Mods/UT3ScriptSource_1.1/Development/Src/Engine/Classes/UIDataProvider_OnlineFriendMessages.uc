﻿/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

/**
 * This class is responsible for retrieving the friends list from the online
 * subsystem and populating the UI with that data.
 */
class UIDataProvider_OnlineFriendMessages extends UIDataProvider_OnlinePlayerDataBase
	native(inherit)
	implements(UIListElementCellProvider)
	dependson(OnlineSubsystem)
	transient;

/** Gets a copy of the friends messages from the online subsystem */
var array<OnlineFriendMessage> Messages;

/** The column name to display in the UI */
var localized string SendingPlayerNameCol;

/** The column name to display in the UI */
var localized string bIsFriendInviteCol;

/** The column name to display in the UI */
var localized string bWasAcceptedCol;

/** The column name to display in the UI */
var localized string bWasDeniedCol;

/** The column name to display in the UI */
var localized string MessageCol;

/** The person that sent the last invite */
var string LastInviteFrom;



/**
 * Binds the player to this provider. Starts the async friends list gathering
 *
 * @param InPlayer the player that we are retrieving friends for
 */
event OnRegister(LocalPlayer InPlayer)
{
	local OnlineSubsystem OnlineSub;
	local OnlinePlayerInterface PlayerInterface;

	Super.OnRegister(InPlayer);
	// If the player is None, we are in the editor
	if (Player != None)
	{
		// Figure out if we have an online subsystem registered
		OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
		if (OnlineSub != None)
		{
			// Grab the player interface to verify the subsystem supports it
			PlayerInterface = OnlineSub.PlayerInterface;
			if (PlayerInterface != None)
			{
				// Register that we are interested in any sign in change for this player
				PlayerInterface.AddLoginChangeDelegate(OnLoginChange,Player.ControllerId);
				// Add the callbacks for messages
				PlayerInterface.AddFriendMessageReceivedDelegate(Player.ControllerId,OnFriendMessageReceived);
				PlayerInterface.AddFriendInviteReceivedDelegate(Player.ControllerId,OnFriendInviteReceived);
				PlayerInterface.AddReceivedGameInviteDelegate(Player.ControllerId,OnGameInviteReceived);
				// Read any messages that are waiting
				ReadMessages();
			}
		}
	}
}

/**
 * Clears our delegate for getting login change notifications
 */
event OnUnregister()
{
	local OnlineSubsystem OnlineSub;
	local OnlinePlayerInterface PlayerInterface;

	// Figure out if we have an online subsystem registered
	OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
	if (OnlineSub != None)
	{
		// Grab the player interface to verify the subsystem supports it
		PlayerInterface = OnlineSub.PlayerInterface;
		if (PlayerInterface != None)
		{
			// Clear our callback function per player
			PlayerInterface.ClearLoginChangeDelegate(OnLoginChange,Player.ControllerId);
			// Clear the callbacks for messages
			PlayerInterface.ClearFriendMessageReceivedDelegate(Player.ControllerId,OnFriendMessageReceived);
			PlayerInterface.ClearFriendInviteReceivedDelegate(Player.ControllerId,OnFriendInviteReceived);
			PlayerInterface.ClearReceivedGameInviteDelegate(Player.ControllerId,OnGameInviteReceived);
		}
	}
	Super.OnUnregister();
}

/** Copies the messages from the subsystem */
function ReadMessages()
{
	local OnlineSubsystem OnlineSub;
	local OnlinePlayerInterface PlayerInterface;

	Messages.Length = 0;
	// Figure out if we have an online subsystem registered
	OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
	if (OnlineSub != None)
	{
		// Grab the player interface to verify the subsystem supports it
		PlayerInterface = OnlineSub.PlayerInterface;
		if (PlayerInterface != None)
		{
			// Make a copy of the friends messages for the UI
			PlayerInterface.GetFriendMessages(Player.ControllerId,Messages);
		}
	}
	// Notify any subscribers that we have new data
	NotifyPropertyChanged();
}

/**
 * Called when a friend invite arrives for a local player
 *
 * @param LocalUserNum the user that is receiving the invite
 * @param RequestingPlayer the player sending the friend request
 * @param RequestingNick the nick of the player sending the friend request
 * @param Message the message to display to the recipient
 */
function OnFriendInviteReceived(byte LocalUserNum,UniqueNetId RequestingPlayer,string RequestingNick,string Message)
{
	ReadMessages();
}

/**
 * Handles the notification that a friend message was received
 *
 * @param LocalUserNum the user that is receiving the message
 * @param SendingPlayer the player sending the message 
 * @param SendingNick the nick of the player sending the message
 * @param Message the message to display to the recipient
 */
function OnFriendMessageReceived(byte LocalUserNum,UniqueNetId SendingPlayer,string SendingNick,string Message)
{
	ReadMessages();
}

/**
 * Executes a refetching of the friends data when the login for this player
 * changes
 */
function OnLoginChange()
{
	ReadMessages();
}

/**
 * Handles the notification that a game invite has arrived
 *
 * @param LocalUserNum the user that is receiving the invite
 * @param InviterName the nick name of the person sending the invite
 */
function OnGameInviteReceived(byte LocalUserNum,string InviterName)
{
	LastInviteFrom = InviterName;
	ReadMessages();
}