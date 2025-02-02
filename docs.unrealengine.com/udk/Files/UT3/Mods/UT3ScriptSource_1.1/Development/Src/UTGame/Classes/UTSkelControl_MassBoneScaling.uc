﻿/**
 * skeletal controller that provides a cleaner and more efficient way to handle scaling for many bones in a mesh
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class UTSkelControl_MassBoneScaling extends SkelControlBase
	native(Animation);

/** bone scales - indices match mesh's bone indices */
var() array<float> BoneScales;



/** sets the given bone to the given scale
 * @note this controller must be hooked up to the specified bone in the AnimTree for this to have any effect
 */
native final function SetBoneScale(name BoneName, float Scale);

/** returns the scale this control has for the given bone
 * @note does not take into account any other controls that are affecting the bone's scale
 */
native final function float GetBoneScale(name BoneName);
