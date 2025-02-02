﻿/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class UTSkelControl_SpinControl extends SkelControlSingleBone
	native(Animation)
	hidecategories(Adjustments,Translation,Rotation);

/** How fast is the core to spin at max health */

var(Spin)	float 	DegreesPerSecond;
var(Spin)	vector	Axis;



defaultproperties
{
	bApplyTranslation=false
	bAddTranslation=false
	bApplyRotation=true
	bAddRotation=true
	BoneRotationSpace=BCS_ActorSpace
	DegreesPerSecond=180
}
