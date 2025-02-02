﻿/**
 *	Abstract base class for a skeletal controller.
 *	A SkelControl is a module that can modify the position or orientation of a set of bones in a skeletal mesh in some programmtic way.
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class SkelControlBase extends Object
	hidecategories(Object)
	native(Anim)
	abstract;


 /** Enum for controlling which reference frame a controller is applied in. */
enum EBoneControlSpace
{
	/** Set absolute position of bone in world space. */
	BCS_WorldSpace,

	/** Set position of bone in Actor's reference frame. */
	BCS_ActorSpace,

	/** Set position of bone in SkeletalMeshComponent's reference frame. */
	BCS_ComponentSpace,

	/** Set position of bone relative to parent bone. */
	BCS_ParentBoneSpace,

	/** Set position of bone in its own reference frame. */
	BCS_BoneSpace,

	/** Set position of bone in the reference frame of another bone. */
	BCS_OtherBoneSpace
};


/** SkeletalMeshComponent owner */
var const transient	SkeletalMeshComponent		SkelComponent;

/** Name used to identify this SkelControl. */
var(Controller)	name			ControlName;

/**
 *	Used to control how much affect this SkelControl has.
 *	1.0 means fully active, 0.0 means have no affect.
 *	Exactly how the control ramps up depends on the specific control type.
 */
var(Controller)	float			ControlStrength;

/** When calling SetActive passing in 'true', indicates how many seconds to take to reach a ControlStrength of 1.0. */
var(Controller)	float			BlendInTime;

/** When calling SetActive passing in 'false', indicates how many seconds to take to reach a ControlStrength of 0.0. */
var(Controller)	float			BlendOutTime;

/** Strength towards which we are currently ramping. */
var				float			StrengthTarget;

/** Amount of time left in the currently active blend. */
var				float			BlendTimeToGo;

/** If true, Strength will be the same as given AnimNode(s). This is to make transitions easier between nodes and Controllers. */
var(Controller)	bool			bSetStrengthFromAnimNode;
/** List of AnimNode names, to get Strength from */
var(Controller)	Array<Name>		StrengthAnimNodeNameList;
/** Cached list of nodes to get strength from */
var	transient	Array<AnimNode>	CachedNodeList;
var transient	bool			bInitializedCachedNodeList;

/** If true, calling SetSkelControlActive on this node will call SetSkelControlActive on the next one in the chain as well. */
var(Controller)	bool			bPropagateSetActive;

/** This scaling is applied to the bone that this control is acting upon. */
var(Controller) float			BoneScale;

/**
 *	Used to ensure we don't tick this SkelControl twice, if used in multiple different control chains.
 *	Compared against the SkeletalMeshComponent TickTag.
 */
var				int				ControlTickTag;

/** 
 *	whether this control should be ignored if the SkeletalMeshComponent being composed hasn't been rendered recently
 *	
 *	@note this can be forced by the SkeletalMeshComponent's bIgnoreControllersWhenNotRendered flag
 */
var()			bool			bIgnoreWhenNotRendered;

/** If true, when skel control becomes active it uses a curve rather than a linear blend to blend in more smoothly. */
var()			bool			bEnableEaseInOut;

/** If the LOD of this skeletal mesh is at or above this LOD, then this SkelControl will not be applied. */
var(Controller)	int				IgnoreAtOrAboveLOD;

/** Next SkelControl in the linked list. */
var				SkelControlBase	NextControl;

/** Used by editor. */
var				int				ControlPosX;

/** Used by editor. */
var				int				ControlPosY;

/** Used by editor. */
var				int				DrawWidth;





/**
 *	Toggle the active state of the SkeControl.
 *	If passing in true, will take BlendInTime to reach a ControlStrength of 1.0.
 *	If passing in false, will take BlendOutTime to reach a ControlStrength of 0.0.
 */
native final function SetSkelControlActive(bool bInActive);

/**
 * Set custom strength with optional blend time.
 * @param	NewStrength		Target Strength for this controller.
 * @param	InBlendTime		Time it will take to reach that new strength. (0.f == Instant)
 */
native final function SetSkelControlStrength(float NewStrength, float InBlendTime);


defaultproperties
{
	BoneScale=1.0
	ControlStrength=1.0
	StrengthTarget=1.0
	BlendInTime=0.2
	BlendOutTime=0.2
	IgnoreAtOrAboveLOD=1000
}
