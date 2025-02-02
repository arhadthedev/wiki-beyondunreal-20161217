﻿/**
 *
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class UTProj_SpiderMineBase extends UTProjectile
	native
	abstract;

var float DetectionTimer; // check target every this many seconds
/** check for targets within this many units of us */
var float DetectionRange;
/** extra range beyond DetectionRange in which we keep an already acquired target */
var float KeepTargetExtraRange;
var float ScurrySpeed, ScurryAnimRate;
var float HeightOffset;

var     Pawn    TargetPawn;
var     int     TeamNum;

var	bool	bClosedDown;
var	bool	bGoToTargetLoc;
var	vector	TargetLoc;
var	int	TargetLocFuzz;

var SkeletalMeshComponent Mesh;

/** the UTSpiderMineTrap that this mine is bound to. If it becomes None, the mine will blow itself up
 * The mine will return to it if it has nothing to do
 */
var UTSpiderMineTrap Lifeline;

/** mine starts returning to its trap (if it has one) after this many seconds of inactivity */
var float ReturnToTrapDelay;
/** set when mine is trying to return to its trap */
var bool bReturning;
/** set when the mine is being destroyed because it successfully returned to a trap (so don't play explosion effects) */
var bool bReturnedToTrap;

/** looping walk sound */
var AudioComponent WalkingSoundComponent;

/** The battle cry */
var AudioComponent AttackScreechSoundComponent;

/** Minimum floor normal.Z that spider can walk on */
var float MinSpiderFloorZ;



replication
{
	if (bNetInitial)
		KeepTargetExtraRange;
	if (bNetDirty)
		bGoToTargetLoc, bReturning, bReturnedToTrap;
	if (bNetDirty && (bGoToTargetLoc || bReturning))
		TargetLoc;
	if (bNetDirty && !bGoToTargetLoc && !bReturning)
		TargetPawn;
}

simulated function Destroyed()
{
	super.Destroyed();

	if ( LifeLine != None )
	{
		LifeLine.DeployedMines--;
	}
}

simulated function PlayAnim(name NewAnim, float Rate, optional bool bLooped)
{
	local AnimNodeSequence Sequence;

	// do not play on a dedicated server
	if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		// Check we have access to mesh and animations
		Sequence = AnimNodeSequence(Mesh.Animations);
		if (Mesh != None && Sequence != None)
		{
			// Set right animation sequence if needed
			if (Sequence.AnimSeq == None || Sequence.AnimSeq.SequenceName != NewAnim)
			{
				Sequence.SetAnim(NewAnim);
			}

			if (Sequence.AnimSeq == None)
			{
				`Warn("Animation" @ NewAnim @ "not found");
			}
			else if (!Sequence.bPlaying || Sequence.bLooping != bLooped || Sequence.Rate != Rate)
			{
				// Play Animation
				Sequence.PlayAnim(bLooped, Rate);
			}
		}
	}
}

simulated function StopAnim()
{
	// do not play on a dedicated server
	if ( WorldInfo.NetMode == NM_DedicatedServer )
		return;

	// Check we have access to mesh and animations
	if ( Mesh != None && AnimNodeSequence(Mesh.Animations) != None )
	{
		AnimNodeSequence(Mesh.Animations).StopAnim();
	}
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	if (Role < ROLE_Authority && Physics == PHYS_None)
	{
		bProjTarget = true;
		GotoState('OnGround');
	}

	PlayAnim('Wakeup', 1.0);
}

function Init(vector Direction)
{
	Super.Init(Direction);

	SetRotation(Rotation + rot(16384,0,0));
}

simulated event TornOff()
{
	if (bReturnedToTrap)
	{
		bSuppressExplosionFX = true;
	}
	Destroy();
}

simulated function ProcessTouch(Actor Other, Vector HitLocation, Vector HitNormal)
{
	ImpactedActor = Other;
	if (UTProj_SpiderMineBase(Other) != None)
	{
		if ( Other.Instigator != Instigator )
		{
			Explode(Location, HitNormal);
		}
		else if (Physics == PHYS_Falling)
			Velocity = vect(0,0,200) + 150 * VRand();
	}
	else if (Pawn(Other) != None)
	{
		if ( Other != Instigator && !WorldInfo.GRI.OnSameTeam(Instigator, Other) )
		{
			Explode(Location, HitNormal);
		}
	}
	else if (Other.bCanBeDamaged && Other.Base != self)
	{
		Explode(Location, HitNormal);
	}
	ImpactedActor = None;
}

simulated function AdjustSpeed()
{
	ScurrySpeed = default.ScurrySpeed / (Attached.length + 1);
	ScurryAnimRate = default.ScurryAnimRate / (Attached.length + 1);
}

simulated function Attach(Actor Other)
{
	AdjustSpeed();
}

simulated function Detach(Actor Other)
{
	AdjustSpeed();
}

simulated event byte ScriptGetTeamNum()
{
	return TeamNum;
}

function AcquireTarget()
{
	local Pawn A;
	local float Dist, BestDist;

	TargetPawn = None;

	foreach VisibleCollidingActors(class'Pawn', A, DetectionRange)
	{
		if ( A != Instigator && A.Health > 0 && !WorldInfo.GRI.OnSameTeam(A, self) && !A.IsA('UTVehicle_DarkWalker')
		 && (UTVehicle(A) == None || UTVehicle(A).Driver != None || UTVehicle(A).bTeamLocked) )
		{
			Dist = VSize(A.Location - Location);
			if (TargetPawn == None || Dist < BestDist)
			{
				TargetPawn = A;
				BestDist = Dist;
			}
		}
	}
}

function WarnTarget()
{
	if (TargetPawn != None && TargetPawn.Controller != None)
	{
		TargetPawn.Controller.ReceiveProjectileWarning(self);

		if (AIController(TargetPawn.Controller) != None && AIController(TargetPawn.Controller).Skill >= 5.0 && !TargetPawn.IsFiring())
		{
			TargetPawn.Controller.Focus = self;
			TargetPawn.Controller.FireWeaponAt(self);
		}
	}
}

event TakeDamage(int DamageAmount, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	if (DamageAmount > 0 && !WorldInfo.GRI.OnSameTeam(EventInstigator, self))
	{
		Explode(Location, Normal(Momentum));
	}
}

simulated function PhysicsVolumeChange(PhysicsVolume NewVolume)
{
	local UTSlowVolume SlowVolume;

	if (NewVolume.bPainCausing)
	{
		Explode(Location, vector(Rotation));
	}
	else
	{
		// check if left slow volume
		SlowVolume = UTSlowVolume(PhysicsVolume);
		if (SlowVolume != None)
		{
			ScurrySpeed /= SlowVolume.ScalingFactor;
			ScurryAnimRate /= SlowVolume.ScalingFactor;
		}

		// check if entered slow volume
		SlowVolume = UTSlowVolume(NewVolume);
		if (SlowVolume != None)
		{
			ScurrySpeed *= SlowVolume.ScalingFactor;
			ScurryAnimRate *= SlowVolume.ScalingFactor;
		}
	}
}

auto state Flying
{
	simulated event Landed( vector HitNormal, actor FloorActor )
	{
		local rotator NewRot;

		bProjTarget = True;

		NewRot = rotator(HitNormal);
		NewRot.Pitch -= 16384;
		SetRotation(NewRot);

		GotoState((TargetPawn != None) ? 'Scurrying' : 'OnGround');
	}

	simulated event HitWall( vector HitNormal, Actor Wall, PrimitiveComponent WallComp )
	{
		if ( Instigator != None && Pawn(Wall) != None )
		{
			if (!WorldInfo.GRI.OnSameTeam(Instigator, Wall))
			{
				ImpactedActor = Wall;
				Explode(Location, HitNormal);
				ImpactedActor = None;
			}
		}
		Velocity = 0.8 * (Velocity - 2.0 * HitNormal * (Velocity dot HitNormal));
		if ( HitNormal.Z > MinSpiderFloorZ )
		{
			Landed(HitNormal, Wall);
		}
	}

	simulated function BeginState(Name PreviousStateName)
	{
		SetPhysics(PHYS_Falling);
		Lifespan = 6.0;
	}
	
	simulated function EndState(Name NextStateName)
	{
		Lifespan = 0.0;
	}
}

simulated state OnGround
{
	ignores Landed, HitWall;

	simulated function Timer()
	{
		if (Role < ROLE_Authority)
		{
			if (TargetPawn != None)
			{
				GotoState('Scurrying');
			}
			else if (bGoToTargetLoc)
			{
				GotoState('ScurryToTargetLoc');
			}
			else if (bReturning)
			{
				GotoState('Returning');
			}

			return;
		}

		// if it has no lifeline (trap or player), die
		if (Lifeline == None || Lifeline.bDeleteMe)
		{
			Explode(Location, vector(Rotation));
		}

		AcquireTarget();

		if (TargetPawn != None)
		{
			GotoState('Scurrying');
		}
	}

	/** returns the spider mine to its trap, if it has one */
	function ReturnToTrap()
	{
		if (Lifeline == None || Lifeline.bDeleteMe)
		{
			Explode(Location, vector(Rotation));
		}
		else
		{
			GotoState('Returning');
		}
	}

	function bool SetScurryTarget(vector NewTargetLoc, Pawn NewInstigator)
	{
		local bool bResult;

		bResult = Global.SetScurryTarget(NewTargetLoc, NewInstigator);
		if (bResult && IsTimerActive('ReturnToTrap'))
		{
			// even if we ignored the target because we're already there, reset return time
			SetTimer(ReturnToTrapDelay, false, 'ReturnToTrap');
		}

		return bResult;
	}

	simulated function BeginState(Name PreviousStateName)
	{
		if (Role == ROLE_Authority && Lifeline != None)
		{
			SetTimer(ReturnToTrapDelay, false, 'ReturnToTrap');
		}
		SetPhysics(PHYS_None);
		Velocity = vect(0,0,0);
		SetTimer(DetectionTimer, True);
		Timer();
		LifeSpan = 2 * ReturnToTrapDelay;
	}

	simulated function EndState(Name NextStateName)
	{
		SetTimer(0, False);
		ClearTimer('ReturnToTrap');
		LifeSpan = 0.0;
	}

Begin:
	Sleep(0.4);
	PlayAnim('Sleep_Idle',1.0);
	bClosedDown = true;
}

simulated state Scurrying
{
	simulated function Timer()
	{
		local vector NewLoc;
		local rotator TargetDirection;
		local float TargetDist;

		if (TargetPawn == None || TargetPawn.bDeleteMe)
		{
			TargetPawn = None;
			GotoState('Flying');
		}
		else if (Physics == PHYS_Walking)
		{
			NewLoc = TargetPawn.Location - Location;
			TargetDist = VSize(NewLoc);

			if (TargetDist < DetectionRange + KeepTargetExtraRange)
			{
				NewLoc.Z = 0.f;
				Velocity = Normal(NewLoc) * ScurrySpeed;
				if (TargetDist < 225.0)
				{
					GotoState('Flying');
					Velocity *= 1.2;
					Velocity.Z = 350;

					//Play a nice screeching sound (not in WarnTarget because its meant only for on the 'jump')
					if (AttackScreechSoundComponent != none)
					{
					   AttackScreechSoundComponent.Play();
					}
			
					WarnTarget();
				}
				else
				{
					TargetDirection = Rotator(NewLoc);
					TargetDirection.Yaw -= 16384;
					TargetDirection.Roll = 0;
					SetRotation(TargetDirection);
					PlayAnim('RunFwd', ScurryAnimRate,true);
				}
			}
			else
			{
				TargetPawn = None;
				GotoState('Flying');
			}
		}
	}

	simulated event Landed(vector HitNormal, Actor FloorActor)
	{
		SetPhysics(PHYS_Walking);
		SetBase(FloorActor);
	}

	function BeginState(Name PreviousStateName)
	{
		WarnTarget();
	}

	simulated function EndState(Name NextStateName)
	{
		StopAnim();
		SetTimer(0.0, False);
		WalkingSoundComponent.Stop();
	}

Begin:
	SetPhysics(PHYS_Walking);
	if (bClosedDown)
	{
		PlayAnim('Wakeup', 1.0);
		bClosedDown = false;
		Sleep(0.25);
	}
	WalkingSoundComponent.Play();
	SetTimer(DetectionTimer * 0.5, true);
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	local int i;

	//make sure anything attached gets blown up too
	for (i = 0; i < Attached.length; i++)
	{
		Attached[i].TakeDamage(Damage, InstigatorController, Attached[i].Location, vect(0,0,0), MyDamageType,, self);
	}

	Super.Explode(HitLocation, HitNormal);
}

/** NewInstigator is asking the mine to go to NewTargetLoc
 * @return whether the mine will follow the request
 */
function bool SetScurryTarget(vector NewTargetLoc, Pawn NewInstigator)
{
	local bool bCanControl;

	if (TargetPawn == None)
	{
		bCanControl = WorldInfo.Game.bTeamGame ? WorldInfo.GRI.OnSameTeam(NewInstigator, self) : (InstigatorController == NewInstigator.Controller);
		if ( bCanControl && FastTrace(NewTargetLoc, Location + vect(0,0,32)) )
		{
			// give this player control of the mine
			Instigator = NewInstigator;
			InstigatorController = Instigator.Controller;

			if (VSize(NewTargetLoc - Location) > TargetLocFuzz)
			{
				TargetLoc = NewTargetLoc + VRand() * Rand(TargetLocFuzz);
				bGoToTargetLoc = true;
				GotoState('ScurryToTargetLoc');
			}
			return true;
		}
	}

	return false;
}

simulated state ScurryToTargetLoc extends Scurrying
{
	function bool SetScurryTarget(vector NewTargetLoc, Pawn NewInstigator)
	{
		if (Instigator == NewInstigator)
		{
			TargetLoc = NewTargetLoc + VRand() * Rand(TargetLocFuzz);
			return true;
		}
		else
		{
			return false;
		}
	}

	simulated function Timer()
	{
		local vector NewLoc;
		local rotator TargetDirection;

		if (Physics == PHYS_Walking)
		{
			NewLoc = TargetLoc - Location;
			NewLoc.Z = 0;
			if (VSize(NewLoc) < 250.f)
			{
				AcquireTarget();
				if (TargetPawn != None)
				{
					GotoState('Scurrying');
				}
				else
				{
					GotoState('Flying');
				}
			}
			else
			{
				Velocity = Normal(NewLoc) * ScurrySpeed;
				TargetDirection = rotator(NewLoc);
				TargetDirection.Yaw -= 16384;
				TargetDirection.Roll = 0;
				SetRotation(TargetDirection);
				PlayAnim('RunFwd', ScurryAnimRate,true);
			}
		}
	}

	simulated function EndState(Name NextStateName)
	{
		StopAnim();
		SetTimer(0.0, False);
		WalkingSoundComponent.Stop();
		bGoToTargetLoc = false;
	}
}

simulated singular event HitWall(vector HitNormal, actor Wall, PrimitiveComponent WallComp)
{
	if ( Instigator != None && Pawn(Wall) != None && !WorldInfo.GRI.OnSameTeam(Instigator, Wall) )
	{
		ImpactedActor = Wall;
		Explode(Location, HitNormal);
		ImpactedActor = None;
		return;
	}
	if ( HitNormal.Z > MinSpiderFloorZ )
	{
		SetPhysics(PHYS_Walking);
		SetBase(Wall);
		return;
	}
	if ( Physics == PHYS_Falling )
	{
		Velocity = 0.8 * (Velocity - 2.0 * HitNormal * (Velocity dot HitNormal));
	}
	LifeSpan = (LifeSpan == 0.0) ? 5.0 : FMin(LifeSpan, 5.0);
	SetPhysics(PHYS_Falling);
	Velocity.Z = 300.0;
}

simulated state Returning extends Scurrying
{
	event Bump(Actor Other, PrimitiveComponent OtherComp, vector HitNormal)
	{
		if (Other == Lifeline)
		{
			Lifeline.AvailableMines++;
			// destroy delayed (give time to replicate) and without explosion
			bReturnedToTrap = true;
			bSuppressExplosionFX = true;
			bWaitForEffects = true;
			ShutDown();
			LifeSpan = 1.0;
		}
	}

	simulated function Timer()
	{
		local vector NewLoc;
		local rotator TargetDirection;
		local float Dist;

		if (Physics == PHYS_Walking)
		{
			if (Role == ROLE_Authority && (Lifeline == None || Lifeline.bDeleteMe))
			{
				Explode(Location, vector(Rotation));
			}
			else
			{
				if (Role == ROLE_Authority && TargetLoc != Lifeline.Location)
				{
					TargetLoc = Lifeline.Location;
				}

				NewLoc = TargetLoc - Location;
				NewLoc.Z = 0;
				Dist = VSize(NewLoc);
				if ( Dist <= 24.0 )
				{
					if (Role == ROLE_Authority)
					{
						Bump(Lifeline, None, vect(0,0,1));
					}
				}
				else
				{

					if ( Dist < 200.0 )
					{
						Velocity = Normal(NewLoc) * 0.5*ScurrySpeed;
						if ( FRand() < 0.15 )
						{
							SetTimer(DetectionTimer * 0.25, true);
						}
					}
					else
					{
						Velocity = Normal(NewLoc) * ScurrySpeed;
					}
					TargetDirection = rotator(NewLoc);
					TargetDirection.Yaw -= 16384;
					TargetDirection.Roll = 0;
					SetRotation(TargetDirection);
					PlayAnim('RunFwd', ScurryAnimRate,true);
				}
			}
		}
	}

	simulated function BeginState(name PrevStateName)
	{
		Super.BeginState(PrevStateName);

		LifeSpan = 10.0;
		if (Role == ROLE_Authority)
		{
			bReturning = true;
			TargetLoc = Lifeline.Location;
		}
	}

	simulated function EndState(Name NextStateName)
	{
		LifeSpan = 0.0;
		SetTimer(0.0, false);
		bReturning = false;
	}
}

defaultproperties
{
	MinSpiderFloorZ=0.1
	Speed=800.0
	MaxSpeed=800.0
	ScurrySpeed=525.0
	ScurryAnimRate=1.0
	TossZ=0.0
	Damage=95.0
	DamageRadius=250.0
	MomentumTransfer=50000
	Physics=PHYS_Falling
	RotationRate=(Pitch=20000)
	DetectionTimer=0.50
	DetectionRange=750.0
	KeepTargetExtraRange=250.0
	bProjTarget=true
	bCollideWorld=True
	bBlockActors=true

	RemoteRole=ROLE_SimulatedProxy
	bNetTemporary=False
	bUpdateSimulatedPosition=True
	LifeSpan=0.0
	TargetLocFuzz=250
	ReturnToTrapDelay=5.0
	bSwitchToZeroCollision=false

	bBounce=True
	bHardAttach=True
}
