﻿/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class UTWeap_Avril extends UTWeapon
	native
	abstract;

/** A pointer to the currently controlled rocket */
var repnotify UTProj_AvrilRocketBase MyRocket;

/** If you shortcircut the reload, the time will get deferred until you bring the weapon back up */
var float DeferredReloadTime;

/** How long the reload sequence takes*/
var float ReloadTime;

/** How long the fire sequence takes*/
var float FireTime;

/** Animation to play when there is no ammo*/
var name NoAmmoWeaponPutDownAnim;

/** Anim to play while reloading */
var name WeaponReloadAnim;
var AudioComponent ReloadSound;
var SoundCue ReloadCue;

/** set when holding altfire for targeting laser (can't use normal state system because it can fire simultaneously with primary) */
var bool bTargetingLaserActive;

/** component for the laser effect */
var ParticleSystemComponent LaserEffect;

/** laser sounds */
var SoundCue TargetingLaserStartSound, TargetingLaserStopSound, TargetingLaserAmbientSound;

/** list of known mines/rockets to affect */
var array<UTProjectile> TargetedProjectiles;

/** last time TargetedProjectiles list was updated */
var float LastTargetedProjectilesCheckTime;

/** the maximum number of projectiles we're allowed to control simultaneously */
var int MaxControlledProjectiles;

/** The speed of a deferred reload */
var float ReloadAnimSpeed;

/*********************************************************************************************
 * Weapon lock on support
 ********************************************************************************************* */

/** The frequency with which we will check for a lock */
var(Locking) float		LockCheckTime;

/** How far out should we be considering actors for a lock */
var(Locking) int		LockRange;

/** How long does the player need to target an actor to lock on to it*/
var(Locking) float		LockAcquireTime;

/** Once locked, how long can the player go without painting the object before they lose the lock */
var(Locking) float		LockTolerance;

/** When true, this weapon is locked on target */
var bool 				bLockedOnTarget;

/** What "target" is this weapon locked on to */
var repnotify Actor 			LockedTarget;

/** What "target" is current pending to be locked on to */
var Actor				PendingLockedTarget;

/** How long since the Lock Target has been valid */
var float  				LastLockedOnTime;

/** When did the pending Target become valid */
var float				PendingLockedTargetTime;

/** When was the last time we had a valid target */
var float				LastValidTargetTime;

/** angle for locking for lock targets */
var float 				LockAim;

/** angle for locking for lock targets when on Console */
var float 				ConsoleLockAim;

/** Sound Effects to play when Locking */
var SoundCue 			LockAcquiredSound;
var SoundCue			LockLostSound;

/** If true, weapon will try to lock onto targets */
var bool bTargetLockingActive;

/** Last time target lock was checked */
var float LastTargetLockCheckTime;

//*********************************************************************************************



replication
{
	if (bNetDirty)
		MyRocket, DeferredReloadTime, bLockedOnTarget, LockedTarget;
}

function float RelativeStrengthVersus(Pawn P, float Dist)
{
	return CanLockOnTo(P) ? 0.75 : 0.0;
}

simulated function AttachWeaponTo(SkeletalMeshComponent MeshCpnt, optional Name SocketName)
{
	local SkeletalMeshComponent SkelMesh;

	SkelMesh = SkeletalMeshComponent(Mesh);
	if (LaserEffect != None && SkelMesh != None)
	{
		SkelMesh.AttachComponentToSocket(LaserEffect, 'BeamStart');
	}

	Super.AttachWeaponTo(MeshCpnt, SocketName);
}

simulated function ReplicatedEvent(name VarName)
{
	if (VarName == 'MyRocket')
	{
		if (MyRocket == None && !HasAnyAmmo())
		{
			WeaponEmpty();
		}
	}
	else if (VarName == 'LockedTarget')
	{
		CheckLockZoom();
	}
	Super.ReplicatedEvent(VarName);
}

simulated function Projectile ProjectileFire()
{
	if (Role == ROLE_Authority && MyRocket != None && MyRocket.LockingWeapon == self)
	{
		MyRocket.SetTarget(None, self);
		MyRocket = None;
   	}

	MyRocket = UTProj_AvrilRocketBase(Super.ProjectileFire());
	if (MyRocket != None )
	{
		MyRocket.MyWeapon = self;
		SetTimer(0.2, false, 'SetRocketTarget');
	}

	return MyRocket;
}

function SetRocketTarget()
{
	if ( (MyRocket != None) && !MyRocket.bDeleteMe )
	{
		MyRocket.SetTarget(LockedTarget, self);
	}
}

/**
 * We override TryPutDown so that we can store the deferred amount of time.
 */
simulated function bool TryPutDown()
{
	local float MinTimerTarget;
	local float TimerRate;
	local float TimerCount;

	bWeaponPutDown = true;

	TimerRate = GetTimerRate('RefireCheckTimer');
	if ( TimerRate > 0 )
	{
		MinTimerTarget = TimerRate * MinReloadPct[CurrentFireMode];
		TimerCount = GetTimerCount('RefireCheckTimer');

		if (TimerCount > MinTimerTarget)
		{
			DeferredReloadTime = TimerRate - TimerCount;
			PutDownWeapon();
			return true;
		}
		else
		{
			// Shorten the wait time
			SetTimer( MinTimerTarget - TimerCount , false, 'RefireCheckTimer');
			DeferredReloadTime = TimerRate - MinTimerTarget - (MinTimerTarget - TimerCount);
			return true;
		}
	}
	else
	{
		DeferredReloadTime = 0;
		return true;
	}

	return false;
}

simulated function float GetEquipTime()
{
	local float NewEquipTime;
	NewEquipTime = Super.GetEquipTime();

	if (DeferredReloadTime > NewEquipTime)
	{
		NewEquipTime = DeferredReloadTime;
	}

	DeferredReloadTime = 0;

	return NewEquipTime;
}

simulated function PlayWeaponEquip()
{
	ReloadAnimSpeed =GetTimerRate('WeaponEquipped') - GetTimerCount('WeaponEquipped') - super.GetEquipTime();
	super.PlayWeaponEquip();
	if(ReloadAnimSpeed > 0)
	{
		setTimer(EquipTime,false,'FastReload');
	}
}
simulated function FastReload()
{
	PlayReloadAnim(ReloadAnimSpeed);
	ReloadAnimSpeed=0.0f;
}

native function UpdateLockTarget(Actor NewLockTarget);

/**
 *  This function is used to adjust the LockTarget.
 *  Called by UpdateLockTarget() only when NewLockTarget is different from LockTarget
 */
event AdjustLockTarget(actor NewLockTarget)
{
	if ( (NewLockTarget == None) || NewLockTarget.bDeleteMe )
	{
		// Clear the lock
		if (bLockedOnTarget)
		{
			LockedTarget = None;

			bLockedOnTarget = false;

			if (LockLostSound != None && Instigator != None && Instigator.IsHumanControlled() )
			{
				PlayerController(Instigator.Controller).ClientPlaySound(LockLostSound);
			}
		}
	}
	else
	{
		// Set the lcok
		bLockedOnTarget = true;
		LockedTarget = NewLockTarget;
		if ( LockAcquiredSound != None && Instigator != None  && Instigator.IsHumanControlled() )
		{
			PlayerController(Instigator.Controller).ClientPlaySound(LockAcquiredSound);
		}
	}

	CheckLockZoom();

	if (MyRocket != none)
	{
		MyRocket.SetTarget(NewLockTarget, self);
	}
}

/** called when locked target changes, check if we should start or stop the zooming due to the target change */
simulated function CheckLockZoom()
{
	local EZoomState ZoomState;

	if (Instigator != None)
	{
		ZoomState = GetZoomedState();
		if (LockedTarget != None)
		{
			if (ZoomState == ZST_NotZoomed && PendingFire(1))
			{
				CheckZoom(1);
			}
		}
		else if (ZoomState != ZST_NotZoomed && UTPlayerController(Instigator.Controller) != None)
		{
			EndZoom(UTPlayerController(Instigator.Controller));
		}
	}
}

/**
 * Given an actor (TA) determine if we can lock on to it.  By default only allow locking on
 * to pawns.  Some weapons may want to be able to lock on to other actors.
 */
native function bool CanLockOnTo(Actor TA);

simulated event Destroyed()
{
	AdjustLockTarget(none);
	super.Destroyed();
}

simulated function bool PassThroughDamage(Actor HitActor)
{
	return ((HitActor == MyRocket && MyRocket != None) || Super.PassThroughDamage(HitActor));
}

simulated function WeaponCalcCamera(float fDeltaTime, out vector out_CamLoc, out rotator out_CamRot)
{
	local EZoomState ZoomState;

	if (LockedTarget != None)
	{
		ZoomState = GetZoomedState();
		if (ZoomState == ZST_ZoomingIn || ZoomState == ZST_Zoomed)
		{
			out_CamRot = rotator(LockedTarget.GetTargetLocation() - Instigator.GetPawnViewLocation());
			Instigator.Controller.SetRotation(out_CamRot);
		}
	}
}

simulated event SetPosition(UTPawn Holder)
{
	local EZoomState ZoomState;

	// if locked, make sure rotation is up to date for weapon position calculation
	if (Holder.Controller != None && LockedTarget != None)
	{
		ZoomState = GetZoomedState();
		if (ZoomState == ZST_ZoomingIn || ZoomState == ZST_Zoomed)
		{
			Holder.Controller.SetRotation(rotator(LockedTarget.GetTargetLocation() - Instigator.GetPawnViewLocation()));
		}
	}

	Super.SetPosition(Holder);
}

function RocketDestroyed(UTProj_AvrilRocketBase Rocket)
{
	if (Rocket == MyRocket)
	{
		MyRocket = none;
	}

	if (!HasAnyAmmo() )
	{
		WeaponEmpty();
	}
}

/**
 * Draw the Avril hud
 */
simulated function ActiveRenderOverlays( HUD H )
{
	super.ActiveRenderOverlays(H);

	if (bLockedOnTarget)
	{
		DrawLockedOn( H );
	}
	else
	{
		bWasLocked = false;
	}
}

// AI Interface
function float SuggestAttackStyle()
{
	return -0.4;
}

function float SuggestDefenseStyle()
{
	return 0.5;
}

function byte BestMode()
{
	return 0;
}

function float GetAIRating()
{
	local UTBot B;
	local float ZDiff, Dist, Result;

	B = UTBot(Instigator.Controller);
	if (B == None || B.Enemy == None)
	{
		return AIRating;
	}
	if (B.Focus != None && B.Focus.IsA('UTProj_SPMACamera'))
	{
		return 2;
	}

	if (Vehicle(B.Enemy) == None)
	{
		return 0.0;
	}

	Result = AIRating;
	ZDiff = Instigator.Location.Z - B.Enemy.Location.Z;
	if (ZDiff < -200.0)
	{
		Result += 0.1;
	}
	Dist = VSize(B.Enemy.Location - Instigator.Location);
	if (Dist > 2000.0)
	{
		return FMin(2.0, Result + (Dist - 2000.0) * 0.0002);
	}

	return Result;
}

function bool RecommendRangedAttack()
{
	local UTBot B;

	B = UTBot(Instigator.Controller);
	if (B == None || B.Enemy == None)
	{
		return true;
	}

	return (VSize(B.Enemy.Location - Instigator.Location) > 2000.0 * (1.0 + FRand()));
}
// end AI Interface

simulated function WeaponEmpty()
{
	// If we were firing, stop
	if (IsFiring())
	{
		GotoState('Active');
	}

	if ( Instigator != none && Instigator.IsLocallyControlled() && MyRocket == None)
	{
		Instigator.InvManager.SwitchToBestWeapon( true );
	}
}

/** updates the location for the targeting laser and notifies any spider mines or AVRiL rockets in the vacinity */
simulated function UpdateTargetingLaser()
{
	local vector TargetLocation, StartTrace, EndTrace;
	local ImpactInfo Impact;
	local UTProj_AvrilRocketBase Rocket;
	local UTProj_SpiderMineBase Mine;
	local int i, NumControlled;
	local array<UTSpiderMineTrap> Traps;

	// if we have a locked target, just go to that
	if (LockedTarget != None)
	{
		TargetLocation = LockedTarget.GetTargetLocation(Instigator);
	}
	else
	{
		// we have to trace to find out what we're hitting
		StartTrace = Instigator.GetWeaponStartTraceLocation();
		EndTrace = StartTrace + vector(GetAdjustedAim(StartTrace)) * LockRange;
		Impact = CalcWeaponFire(StartTrace, EndTrace);
		TargetLocation = Impact.HitLocation;
	}

	// update beam effect
	LaserEffect.SetVectorParameter('BeamEnd', TargetLocation);

	// notify mines and rockets
	if (Role == ROLE_Authority)
	{
		SetFlashLocation(TargetLocation);

		if (WorldInfo.TimeSeconds - LastTargetedProjectilesCheckTime >= 0.5)
		{
			FindTargetedProjectiles(TargetLocation, Traps);
		}

		for (i = 0; i < TargetedProjectiles.length && NumControlled < MaxControlledProjectiles; i++)
		{
			Rocket = UTProj_AvrilRocketBase(TargetedProjectiles[i]);
			if (Rocket != None)
			{
				// rockets only get notification of target locks
				if (Rocket.MyWeapon != self && LockedTarget != None && Rocket.SetTarget(LockedTarget, self))
				{
					NumControlled++;
				}
			}
			else
			{
				Mine = UTProj_SpiderMineBase(TargetedProjectiles[i]);
				if (Mine != None && Mine.SetScurryTarget(TargetLocation, Instigator))
				{
					NumControlled++;
				}
			}
		}
		// if we still have room to control more projectiles, ask traps to spawn mines
		for (i = 0; i < Traps.length && NumControlled < MaxControlledProjectiles; i++)
		{
			Mine = Traps[i].SpawnMine(None, Normal(TargetLocation - Instigator.Location));
			if (Mine != None && Mine.SetScurryTarget(TargetLocation, Instigator))
			{
				NumControlled++;
			}
		}
	}
}

/** called on a timer to fill the list of projectiles affected by the targeting laser */
function FindTargetedProjectiles(vector TargetLocation, out array<UTSpiderMineTrap> Traps)
{
	local Actor A;
	local UTSpiderMineTrap Trap;

	TargetedProjectiles.length = 0;
	foreach DynamicActors(class'Actor', A)
	{
		if (A.IsA('UTProj_SpiderMineBase') || A.IsA('UTProj_AvrilRocketBase'))
		{
			TargetedProjectiles[TargetedProjectiles.length] = UTProjectile(A);
		}
		else
		{
			Trap = UTSpiderMineTrap(A);
			if ( Trap != None && (Instigator.Controller == Trap.InstigatorController || WorldInfo.GRI.OnSameTeam(Trap, Instigator)) &&
				FastTrace(TargetLocation, A.Location + vect(0,0,32)) )
			{
				// spider mine trap spawns mines to follow target if they can see it
				Traps[Traps.length] = Trap;
			}
		}
	}

	LastTargetedProjectilesCheckTime = WorldInfo.TimeSeconds;
}

simulated function Tick(float DeltaTime)
{
	Super.Tick(DeltaTime);

	if (bTargetingLaserActive)
	{
		UpdateTargetingLaser();
	}
}

simulated function BeginFire(byte FireModeNum)
{
	local UTPawn P;

	if (FireModeNum == 1 && !bTargetingLaserActive && bReadyToFire())
	{
		// targeting laser altfire
		bTargetingLaserActive = true;
		UpdateTargetingLaser();
		LaserEffect.ActivateSystem();
		WeaponPlaySound(TargetingLaserStartSound);
		P = UTPawn(Instigator);
		if (P != None)
		{
			P.SetWeaponAmbientSound(TargetingLaserAmbientSound);
		}
	}
	Super.BeginFire(FireModeNum);
}

simulated function EndFire(byte FireModeNum)
{
	local UTPlayerController PC;
	local int i;
	local UTProj_AvrilRocketBase Rocket;
	local UTPawn P;

	if (FireModeNum == 1 && bTargetingLaserActive)
	{
		// targeting laser altfire
		bTargetingLaserActive = false;
		LaserEffect.DeactivateSystem();
		WeaponPlaySound(TargetingLaserStopSound);
		ClearFlashLocation();
		P = UTPawn(Instigator);
		if (P != None)
		{
			P.SetWeaponAmbientSound(None);
		}
		// lose target lock on any rockets we were controlling
		for (i = 0; i < TargetedProjectiles.length; i++)
		{
			Rocket = UTProj_AvrilRocketBase(TargetedProjectiles[i]);
			if (Rocket != None && Rocket.LockingWeapon == self && Rocket.MyWeapon != self)
			{
				Rocket.SetTarget(None, self);
			}
		}
		TargetedProjectiles.length = 0;
	}

	PC = UTPlayerController(Instigator.Controller);
	if (PC != None && LocalPlayer(PC.Player) != none && FireModeNum < bZoomedFireMode.Length && bZoomedFireMode[FireModeNum] != 0)
	{
		if ( GetZoomedState() != ZST_NotZoomed )
		{
			PC.EndZoom();
		}
	}
	Super(Weapon).EndFire(FireModeNum);
}

simulated function bool CheckZoom(byte FireModeNum)
{
	return ((bLockedOnTarget && GetZoomedState() == ZST_NotZoomed) ? Super.CheckZoom(FireModeNum) : false);
}

simulated function PlayFireEffects( byte FireModeNum, optional vector HitLocation )
{
	local float TotalFireTime;

	if (IsZero(HitLocation))
	{
		// rocket fired

		// Play Weapon fire animation
		if ( FireModeNum < WeaponFireAnim.Length && WeaponFireAnim[FireModeNum] != '' )
		{
			TotalFireTime = FireTime*((UTPawn(Owner)!= None) ? UTPawn(Owner).FireRateMultiplier : 1.0);
			PlayWeaponAnimation( WeaponFireAnim[FireModeNum], TotalFireTime);
			PlayArmAnimation(WeaponFireAnim[FireModeNum], TotalFireTime, false);
			SetTimer(TotalFireTime,false,'PlayReloadAnim');
		}

		// Start muzzle flash effect
		CauseMuzzleFlash();

		ShakeView();
	}
}

simulated function PlayReloadAnim(optional float ReloadOverrideTime)
{
	local float ReloadFinal;
	if(AmmoCount > 0)
	{
		if (ReloadOverrideTime != 0.0)
		{
			ReloadFinal = ReloadOverrideTime;
		}
		else
		{
			ReloadFinal = ReloadTime;
			if (UTPawn(Owner) != None)
			{
				ReloadFinal *= UTPawn(Owner).FireRateMultiplier;
			}
		}
		PlayWeaponAnimation(WeaponReloadAnim,ReloadFinal);
		PlayArmAnimation(WeaponReloadAnim,ReloadFinal);
		if(ReloadSound == none)
		{
			ReloadSound = CreateAudioComponent(ReloadCue, false, true);
		}
		if(ReloadSound != none)
		{
			ReloadSound.PitchMultiplier = ReloadTime/ReloadFinal;
			ReloadSound.Play();
		}
	}
}

simulated function PlayWeaponPutDown()
{
	if(ReloadSound != none)
	{
		ReloadSound.FadeOut(0.1,0.0);
		ReloadSound = none;
	}
	if(AmmoCount > 0)
		WeaponPutDownAnim = default.WeaponPutDownAnim;
	else
		WeaponPutDownAnim = NoAmmoWeaponPutDownAnim;
	super.PlayWeaponPutDown();
}

simulated function PutDownWeapon()
{
	EndFire(1); // Stop the laser beam
	super.PutDownWeapon();
}

/*********************************************************************************************
 * Target Locking
 *********************************************************************************************/

/**
 * The function checks to see if we are locked on a target
 */
native function CheckTargetLock();

simulated function GetWeaponDebug( out Array<String> DebugInfo )
{
	Super.GetWeaponDebug(DebugInfo);

	DebugInfo[DebugInfo.Length] = "Locked: "@bLockedOnTarget@LockedTarget@LastLockedontime@(WorldInfo.TimeSeconds-LastLockedOnTime);
	DebugInfo[DebugInfo.Length] = "Pending:"@PendingLockedTarget@PendingLockedTargetTime@WorldInfo.TimeSeconds;
}

auto simulated state Inactive
{
	simulated event BeginState(name PreviousStateName)
	{
		// make sure targeting laser got turned off
		if (bTargetingLaserActive)
		{
			EndFire(1);
		}

		Super.BeginState(PreviousStateName);

		if ( Role == ROLE_Authority )
		{
			bTargetLockingActive = false;
			AdjustLockTarget(None);
		}
	}

	simulated event EndState(Name NextStateName)
	{
		Super.EndState(NextStateName);

		if ( Role == ROLE_Authority )
		{
			bTargetLockingActive = true;
		}
	}
}

//*********************************************************************************************

state Active
{
	simulated function bool ShouldLagRot()
	{
		return (!bTargetingLaserActive && MyRocket == None);
	}
}

simulated state WeaponFiring
{
	simulated event EndState( Name NextStateName )
	{
		// do not call ClearFlashLocation() here as that is for the beam which may still be firing

		// Set weapon as not firing
		ClearFlashCount();
		ClearTimer('RefireCheckTimer');

		if (Instigator != none && AIController(Instigator.Controller) != None)
		{
			AIController(Instigator.Controller).NotifyWeaponFinishedFiring(self,CurrentFireMode);
		}
	}
}

simulated state WeaponEquipping
{
	simulated function bool TryPutDown()
	{
		local float EquipTimeRemaining;

		// make sure aborting an equip won't cancel any extra time due to reloading
		EquipTimeRemaining = GetTimerRate('WeaponEquipped') - GetTimerCount('WeaponEquipped');
		if (EquipTimeRemaining > EquipTime)
		{
			DeferredReloadTime = EquipTimeRemaining;
		}

		return Super.TryPutDown();
	}
}

defaultproperties
{
	WeaponColor=(R=255,G=0,B=0,A=255)
	FireInterval(0)=+4.0
	FireInterval(1)=+0.0
	ReloadTime=3.0
	FireTime=1.0
	MaxControlledProjectiles=8
	PlayerViewOffset=(X=0.0,Y=0.0,Z=-0.0)
 	WeaponFireTypes(0)=EWFT_Projectile
	WeaponFireTypes(1)=EWFT_None

	ShotCost(1)=0
	MaxDesireability=0.7
	AIRating=+0.55
	CurrentRating=+0.55
	bInstantHit=false
	bSplashJump=true
	bRecommendSplashDamage=false
	bSniping=false
	bLeadTarget=false
	bWarnIfInLocker=true

	ShouldFireOnRelease(0)=1
	InventoryGroup=10
	GroupWeight=0.6

	AmmoCount=5
	LockerAmmoCount=5
	LockerRotation=(pitch=0,yaw=0,roll=-16384)
	MaxAmmoCount=15
	FireOffset=(X=16,Y=8,Z=-5)

	MinReloadPct(0)=0.15
	MinReloadPct(1)=0.15

	bZoomedFireMode(0)=0
	bZoomedFireMode(1)=1

	ZoomedTargetFOV=40.0
	ZoomedRate=200

	LockAim=0.996
	ConsoleLockAim=0.992
	LockChecktime=0.05
	LockRange=22000
	LockAcquireTime=0.05
	LockTolerance=0.4

	IconX=460
	IconY=343
	IconWidth=29
	IconHeight=47

	EquipTime=0.75
	PutDownTime=0.45
	CrossHairCoordinates=(U=384,V=64,UL=64,VL=64)
	IconCoordinates=(U=728,V=427,UL=145,VL=52)
	QuickPickGroup=1
	QuickPickWeight=0.9

	MaxPitchLag=300
	MaxYawLag=400

	MuzzleFlashLightClass=class'UTGame.UTRocketMuzzleFlashLight'

	TickGroup=TG_PostAsyncWork
}
