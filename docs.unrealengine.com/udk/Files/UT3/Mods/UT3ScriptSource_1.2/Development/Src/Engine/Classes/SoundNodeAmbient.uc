﻿/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class SoundNodeAmbient extends SoundNode
	native(Sound)
	collapsecategories
	hidecategories(Object)
	dependson(SoundNodeAttenuation)
	editinlinenew;


var()								SoundDistanceModel		DistanceModel;

var()								rawdistributionfloat	MinRadius;
var()								rawdistributionfloat	MaxRadius;
var()								rawdistributionfloat	LPFMinRadius;
var()								rawdistributionfloat	LPFMaxRadius;

var()								bool					bSpatialize;
var()								bool					bAttenuate;
var()								bool					bAttenuateWithLowPassFilter;

var()								SoundNodeWave			Wave;

var()								rawdistributionfloat		VolumeModulation;
var()								rawdistributionfloat		PitchModulation;





defaultproperties
{
	Begin Object Class=DistributionFloatUniform Name=DistributionMinRadius
		Min=400
		Max=400
	End Object
	MinRadius=(Distribution=DistributionMinRadius)

	Begin Object Class=DistributionFloatUniform Name=DistributionMaxRadius
		Min=5000
		Max=5000
	End Object
	MaxRadius=(Distribution=DistributionMaxRadius)

	Begin Object Class=DistributionFloatUniform Name=DistributionLPFMinRadius
		Min=1500
		Max=1500
	End Object
	LPFMinRadius=(Distribution=DistributionLPFMinRadius)

	Begin Object Class=DistributionFloatUniform Name=DistributionLPFMaxRadius
		Min=2500
		Max=2500
	End Object
	LPFMaxRadius=(Distribution=DistributionLPFMaxRadius)

	Begin Object Class=DistributionFloatUniform Name=DistributionVolume
		Min=1
		Max=1
	End Object
	VolumeModulation=(Distribution=DistributionVolume)

	Begin Object Class=DistributionFloatUniform Name=DistributionPitch
		Min=1
		Max=1
	End Object
	PitchModulation=(Distribution=DistributionPitch)

	bSpatialize=true
	bAttenuate=true
	bAttenuateWithLowPassFilter=false
}

