﻿/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class ActorFactoryPhysicsAsset extends ActorFactory
	config(Editor)
	collapsecategories
	hidecategories(Object)
	native;

var()	PhysicsAsset		PhysicsAsset;
var()	SkeletalMesh		SkeletalMesh;

var()	bool				bStartAwake;
var()	bool				bDamageAppliesImpulse;
var()	bool				bNotifyRigidBodyCollision;
var()	vector				InitialVelocity;
var()	vector				DrawScale3D;

/** Try and use physics hardware for this spawned object. */
var()	bool	bUseCompartment;

/** If false, primitive does not cast dynamic shadows. */
var()	bool	bCastDynamicShadow;



defaultproperties
{
	MenuName="Add PhysicsAsset"
	NewActorClass=class'Engine.KAsset'
	GameplayActorClass=class'Engine.KAssetSpawnable'

	DrawScale3D=(X=1,Y=1,Z=1)
	bStartAwake=true
	bDamageAppliesImpulse=true
	bCastDynamicShadow=true
}
