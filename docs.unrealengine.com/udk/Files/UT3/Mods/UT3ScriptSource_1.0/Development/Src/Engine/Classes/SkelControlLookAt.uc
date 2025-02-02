﻿class SkelControlLookAt extends SkelControlBase
	native(Anim);
	
/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 *
 *	Controller that rotates a single bone to 'look at' a given target.
 */
 


/** Position in world space that this bone is looking at. */
var(LookAt)		vector				TargetLocation;

/** Reference frame that TargetLocation is defined in. */
var(LookAt)		EBoneControlSpace	TargetLocationSpace;

/** Name of bone used if TargetLocationSpace is BCS_OtherBoneSpace. */
var(LookAt)		name				TargetSpaceBoneName;

/** Axis of the controlled bone that you wish to point at the TargetLocation. */
var(LookAt)		EAxis				LookAtAxis;

/** Whether to invert the LookAtAxis, so it points away from the TargetLocation. */
var(LookAt)		bool				bInvertLookAtAxis;

/** If you want to also define which axis should try to point 'up' (world +Z). */
var(LookAt)		bool				bDefineUpAxis;

/** Axis of bone to point upwards. Cannot be the same as LookAtAxis. */
var(LookAt)		EAxis				UpAxis;

/** Whether to invert the UpAxis, so it points down instead. */
var(LookAt)		bool				bInvertUpAxis;

/** Interpolation speed for TargetLocation to DesiredTargetLocation */
var(LookAt)		float				TargetLocationInterpSpeed;

/** Interpolation target for TargetLocation */
var				vector				DesiredTargetLocation;

/** If true, only allow a certain adjustment from the reference pose of the bone. */
var(Limit)		bool				bEnableLimit;
/** By default limit is based on ref pose of the character */
var(Limit)		bool				bLimitBasedOnRefPose;
/** Interp back to zero strength if limit surpassed */
var(Limit)		bool				bDisableBeyondLimit;
/** Call event to notify owner of limit break */
var(Limit)		bool				bNotifyBeyondLimit;

/** If true, draw a cone in the editor to indicate the maximum allowed movement of the bone. */
var(Limit)		bool				bShowLimit;

/** The maximum rotation applied from the reference pose of the bone, in degrees. */
var(Limit)		float				MaxAngle;

/** Allowed error between the current look direction and the desired look direction. */
var(Limit)		float				DeadZoneAngle;

/** Per rotation axis filtering */
var(Limit)		bool				bAllowRotationX;
var(Limit)		bool				bAllowRotationY;
var(Limit)		bool				bAllowRotationZ;
var(Limit)		EBoneControlSpace	AllowRotationSpace;
var(Limit)		Name				AllowRotationOtherBoneName;

/** LookAtAlpha allows to cancel head look when going beyond boundaries */
var const transient	float	LookAtAlpha;
var const transient float	LookAtAlphaTarget;
var const transient float	LookAtAlphaBlendTimeToGo;

/** internal, used to draw base orientation for limits */
var const transient Vector	LimitLookDir;
/** Internal, base look dir, without skel controller's influence. */
var const transient Vector	BaseLookDir;
/** Internal, base bone position in component space. */
var const transient Vector	BaseBonePos;
/** 
 * Keep track of when the controller was last calculated.
 * We need this to make sure BaseLookDir is accurate, when using CanLookAt().
 */
var const transient float	LastCalcTime;

function SetTargetLocation(Vector NewTargetLocation)
{
	DesiredTargetLocation = NewTargetLocation;

	// If control is not relevant, update TargetLocation right away, with no interpolation.
	if( ControlStrength * LookAtAlpha < 0.00001f )
	{
		TargetLocation = NewTargetLocation;
	}
}

simulated function InterpolateTargetLocation(float DeltaTime)
{
	TargetLocation = VInterpTo(TargetLocation, DesiredTargetLocation, DeltaTime, TargetLocationInterpSpeed);
}

/** 
 * Set LookAtAlpha. 
 * Allows the controller to blend in/out while still being processed.
 * CalculateNewBoneTransforms() is still called when ControllerStength > 0 and LookAtAlpha <= 0
 */
final native function SetLookAtAlpha(float DesiredAlpha, float DesiredBlendTime);

/** 
 * returns TRUE if PointLoc is within cone of vision of look at controller. 
 * This requires the mesh to be rendered, SpaceBases has to be up to date.
 * @param	PointLoc		Point in world space.
 * @param	bDrawDebugInfo	if true, debug information will be drawn on hud.
 */
final native function bool CanLookAtPoint(vector PointLoc, optional bool bDrawDebugInfo, optional bool bDebugUsePersistentLines, optional bool bDebugFlushLinesFirst);

defaultproperties
{
	LookAtAxis=AXIS_X
	UpAxis=AXIS_Z
	bShowLimit=TRUE
	bLimitBasedOnRefPose=TRUE
	TargetLocationInterpSpeed=10.f

	LookAtAlphaTarget=1.f
	LookAtAlpha=1.f

	bAllowRotationX=TRUE
	bAllowRotationY=TRUE
	bAllowRotationZ=TRUE
	AllowRotationSpace=BCS_BoneSpace
}
