﻿/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class CoverMeshComponent extends StaticMeshComponent
	native(AI);

;

struct native CoverMeshes
{
	var StaticMesh Base;
	var StaticMesh LeanLeft, LeanRight;
	var StaticMesh Climb, Mantle;
	var StaticMesh SlipLeft, SlipRight;
	var StaticMesh SwatLeft, SwatRight;
	var StaticMesh PopUp;
};
var editoronly array<CoverMeshes> Meshes;

/** Base offset applied to all meshes */
var vector LocationOffset;

var editoronly StaticMesh AutoAdjustOn, AutoAdjustOff;
var editoronly StaticMesh Disabled;

defaultproperties
{
	HiddenGame=true
	AlwaysLoadOnServer=FALSE
	AlwaysLoadOnClient=FALSE
	CollideActors=FALSE
	BlockActors=FALSE
	BlockZeroExtent=FALSE
	BlockNonZeroExtent=FALSE
	BlockRigidBody=FALSE
	bAcceptsDecals=FALSE
	bAcceptsLights=FALSE
	CastShadow=FALSE

	StaticMesh=StaticMesh'NodeBuddies.3D_Icons.NodeBuddy__BASE_TALL'
	LocationOffset=(X=0,Y=0,Z=-60)

	
	Meshes(CT_None)=(Base=StaticMesh'NodeBuddies.3D_Icons.NodeBuddy__BASE_TALL')
	Meshes(CT_Standing)={(
						  Base=StaticMesh'NodeBuddies.3D_Icons.NodeBuddy__BASE_TALL',
						  LeanLeft=StaticMesh'NodeBuddies.3D_Icons.NodeBuddy_LeanLeftS',
						  LeanRight=StaticMesh'NodeBuddies.3D_Icons.NodeBuddy_LeanRightS',
						  SlipLeft=StaticMesh'NodeBuddies.3D_Icons.NodeBuddy_CoverSlipLeft',
						  SlipRight=StaticMesh'NodeBuddies.3D_Icons.NodeBuddy_CoverSlipRight',
						  SwatLeft=StaticMesh'NodeBuddies.3D_Icons.NodeBuddy_SwatLeft',
						  SwatRight=StaticMesh'NodeBuddies.3D_Icons.NodeBuddy_SwatRight',
						)}
	Meshes(CT_MidLevel)={(
						  Base=StaticMesh'NodeBuddies.3D_Icons.NodeBuddy__BASE_SHORT',
						  LeanLeft=StaticMesh'NodeBuddies.3D_Icons.NodeBuddy_LeanLeftM',
						  LeanRight=StaticMesh'NodeBuddies.3D_Icons.NodeBuddy_LeanRightM',
						  Climb=StaticMesh'NodeBuddies.3D_Icons.NodeBuddy_Climb',
						  Mantle=StaticMesh'NodeBuddies.3D_Icons.NodeBuddy_Mantle',
						  SlipLeft=StaticMesh'NodeBuddies.3D_Icons.NodeBuddy_CoverSlipLeft',
						  SlipRight=StaticMesh'NodeBuddies.3D_Icons.NodeBuddy_CoverSlipRight',
						  SwatLeft=StaticMesh'NodeBuddies.3D_Icons.NodeBuddy_SwatLeft',
						  SwatRight=StaticMesh'NodeBuddies.3D_Icons.NodeBuddy_SwatRight',
						  PopUp=StaticMesh'NodeBuddies.3D_Icons.NodeBuddy_PopUp',
						)}

	AutoAdjustOn=StaticMesh'NodeBuddies.3D_Icons.NodeBuddy_AutoAdjust'
	AutoAdjustOff=StaticMesh'NodeBuddies.3D_Icons.NodeBuddy_AutoAdjustOff'
	Disabled=StaticMesh'NodeBuddies.3D_Icons.NodeBuddy_Enabled'
}
