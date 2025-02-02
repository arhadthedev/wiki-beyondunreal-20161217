﻿/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class UTLinkedReplicationInfo extends ReplicationInfo
	abstract
	native
	nativereplication;

var UTLinkedReplicationInfo NextReplicationInfo;



replication
{
	// Variables the server should send to the client.
	if ( bNetInitial && (Role==ROLE_Authority) )
		NextReplicationInfo;
}

defaultproperties
{
	NetUpdateFrequency=1
}
