﻿/**
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class UTWalkerBody extends Actor
	native(Vehicle)
	abstract
	notplaceable;

// 3 legged walkers, by default
const NUM_WALKER_LEGS = 3;

enum EWalkerLegID
{
	WalkerLeg_Rear,
	WalkerLeg_FrontLeft,
	WalkerLeg_FrontRight
};

/** Skel mesh for the legs. */
var() /*const*/ editconst SkeletalMeshComponent	SkeletalMeshComponent;

/** Refs to shoulder lookat skelcontrols for each leg  */
var protected transient SkelControlLookat ShoulderSkelControl[NUM_WALKER_LEGS];
/** Names for the shoulder skelcontrol nodes for each leg (from the animtree) */
var protected const Name ShoulderSkelControlName[NUM_WALKER_LEGS];

/** If TRUE for corresponding foot, walking/stepping code will ignore that leg */
var() byte IgnoreFoot[NUM_WALKER_LEGS];

/** Handles used to move the walker feet around. */
var() UTWalkerStepHandle FootConstraints[NUM_WALKER_LEGS];

/** world time to advance to the next phase of the step - experimental walker leg code */
var float NextStepStageTime[NUM_WALKER_LEGS];

/** Time, in seconds, that each step stage lasts. */
var() const array<float> StepStageTimes;

/** which stage the step is in for each leg - experimental walker leg code */
var protected int StepStage[NUM_WALKER_LEGS];

/** used to play water effects when feet enter/exit water */
var byte FootInWater[NUM_WALKER_LEGS];
var ParticleSystem FootWaterEffect;

/** Min dist trigger to make foot a possible candidate for next step */
var() float MinStepDist;

/** Max leg extension */
var() float MaxLegReach;

/** Factor in range [0..1].  0 means no leg spread, 1 means legs are spread as far as possible. */
var() float LegSpreadFactor;
var() float	CustomGravityScale;
var() float LandedFootDistSq;

/** How far foot should embed into ground. */
var() protected const float FootEmbedDistance;


/** Bone names for this walker */
var const name FootBoneName[NUM_WALKER_LEGS];
var const name ShoulderBoneName[NUM_WALKER_LEGS];
var const name BodyBoneName;

/** Ref to the walker vehicle that we are attached to. */
var transient UTVehicle_Walker	WalkerVehicle;

var protected const bool	bHasCrouchMode;
var	bool					bIsDead;

/** Where the feet are right now */
var vector CurrentFootPosition[NUM_WALKER_LEGS];

var array<MaterialImpactEffect> FootStepEffects;
var ParticleSystemComponent FootStepParticles[NUM_WALKER_LEGS];

/** Store indices into the legs array, used to map from rear/left/right leg designations to the model's leg indices.  Indexed by LegID. */
var transient int LegMapping[EWalkerLegID.EnumCount];

/** Base directions from the walker center for the legs to point, in walker-local space.  Indexed by LegID. */
var protected const vector BaseLegDirLocal[EWalkerLegID.EnumCount];

/**
 * Scalar to control how much velocity to add to the desired foot positions.  Indexed by LegID.
 * This effectively controls how far ahead of the walker the legs will try to reach while the walker
 * is moving.
 */
var() const float FootPosVelAdjScale[EWalkerLegID.EnumCount];

/** Names of the anim nodes for playing the step anim for a leg.  Used to fill in FootStepAnimNode array. */
var protected const Name	FootStepAnimNodeName[NUM_WALKER_LEGS];
/** Refs to AnimNodes used for playing step animations */
var protected AnimNode		FootStepAnimNode[NUM_WALKER_LEGS];

/** How far above the current foot position to begin interpolating towards. */
var() protected const float FootStepStartLift;
/** How far above the desired foot position to end the foot step interpolation */
var() protected const float FootStepEndLift;

struct native WalkerLegStepAnimData
{
	/** Where foot wants to be. */
	var vector				DesiredFootPosition;

	/** Normal of the surface at the desired foot position. */
	var vector				DesiredFootPosNormal;

	/** Physical material at the DesiredFootPosition */
	var PhysicalMaterial	DesiredFootPosPhysMaterial;

	/** True if we don't have a valid desired foot position for this leg. */
	var bool				bNoValidFootHold;
};

/** Indexed by LegID. */
var protected WalkerLegStepAnimData StepAnimData[EWalkerLegID.EnumCount];

/** keeps track of previous leg locations */
var protected vector PreviousTraceSeedLocation[NUM_WALKER_LEGS];

/** The walker legs's light environment */
var DynamicLightEnvironmentComponent LegLightEnvironment;

var float MaxFootStepEffectDist;



function PostBeginPlay()
{
	local int Idx;

	super.PostBeginPlay();

	// make sure the rb is awake
	SkeletalMeshComponent.WakeRigidBody();

	for (Idx=0; Idx<NUM_WALKER_LEGS; ++Idx)
	{
		// cache refs to footstep anims
		FootStepAnimNode[Idx] = SkeletalMeshComponent.FindAnimNode(FootStepAnimNodeName[Idx]);

		// cache refs to skel controls
		ShoulderSkelControl[Idx] = SkelControlLookAt(SkeletalMeshComponent.FindSkelControl(ShoulderSkelControlName[Idx]));
		if (ShoulderSkelControl[Idx] != None)
		{
			// turn it on
			ShoulderSkelControl[Idx].SetSkelControlActive(TRUE);
		}
	}
}

simulated function UpdateShadowSettings(bool bWantShadow)
{
	local bool bNewCastShadow, bNewCastDynamicShadow;

	if (SkeletalMeshComponent != None)
	{
		bNewCastShadow = default.SkeletalMeshComponent.CastShadow && bWantShadow;
		bNewCastDynamicShadow = default.SkeletalMeshComponent.bCastDynamicShadow && bWantShadow;
		if (bNewCastShadow != SkeletalMeshComponent.CastShadow || bNewCastDynamicShadow != SkeletalMeshComponent.bCastDynamicShadow)
		{
			SkeletalMeshComponent.CastShadow = bNewCastShadow;
			SkeletalMeshComponent.bCastDynamicShadow = bNewCastDynamicShadow;
			// defer if we can do so without it being noticeable
			if (LastRenderTime < WorldInfo.TimeSeconds - 1.0)
			{
				SetTimer(0.1 + FRand() * 0.5, false, 'ReattachMesh');
			}
			else
			{
				ReattachMesh();
			}
		}
	}
}

/** reattaches the mesh component, because settings were updated */
simulated function ReattachMesh()
{
	DetachComponent(SkeletalMeshComponent);
	AttachComponent(SkeletalMeshComponent);
}

/* epic ===============================================
* ::StopsProjectile()
*
* returns true if Projectiles should call ProcessTouch() when they touch this actor
*/
simulated function bool StopsProjectile(Projectile P)
{
	// Don't block projectiles fired from this vehicle
	return (P.Instigator != WalkerVehicle) && (bProjTarget || bBlockActors);
}

/** Called once to set up legs. */
native function InitFeet();

/** Called on landing to reestablish a foothold */
native function InitFeetOnLanding();

function SetWalkerVehicle(UTVehicle_Walker V)
{
	WalkerVehicle = V;
	SkeletalMeshComponent.SetShadowParent(WalkerVehicle.Mesh);
	SkeletalMeshComponent.SetLightEnvironment(LegLightEnvironment);
	InitFeet();
}

event PlayFootStep(int LegIdx)
{
	local AudioComponent AC;
	local UTPhysicalMaterialProperty PhysicalProperty;
	local int EffectIndex;

	local vector HitLoc,HitNorm,TraceLength;
	local TraceHitInfo HitInfo;

	if (FootStepEffects.Length == 0)
	{
		return;
	}

	// figure out what we landed on

	TraceLength = vector(QuatToRotator(SkeletalMeshComponent.GetBoneQuaternion(FootBoneName[LegIdx])))*5.0;
	//Trace(HitLoc,HitNorm, CurrentFootPosition[LegIdx]+TraceLength,CurrentFootPosition[LegIdx],true,,HitInfo);
	Trace(HitLoc,HitNorm, CurrentFootPosition[LegIdx]-TraceLength,CurrentFootPosition[LegIdx]-TraceLength*4.0,true,,HitInfo);
	if(HitInfo.PhysMaterial != none)
	{
		PhysicalProperty = UTPhysicalMaterialProperty(HitInfo.PhysMaterial.GetPhysicalMaterialProperty(class'UTPhysicalMaterialProperty')); //(StepAnimData[LegIdx].DesiredFootPosPhysMaterial.GetPhysicalMaterialProperty(class'UTPhysicalMaterialProperty'));
	}
	if (PhysicalProperty != None)
	{
		EffectIndex = FootStepEffects.Find('MaterialType', PhysicalProperty.MaterialType);
		if (EffectIndex == INDEX_NONE)
		{
			EffectIndex = 0;
		}
		// Footstep particle
		if (FootStepEffects[EffectIndex].ParticleTemplate != None && EffectIsRelevant(Location, false))
		{
			if (FootStepParticles[LegIdx] == None)
			{
				FootStepParticles[LegIdx] = new(self) class'UTParticleSystemComponent';
				FootStepParticles[LegIdx].bAutoActivate = false;
				SkeletalMeshComponent.AttachComponent(FootStepParticles[LegIdx], FootBoneName[LegIdx]);
			}
			FootStepParticles[LegIdx].SetTemplate(FootStepEffects[EffectIndex].ParticleTemplate);
			FootStepParticles[LegIdx].ActivateSystem();
		}
	}

	AC = WorldInfo.CreateAudioComponent(FootStepEffects[EffectIndex].Sound, false, true);
	if (AC != None)
	{
		AC.bUseOwnerLocation = false;

		// play it closer to the player if he's controlling the walker
		AC.Location = (PlayerController(WalkerVehicle.Controller) != None) ? 0.5 * (Location + CurrentFootPosition[LegIdx]) : CurrentFootPosition[LegIdx];

		AC.bAutoDestroy = true;
		AC.Play();
	}
	WalkerVehicle.TookStep(LegIdx);
}

event SpawnFootWaterEffect(int LegIdx)
{
	if (FootWaterEffect != None)
	{
		WorldInfo.MyEmitterPool.SpawnEmitter(FootWaterEffect, CurrentFootPosition[LegIdx]);
	}
}

/**
 * Default behavior when shot is to apply an impulse and kick the KActor.
 */
event TakeDamage(int Damage, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	local vector ApplyImpulse;

	if (damageType.default.KDamageImpulse > 0 )
	{
		if ( VSize(momentum) < 0.001 )
		{
			`Log("Zero momentum to KActor.TakeDamage");
			return;
		}

		// Make sure we have a valid TraceHitInfo with our SkeletalMesh
		// we need a bone to apply proper impulse
		CheckHitInfo( HitInfo, SkeletalMeshComponent, Normal(Momentum), hitlocation );

		ApplyImpulse = Normal(momentum) * damageType.default.KDamageImpulse;
		if ( HitInfo.HitComponent != None )
		{
			HitInfo.HitComponent.AddImpulse(ApplyImpulse, HitLocation, HitInfo.BoneName);
		}
	}
}

function PlayDying()
{
	local int i;

	Lifespan = 8.0;
	CustomGravityScale = 1.5;
	bCollideWorld = true;
	bIsDead = true;

	// clear all constraints
	for ( i=0; i<3; i++ )
	{
		FootConstraints[i].ReleaseComponent();
	}

	SkeletalMeshComponent.SetTraceBlocking(true, false);
	SkeletalMeshComponent.SetBlockRigidBody(true);
	SkeletalMeshComponent.SetShadowParent(None);
	GotoState('DyingVehicle');
}

function AddVelocity( vector NewVelocity, vector HitLocation,class<DamageType> DamageType, optional TraceHitInfo HitInfo )
{
	if ( !IsZero(NewVelocity) )
	{
		if (Location.Z > WorldInfo.StallZ)
		{
			NewVelocity.Z = FMin(NewVelocity.Z, 0);
		}
		NewVelocity = DamageType.Default.VehicleMomentumScaling * DamageType.Default.KDamageImpulse * Normal(NewVelocity);
		SkeletalMeshComponent.AddImpulse(NewVelocity, HitLocation);
	}
}

state DyingVehicle
{
	event TakeDamage(int Damage, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
	{
		if ( DamageType == None )
			return;
		AddVelocity(Momentum, HitLocation, DamageType, HitInfo);
	}
}

/** cause a single step, used for debugging */
native function DoTestStep(int LegIdx, float Mag);

/** NOTE:  this is actually what changes the colors on the PowerOrb on the legs of the Walker **/
simulated function TeamChanged()
{
	local MaterialInterface NewMaterial;

	NewMaterial = WalkerVehicle.Mesh.GetMaterial(0);
	SkeletalMeshComponent.SetMaterial( 0, NewMaterial );

	NewMaterial = WalkerVehicle.Mesh.GetMaterial(1);
	SkeletalMeshComponent.SetMaterial( 1, NewMaterial );
}


/** NOTE:  this is actually what changes the colors on the PowerOrb on the legs of the Walker **/
simulated function SetBurnOut()
{
	local int TeamNum;
	local BurnOutDatum BOD;
	local MaterialInterface NewMaterial;

	TeamNum = WalkerVehicle.GetTeamNum();

	// we use the walker in DM maps where the team will be 255
	if( WalkerVehicle.PowerOrbBurnoutTeamMaterials.length < TeamNum )
	{
		TeamNum = 0;
	}

	// set our specific turret BurnOut Material
	if( ( WalkerVehicle.PowerOrbBurnoutTeamMaterials.length > 0 ) && ( WalkerVehicle.PowerOrbBurnoutTeamMaterials[TeamNum] != None ) )
	{
		NewMaterial = WalkerVehicle.PowerOrbBurnoutTeamMaterials[TeamNum];
		WalkerVehicle.Mesh.SetMaterial( 1, NewMaterial );
		BOD.MITV = WalkerVehicle.Mesh.CreateAndSetMaterialInstanceTimeVarying(1);
		WalkerVehicle.BurnOutMaterialInstances[WalkerVehicle.BurnOutMaterialInstances.length] = BOD;
	}
}


defaultproperties
{
	TickGroup=TG_PostAsyncWork

	Physics=PHYS_RigidBody

	bEdShouldSnap=true
	bStatic=false
	bCollideActors=true
	bBlockActors=false
	bWorldGeometry=false
	bCollideWorld=false
	bProjTarget=true
	bIgnoreEncroachers=true
	bNoEncroachCheck=true

	RemoteRole=ROLE_None

	Begin Object Class=DynamicLightEnvironmentComponent Name=LegLightEnvironmentComp
	    AmbientGlow=(R=0.2,G=0.2,B=0.2,A=1.0)
	End Object
	LegLightEnvironment=LegLightEnvironmentComp
	Components.Add(LegLightEnvironmentComp)


	Begin Object Class=SkeletalMeshComponent Name=LegMeshComponent
		CollideActors=true
		BlockActors=false
		BlockZeroExtent=true
		BlockNonZeroExtent=true
		PhysicsWeight=1
		bHasPhysicsAssetInstance=true
		BlockRigidBody=false
		RBChannel=RBCC_Nothing
		RBCollideWithChannels=(Default=TRUE,GameplayPhysics=TRUE,EffectPhysics=TRUE)
		bUseAsOccluder=FALSE
		bUpdateSkelWhenNotRendered=true
		bIgnoreControllersWhenNotRendered=true
		bAcceptsDecals=false
		bUseCompartment=FALSE
		LightEnvironment=LegLightEnvironmentComp
	End Object
	CollisionComponent=LegMeshComponent
	SkeletalMeshComponent=LegMeshComponent
	Components.Add(LegMeshComponent)

	Begin Object Class=UTWalkerStepHandle Name=RB_FootHandle0
		LinearDamping=50.0
		LinearStiffness=10000.0
	End Object
	FootConstraints(0)=RB_FootHandle0
	Components.Add(RB_FootHandle0)

	Begin Object Class=UTWalkerStepHandle Name=RB_FootHandle1
		LinearDamping=50.0
		LinearStiffness=10000.0
	End Object
	FootConstraints(1)=RB_FootHandle1
	Components.Add(RB_FootHandle1)

	Begin Object Class=UTWalkerStepHandle Name=RB_FootHandle2
		LinearDamping=50.0
		LinearStiffness=10000.0
	End Object
	FootConstraints(2)=RB_FootHandle2
	Components.Add(RB_FootHandle2)

	MinStepDist=20.0
	MaxLegReach=450.0

	FootBoneName(0)=Leg1_End
	FootBoneName(1)=Leg2_End
	FootBoneName(2)=Leg3_End
	ShoulderBoneName(0)=Leg1_Shoulder
	ShoulderBoneName(1)=Leg2_Shoulder
	ShoulderBoneName(2)=Leg3_Shoulder

	BodyBoneName=Root
	CustomGravityScale=0.f
	FootEmbedDistance=8.0
	LandedFootDistSq=400.0

	ShoulderSkelControlName[0]="Shoulder1"
	ShoulderSkelControlName[1]="Shoulder2"
	ShoulderSkelControlName[2]="Shoulder3"

	BaseLegDirLocal[WalkerLeg_Rear]=(X=-1.f,Y=0.f,Z=0.f)
	BaseLegDirLocal[WalkerLeg_FrontLeft]=(X=0.5f,Y=-0.866025f,Z=0.f)
	BaseLegDirLocal[WalkerLeg_FrontRight]=(X=0.5f,Y=0.866025f,Z=0.f)

	FootPosVelAdjScale[WalkerLeg_Rear]=1.2f
	FootPosVelAdjScale[WalkerLeg_FrontLeft]=0.6f
	FootPosVelAdjScale[WalkerLeg_FrontRight]=0.6f

	FootStepStartLift=512.f
	FootStepEndLift=128.f

	StepStageTimes(0)=0.7f			// foot pickup and move forward
	StepStageTimes(1)=0.135f		// foot stab to ground at destination
	StepStageTimes(2)=1.f			// wait for foot to reach dest before forcibly ending step

	MaxFootStepEffectDist=5000.0
}
