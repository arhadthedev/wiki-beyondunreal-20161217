﻿/**
 * Reverts any animation compression, restoring the animation to the raw data.
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class AnimationCompressionAlgorithm_RevertToRaw extends AnimationCompressionAlgorithm
	native(Anim);



defaultproperties
{
	Description="Revert To Raw"
	TranslationCompressionFormat=ACF_None
	RotationCompressionFormat=ACF_None
}
