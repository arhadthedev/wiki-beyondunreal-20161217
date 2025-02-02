﻿/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class UTVehicle_Fury extends UTAirVehicle
	native(Vehicle)
	abstract;

var UTAnimNodeSequence AnimPlayer;
var AnimNodeBlend BlendNode;
var float TakeOffRate;

var UTAnimBlendByCollision ArmBlendNodes[4];

/** Boost speed is the (clamped) max speed */
var float BoostAirSpeed;

/** Booster properties */
var float BoosterForceMagnitude[4];

/** True if the booster has been activated */

enum EBoostDir
{
	EBD_None,
	EBD_Forward,
	EBD_Left,
	EBD_Right
};

var EBoostDir BoostAttempt;
var repnotify EBoostDir BoostStatus;

/** If true, steering is very limited (enabled while boosting) */
var bool bSteeringLimited;

/** How long does the boost last */
var float MaxBoostDuration[4];

/** When was it started */
var float BoostEndTime;

/** When can the next boost occur */
var float BoostDisabledTimer;

/** Time between boosts. */
var() float BoostInterval;

var float BoostPowerSpeed;

/** How long afterwards does it take to charge up */
var float BoostChargeRate;

/** desired camera FOV while using booster */
var float BoosterFOVAngle;

/** Camera movement to play when boosting. */
var CameraAnim BoostCameraShake;

/** Values to be used when Steering is lowered */
var float MinTurnStrafeForce;
var float MinTurnThrustForce;
var float MinTurnRiseForce;

/** Adjustments to the upright constraint depending on turn rate */
var float UprightRollMinThreshold;
var float UprightRollMaxThreshold;
var float UprightMaxModifier;

/** Emitter template for the beams */
var particleSystem BeamTemplate;

/** Holds the Emitter for the Beam */
var ParticleSystemComponent BeamEmitter[4];

var ParticleSystemComponent EffectEmitter;

/** Where to attach the Beam */
var name BeamSockets[4];

/** The name of the EndPoint parameter */
var name EndPointParamName;

/** The name of the EndPoint normal parameter */
var name EndPointNormalParamName;

/** Scale applied to tangent where beam hits target. */
var() float EndPointNormalLength;

/** Sfx to play when the beam is fired */
var soundcue BeamFireSound;
/** Sfx to play when boosting forward/back*/
var soundcue AfterburnerSound;
/** Sfx to play when boosting sideways */
var soundcue StrafeSound;

/** Sound playing while the beam is firing */
var protected AudioComponent BeamAmbientSound;
var SoundCue BeamStartSound, BeamStopSound;

var AudioComponent BoostComponent;
struct native BeamLockData
{
	var	actor LockedTarget;
	var name LockedBone;
};

/** Who is the beam locked on to */
var repnotify BeamLockData BeamLockedInfo;

struct native JetSFXInfo
{
	var	name ExhaustTag;			// Name of the Emitter effect this data applies to
	var float Exhaust;				// The value for this emitter when not boosting
	var float ExhaustCur;			// The current value for this emitter
	var float ExhaustRampUpTime;    // How long until the emitter has boosted
	var float ExhaustRampDownTime;	// How long should it take to come back
};

var JetSFXInfo JetSFX[3];	// Forward, Left, Right

var name BoosterNames[3];

var float BoostRampUpTime;
var float BoostRampDownTime;

/** radius to allow players under this Fury to gain entry */
var float CustomEntryRadius;

/** Used to raise and lower tail fin. */
var SkelControlSingleBone	TailFoldControl;

/** How high off the ground to execute PlayLanding event. */
var() float LandingEventHeight;

replication
{
	if (bNetDirty && !bNetOwner && Role==ROLE_Authority)
		BoostStatus;

	if (bNetDirty && Role==ROLE_Authority)
		BeamLockedInfo;
}




native function Boost(out JetSFXInfo SFXInfo, float RampUpTime, float RampDownTime);
native function BoostTo(out JetSFXInfo SFXInfo, float NewExhaust, float RampTime);

simulated function GetSVehicleDebug( out Array<String> DebugInfo )
{
	Super.GetSVehicleDebug(DebugInfo);
	DebugInfo[DebugInfo.Length] = "";
	DebugInfo[DebugInfo.Length] = "Forward Jets: "@JetSFX[0].Exhaust@JetSFX[0].ExhaustCur;
	DebugInfo[DebugInfo.Length] = "Left Jets:    "@JetSFX[1].Exhaust@JetSFX[1].ExhaustCur;
	DebugInfo[DebugInfo.Length] = "Right Jets:   "@JetSFX[2].Exhaust@JetSFX[2].ExhaustCur;
	DebugInfo[DebugInfo.Length] = "";
	DebugInfo[DebugInfo.Length] = "Steering"@VState.ServerGas@VState.ServerSteering;
	DebugInfo[DebugInfo.Length] = "";
	DebugInfo[DebugInfo.Length] = "----Beam----: ";
	DebugInfo[DebugInfo.Length] = ""@BeamLockedInfo.LockedTarget;
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	EnableFullSteering();

   	AddBeamEmitter();
}

simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
	Super.PostInitAnimTree(SkelComp);

	if(SkelComp == Mesh)
	{
		TailFoldControl = SkelControlSingleBone( Mesh.FindSkelControl('TailFold') );
	}
}

simulated event Destroyed()
{
	Super.Destroyed();
	KillBeamEmitter();
}

simulated event ReplicatedEvent(name VarName)
{
	if (VarName == 'BoostStatus')
	{
		if ( BoostStatus != EBD_None )
		{
			ActivateRocketBoosters( BoostStatus );
		}
		else
		{
			DeActivateRocketBoosters();
		}
	}
	else if ( VarName == 'BeamLockedInfo' )
	{
		BeamLockOn();
	}
	else
	{
		Super.ReplicatedEvent(VarName);
	}
}

/********************* Beam Attack ********************************************/

simulated function AddBeamEmitter()
{
	local int i;
	if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		for (i=0;i<4;i++)
		{
			if (BeamEmitter[i] == None)
			{
				if (BeamTemplate != None)
				{
					BeamEmitter[i] = new(Outer) class'UTParticleSystemComponent';
					BeamEmitter[i].SetTemplate(BeamTemplate);
					BeamEmitter[i].SetHidden(true);
					Mesh.AttachComponentToSocket( BeamEmitter[i],BeamSockets[i] );
				}
			}
			else
			{
				BeamEmitter[i].ActivateSystem();
			}
		}
	}
}

simulated function KillBeamEmitter()
{
	local int i;
	for (i=0;i<4;i++)
	{
		if (BeamEmitter[i] != none)
		{
			BeamEmitter[i].SetHidden(true);
			BeamEmitter[i].DeactivateSystem();
		}
	}
}

simulated function SetBeamEmitterHidden(bool bHide)
{
	local int i;

	if ( WorldInfo.NetMode != NM_DedicatedServer )
	{
		if ( bHide )
		{
			if (BeamAmbientSound.bWasPlaying)
			{
				BeamAmbientSound.Stop();
				PlaySound(BeamStopSound, true);
			}
		}
		else if (!BeamAmbientSound.bWasPlaying)
		{
			PlaySound(BeamStartSound, true);
			BeamAmbientSound.SoundCue = BeamFireSound;
			BeamAmbientSound.Play();
		}


		for (i=0;i<4;i++)
		{
			if ( BeamEmitter[i].HiddenGame != bHide )
			{
				if (BeamEmitter[i] != none)
				{
					BeamEmitter[i].SetHidden(bHide);
					if ( !bHide )
					{
						BeamEmitter[i].ActivateSystem();
					}
				}
			}
		}
	}
}

simulated function SpawnImpactEmitter(vector HitLocation, vector HitNormal, const out MaterialImpactEffect ImpactEffect, int SeatIndex)
{
	if (EffectEmitter == None)
	{
		EffectEmitter = new(self) class'ParticleSystemComponent';
		EffectEmitter.SetTemplate(ImpactEffect.ParticleTemplate);
		EffectEmitter.SetAbsolute(true, true, true);
		EffectEmitter.bAutoActivate = false;
		AttachComponent(EffectEmitter);
	}
	else
	{
		if (EffectEmitter.Template != ImpactEffect.ParticleTemplate)
		{
			EffectEmitter.SetTemplate(ImpactEffect.ParticleTemplate);
		}
		else if (EffectEmitter.bWasCompleted)
		{
			// reattach to avoid impact effect stretching across distance since we last fired
			DetachComponent(EffectEmitter);
			AttachComponent(EffectEmitter);
		}
	}

	EffectEmitter.SetTranslation(HitLocation);
	EffectEmitter.SetRotation(rotator(HitNormal));
	EffectEmitter.SetActive(true);
}

simulated function VehicleWeaponFired( bool bViaReplication, vector HitLocation, int SeatIndex )
{
	local int i;
	local vector TraceDir, HitLoc, HitNorm, BeamEndTangent;

	Super.VehicleWeaponImpactEffects(HitLocation, SeatIndex);

	if ( WorldInfo.NetMode != NM_DedicatedServer )
	{
		// Trace in direction from vehicle to hit location, to find hit tangent
		BeamEndTangent = vect(0,0,1);
		TraceDir = Normal(HitLocation - Location);
		if( Trace(HitLoc, HitNorm, HitLocation + (50*TraceDir), HitLocation - (50*TraceDir), FALSE, vect(0,0,0)) != None )
		{
			BeamEndTangent = HitNorm;
		}

		// Set end point and tangent for each beam
		if ( HitLocation != Vect(0,0,0) )
		{
			for (i = 0; i < 4; i++)
			{
				BeamEmitter[i].SetVectorParameter(EndPointParamName, HitLocation);
				BeamEmitter[i].SetVectorParameter(EndPointNormalParamName, BeamEndTangent*EndPointNormalLength);
			}
			SetBeamEmitterHidden(false);
		}
	}
}

simulated function VehicleWeaponStoppedFiring( bool bViaReplication, int SeatIndex )
{
	Super.VehicleWeaponStoppedFiring( bViaReplication,SeatIndex );

	if ( WorldInfo.NetMode != NM_DedicatedServer && SeatIndex == 0)
	{
		SetBeamEmitterHidden(true);

		if (EffectEmitter != None)
		{
			EffectEmitter.DeactivateSystem();
		}
	}
}

simulated function BeamLockOn()
{
	local Vector Loc;

	if ( BeamLockedInfo.LockedTarget != none )
	{
		if ( Pawn( BeamLockedInfo.LockedTarget ) != none && BeamLockedInfo.LockedBone != '' )
		{
			Loc = Pawn( BeamLockedInfo.LockedTarget ).Mesh.GetBoneLocation(BeamLockedInfo.LockedBone);
		}
		else
		{
			Loc = BeamLockedInfo.LockedTarget.Location;
		}
		VehicleWeaponFired(true, Loc, 0);
	}
	else
	{
		VehicleWeaponStoppedFiring(false, 0);
	}
}

/********************* Boosting ********************************************/

simulated function bool TouchingForcedDirVolume()
{
	local ForcedDirVolume FDV;

	foreach TouchingActors(class'ForcedDirVolume', FDV)
	{
		return TRUE;
	}

	return FALSE;
}

simulated function bool OverrideBeginFire(byte FireModeNum)
{
	local EBoostDir BoostDir;

	if (FireModeNum == 1)
	{
		// figure out boost direction based on current input direction
		if( IsLocallyControlled() &&
			BoostStatus == EBD_None &&
			WorldInfo.TimeSeconds - BoostDisabledTimer > BoostInterval &&
			!TouchingForcedDirVolume() )
		{
			BoostDir = EBD_None;

			if (Throttle > 0.5)
			{
				BoostDir = EBD_Forward;
			}
			else if (Steering < -0.5)
			{
				BoostDir = EBD_Right;
			}
			else if (Steering > 0.5)
			{
				BoostDir = EBD_Left;
			}

			if (BoostDir != EBD_None)
			{
				ServerBoost(BoostDir);
				BoostAttempt = BoostDir;
			}
		}

		return true;
	}
	else
	{
		return false;
	}
}

simulated function bool OverrideEndFire(byte FireModeNum)
{
	return (FireModeNum == 1);
}

reliable server function ServerBoost(EBoostDir BoostType)
{
	BoostAttempt = BoostType;
}

simulated event EnableFullSteering()
{
	local UTVehicleSimChopper SObj,DSObj;

	bSteeringLimited = false;

	SObj = UTVehicleSimChopper(SimObj);
	DSObj = UTVehicleSimChopper(default.SimObj);

	SObj.MaxStrafeForce = DSObj.MaxStrafeForce;
	SObj.MaxThrustForce = DSObj.MaxThrustForce;
	SObj.MaxRiseForce   = DSObj.MaxRiseForce;


	AirSpeed = default.AirSpeed;
}

simulated event LowerSteering()
{
	local UTVehicleSimChopper SObj;

	bSteeringLimited = false;

	SObj = UTVehicleSimChopper(SimObj);

	SObj.MaxStrafeForce=MinTurnStrafeForce;
	SObj.MaxThrustForce=MinTurnThrustForce;
	SObj.MaxRiseForce=MinTurnRiseForce;

	AirSpeed=3500;
}

/** ActivateRocketBoosters()
called when player activates rocket boosters
*/
simulated event ActivateRocketBoosters(EBoostDir BoostDir)
{
	//local int i;
	local int BoosterIndex;

	BoostStatus = BoostDir;
	BoosterIndex = Clamp(BoostStatus - 1, 0, 2);
	bSteeringLimited = true;
	AirSpeed = BoostAirSpeed;

	BoostEndTime = WorldInfo.TimeSeconds + MaxBoostDuration[BoostDir];
	LowerSteering();

	//for (i=0;i<4;i++)
	//{
	//	if ( ArmBlendNodes[i] != none && !ArmBlendNodes[i].bPulseBlend )
	//	{
	//		ArmBlendNodes[i].Pulse(0.25);
	//	}
	//}

	if ( WorldInfo.NetMode == NM_DedicatedServer )
		return;

	// Play any animations/etc here
	if ( UTPlayerController(Controller) != none )
	{
		UTPlayerController(Controller).PlayCameraAnim(BoostCameraShake, 1.f, 1.f, 0.1, 0.1, FALSE, FALSE);
		//UTPlayerController(Controller).StartZoom(BoosterFOVAngle,60);
	}
	if(BoostComponent != none)
	{
		if(BoostDir == EBD_Forward)
		{
			BoostComponent.SoundCue = AfterburnerSound;
		}
		else
		{
			BoostComponent.SoundCue = StrafeSound;
		}
		BoostComponent.Play();
	}
	VehicleEffects[0].EffectRef.SetFloatParameter(BoosterNames[BoosterIndex],1.0);
}


/** DeactivateRocketBoosters()
called when player deactivates rocket boosters or they run out
*/
simulated event DeactivateRocketBoosters()
{
	local UTPlayerController PC;
	local int BoosterIndex;
	AirSpeed = Default.AirSpeed;

	BoosterIndex = BoostStatus - 1;

	BoostStatus = EBD_None;
	EnableFullSteering();

	if ( WorldInfo.NetMode == NM_DedicatedServer )
		return;

	PC = UTPlayerController(Controller);
	if ( PC != none )
	{
		PC.StartZoom(PC.DefaultFOV,60);
	}

	if(BoosterIndex >= 0)
	{
		VehicleEffects[0].EffectRef.SetFloatParameter(BoosterNames[BoosterIndex],0.0);
		BoostDisabledTimer = WorldInfo.TimeSeconds;
	}
}

simulated event PlayLanding();

simulated event PlayTakeOff();

/**
  * Let pawns standing under me get in, if I have a driver.
  */
function bool InCustomEntryRadius(Pawn P)
{
	return ( (P.Location.Z < Location.Z) && (VSize2D(P.Location - Location) < CustomEntryRadius)
		&& FastTrace(P.Location, Location) );
}

simulated function bool ShouldClamp()
{
	return false;
}

/** Used to stop boosting when entering forced dir volume. */
function bool OnTouchForcedDirVolume(ForcedDirVolume Vol)
{
	if(Role == ROLE_Authority)
	{
		DeactivateRocketBoosters();
	}

	return TRUE;
}

function bool RecommendLongRangedAttack()
{
	return false;
}

function bool Dodge(eDoubleClickDir DoubleClickMove)
{
	ServerBoost((FRand() < 0.5) ? EBD_Left : EBD_Right);
	return false;
}

defaultproperties
{
	Begin Object Name=CollisionCylinder
		CollisionHeight=+70.0
		CollisionRadius=+240.0
		Translation=(X=0.0,Y=0.0,Z=0.0)
	End Object

	AirSpeed=1500.0
	GroundSpeed=2000
	Health=400
	TeamBeaconOffset=(z=180.0)

	UprightLiftStrength=30.0
	UprightTorqueStrength=30.0
	bMustBeUpright=false
	bEjectPassengersWhenFlipped=false
	bCanFlip=true

	PushForce=50000.0

	ExitOffset=(X=100.0)

	bStayUpright=true
	StayUprightRollResistAngle=5.0
	StayUprightPitchResistAngle=5.0
	StayUprightStiffness=800
	StayUprightDamping=20

	SpawnRadius=220.0

	Begin Object Class=UTVehicleSimChopper Name=SimObject
		MaxThrustForce=1100.0
		MaxReverseForce=500.0
		LongDamping=0.7
		MaxStrafeForce=400.0
		LatDamping=0.7
		MaxRiseForce=800.0
		UpDamping=0.7
		TurnTorqueFactor=7000.0
		TurnTorqueMax=2000.0
		TurnDamping=1.35
		MaxYawRate=1.2
		PitchTorqueFactor=400.0
		PitchTorqueMax=60.0
		PitchDamping=0.1
		RollTorqueTurnFactor=1500.0
		RollTorqueStrafeFactor=100.0
		RollTorqueMax=300.0
		RollDamping=0.1
		MaxRandForce=25.0
		RandForceInterval=0.5
		StopThreshold=100
		bFullThrustOnDirectionChange=true
		PitchViewCorrelation=350.0
	End Object
	SimObj=SimObject
	Components.Add(SimObject)

	MinTurnStrafeForce=100.0
	MinTurnThrustForce=3500.0
	MinTurnRiseForce=2200.0

	MaxGroundEffectDist=512.0

	bHomingTarget=true

	BaseEyeheight=100
	Eyeheight=100
	bRotateCameraUnderVehicle=true
	CameraLag=0.05
	bLimitCameraZLookingUp=true

	TakeOffRate=1.134

	BoostAirSpeed=5000
	BoosterForceMagnitude(1)=1700.0
	BoosterForceMagnitude(2)=1700.0
	BoosterForceMagnitude(3)=1700.0
	MaxBoostDuration(1)=1.0
	MaxBoostDuration(2)=0.7
	MaxBoostDuration(3)=0.7
	BoostPowerSpeed=5000.0
	BoosterFOVAngle=90
	BoostInterval=1.5

 	MaxSpeed=4000

	UprightRollMinThreshold=0
	UprightRollMAxThreshold=1000
	UprightMaxModifier=15

	BoostRampUpTime=0.2
	BoostRampDownTime=0.5

	bHasCustomEntryRadius=true
	CustomEntryRadius=240.0

	LandingEventHeight=400

	bIsNecrisVehicle=true

	HornIndex=3
}
