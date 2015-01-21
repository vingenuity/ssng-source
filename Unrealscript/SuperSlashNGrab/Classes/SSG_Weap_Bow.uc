class SSG_Weap_Bow extends SSG_Weap_Base;

//----------------------------------------------------------------------------------------------------------
var int NumBeginFireCalls;
var float ArrowKnockbackAmount;
var float ArrowFireAngleDegrees;
var class<Projectile> FrostPlayerProjectile;

const NUM_ARROW_FIRE_IN_CIRCLE = 8;


//----------------------------------------------------------------------------------------------------------
reliable client function ClientGivenTo( Pawn NewOwner, bool bDoNotActivate )
{
	local SSG_Pawn SSGP;
	
	super.ClientGivenTo( NewOwner, bDoNotActivate );
	
	SSGP = SSG_Pawn( NewOwner );
	
	if( SSGP != none && SSGP.Mesh.GetSocketByName( SSGP.WeaponSocket ) != none )
	{
		if( SSGP.Controller == none || SSGP.Controller.IsA( 'SSG_PlayerController' ) )
			return;

		Mesh.SetShadowParent( SSGP.Mesh );
		Mesh.SetLightEnvironment( SSGP.LightEnvironment );
		SSGP.Mesh.AttachComponentToSocket( Mesh, SSGP.WeaponSocket );
	}
}


//----------------------------------------------------------------------------------------------------------
function class<Projectile> GetProjectileClass()
{
	local SSG_Pawn      SSGP;

	SSGP = SSG_Pawn( Instigator );
	if( SSGP != None && SSGP.PawnSpeedScale == class'SSG_Pawn'.const.FROST_SPEED_SCALE )
		return FrostPlayerProjectile;

	return Super.GetProjectileClass();
}


//----------------------------------------------------------------------------------------------------------
simulated function Projectile ProjectileFire()
{
	local Vector		StartTrace, EndTrace, RealStartLoc, AimDir, AimDirOffset;
	local Rotator       ProjectileRotationOffset;
	local ImpactInfo	TestImpact;
	local Projectile	SpawnedProjectile1, SpawnedProjectile2, SpawnedProjectile3;
	local SSG_Pawn      SSGP;

	SSGP = SSG_Pawn( Instigator );
	if( SSGP == None )
		return None;

	// tell remote clients that we fired, to trigger effects
	IncrementFlashCount();

	if( Role == ROLE_Authority )
	{
		// This is where we would start an instant trace. (what CalcWeaponFire uses)
		StartTrace = Instigator.GetWeaponStartTraceLocation();
		AimDir = Vector(GetAdjustedAim( StartTrace ));

		// this is the location where the projectile is spawned.
		RealStartLoc = GetPhysicalFireStartLoc(AimDir);

		if( StartTrace != RealStartLoc )
		{
			// if projectile is spawned at different location of crosshair,
			// then simulate an instant trace where crosshair is aiming at, Get hit info.
			EndTrace = StartTrace + AimDir * GetTraceRange();
			TestImpact = CalcWeaponFire( StartTrace, EndTrace );

			// Then we realign projectile aim direction to match where the crosshair did hit.
			AimDir = Normal(TestImpact.HitLocation - RealStartLoc);
		}

		// Spawn projectile
		SpawnedProjectile1 = Spawn(GetProjectileClass(), Self,, RealStartLoc);
		if( SpawnedProjectile1 != None && !SpawnedProjectile1.bDeleteMe )
		{
			SpawnedProjectile1.Init( AimDir );
		}

		if( SSGP.Controller.IsA( 'SSG_PlayerController' ) )
		{
			SpawnedProjectile2 = Spawn(GetProjectileClass(), Self,, RealStartLoc);
			if( SpawnedProjectile2 != None && !SpawnedProjectile2.bDeleteMe )
			{
				ProjectileRotationOffset = Rotator( AimDir );
				ProjectileRotationOffset.Yaw += DegToUnrRot * ArrowFireAngleDegrees;
				AimDirOffset = Vector( ProjectileRotationOffset );

				SpawnedProjectile2.Init( AimDirOffset );
			}

			SpawnedProjectile3 = Spawn(GetProjectileClass(), Self,, RealStartLoc);
			if( SpawnedProjectile3 != None && !SpawnedProjectile3.bDeleteMe )
			{
				ProjectileRotationOffset = Rotator( AimDir );
				ProjectileRotationOffset.Yaw += DegToUnrRot * -ArrowFireAngleDegrees;
				AimDirOffset = Vector( ProjectileRotationOffset );

				SpawnedProjectile3.Init( AimDirOffset );
			}

			if( SSGP.bArrowCircle )
			{
				FireCircleOfArrows( AimDir, RealStartLoc );
			}
		}

		// Return it up the line
		return SpawnedProjectile1;
	}

	return None;
}


//----------------------------------------------------------------------------------------------------------
function FireCircleOfArrows( Vector AimDir, Vector RealStartLoc )
{
	local int			i;
	local Vector		AimDirOffset;
	local Rotator		ProjectileRotationOffset;
	local Projectile	SpawnedProjectile;

	for( i = 1; i < NUM_ARROW_FIRE_IN_CIRCLE; ++i )
	{
		SpawnedProjectile = Spawn(GetProjectileClass(), Self,, RealStartLoc);
		if( SpawnedProjectile != None && !SpawnedProjectile.bDeleteMe )
		{
			ProjectileRotationOffset = Rotator( AimDir );
			ProjectileRotationOffset.Yaw += DegToUnrRot * ( i * ( 360.0 / NUM_ARROW_FIRE_IN_CIRCLE ) );
			AimDirOffset = Vector( ProjectileRotationOffset );

			SpawnedProjectile.Init( AimDirOffset );
		}
	}
}


//----------------------------------------------------------------------------------------------------------
simulated function FireAmmunition()
{
	local Vector ArrowKnockbackVec;

	Super.FireAmmunition();

	if( Instigator.Velocity == Vect( 0.0, 0.0, 0.0 ) )
	{
		ArrowKnockbackVec.X = -cos( UnrRotToRad * Instigator.Rotation.Yaw );
		ArrowKnockbackVec.Y = -sin( UnrRotToRad * Instigator.Rotation.Yaw );
		ArrowKnockbackVec.Z = 0.0;
		Instigator.Velocity = ArrowKnockbackAmount * ArrowKnockbackVec;
	}

	EndFire(0); //FIX: This is an ugly cludge.
}

//----------------------------------------------------------------------------------------------------------
simulated function bool ShouldRefire()
{
	return false;
}


//----------------------------------------------------------------------------------------------------------
function RemoveBow()
{
	local SSG_Pawn SSGP;
	local SSG_Weap_Sword Sword;

	SSGP = SSG_Pawn( Instigator );
	Sword = SSG_Weap_Sword( InvManager.FindInventoryType( class'SSG_Weap_Sword', false ) );
  	if( Sword != None )
  	{
		SSGP.Mesh.DetachComponent( Mesh );
		SSGP.Mesh.AttachComponentToSocket( Sword.Mesh, SSGP.WeaponSocket );
    	InvManager.SetCurrentWeapon( Sword );
  	}
}


//----------------------------------------------------------------------------------------------------------
simulated function BeginFire( Byte FireModeNum )
{
	Super.BeginFire( FireModeNum );

	++NumBeginFireCalls;
}


//----------------------------------------------------------------------------------------------------------
simulated function EndFire( byte FireModeNum )
{
	Super.EndFire( FireModeNum );

	if( NumBeginFireCalls == 1 )
		RemoveBow();

	NumBeginFireCalls = 0;
}


//----------------------------------------------------------------------------------------------------------
simulated event Vector GetPhysicalFireStartLoc(optional vector AimDir)
{
    local SkeletalMeshComponent AttachedMesh;
    local SkeletalMeshSocket MeshSocket;
 
    AttachedMesh = SkeletalMeshComponent(Mesh);
 
    if( AttachedMesh != none )
    {
        MeshSocket = AttachedMesh.GetSocketByName('MuzzleFlashSocket');
 
        if( MeshSocket != none )
        {
            return AttachedMesh.GetBoneLocation( MeshSocket.BoneName );
        }
    }
}


//----------------------------------------------------------------------------------------------------------
simulated state WeaponFiring
{
	//----------------------------------------------------------------------------------------------------------
	simulated event EndState( name NextStateName )
	{
		Super.EndState( NextStateName );
		RemoveBow();
	}
}


//----------------------------------------------------------------------------------------------------------
DefaultProperties
{
	WeaponID=ID_Crossbow
	FiringSound=SoundCue'SSG_WeaponSounds.Crossbow.CrossbowShootCue'

	NumBeginFireCalls=0
	ArrowKnockbackAmount=3000.0
	ArrowFireAngleDegrees=6.0

	SecondsBetweenFires=0.2

	FiringStatesArray(0)=WeaponFiring
	FiringStatesArray(1)=WeaponFiring

	WeaponFireTypes(0)=EWFT_Projectile
	WeaponFireTypes(1)=EWFT_Projectile

	WeaponProjectiles(0)=class'SSG_Proj_Arrow'
	WeaponProjectiles(1)=class'SSG_Proj_Arrow'

	FrostPlayerProjectile=class'SSG_Proj_Arrow_Slow'

	FireInterval(0)=+0.3141775
	FireInterval(1)=+0.3141775

	Spread(0)=0.0
	Spread(1)=0.0

	InstantHitDamageTypes(0)=class'DamageType'
	InstantHitDamageTypes(1)=class'DamageType'
	WeaponRange=22000

	//EffectSockets(0)=MuzzleFlashSocket
	//EffectSockets(1)=MuzzleFlashSocket
	//MuzzleFlashDuration=0.33

	//WeaponFireSnd(0)=none
	//WeaponFireSnd(1)=none

	//MinReloadPct(0)=0.6
	//MinReloadPct(1)=0.6

	//MuzzleFlashSocket=MuzzleFlashSocket

	ShouldFireOnRelease(0)=0
	ShouldFireOnRelease(1)=0

	//LockerRotation=(Pitch=16384)

	//WeaponColor=(R=255,G=255,B=255,A=255)
	//BobDamping=0.85000
	//JumpDamping=1.0
	//AimError=525
	//CurrentRating=+0.5
	MaxDesireability=0.5

	//IconX=458
	//IconY=83
	//IconWidth=31
	//IconHeight=45

	EquipTime=+0.0
	PutDownTime=+0.0

	//MaxPitchLag=600
	//MaxYawLag=800
	//RotChgSpeed=3.0
	//ReturnChgSpeed=3.0
	//AimingHelpRadius[0]=20.0
	//AimingHelpRadius[1]=20.0

	//WeaponCanvasXPct=0.35
	//WeaponCanvasYPct=0.35

	LockerOffset=(X=60.0,Y=20.0,Z=-20.0)
	LockerRotation=(Yaw=16384,Pitch=4096)

	//HiddenWeaponsOffset=(Y=-50.0,Z=-50.0)
	//ProjectileSpawnOffset=20.0
	//LastHitEnemyTime=-1000.0

	PawnAttackFullBodyAnimationName=SSG_Animations_Character_CrossbowAttack_FullBody_01
	PawnAttackUpperBodyAnimationName=SSG_Animations_Character_CrossbowAttack_Torso_01
	AnimationPlaySpeed=2.0
	AttackAnimationStartTime=0.35

	Begin Object Name=WeapSkeletalMeshComponent
		SkeletalMesh=SkeletalMesh'SSG_Weapons.Crossbow.SSG_Weapon_Crossbow_01'
		PhysicsAsset=PhysicsAsset'SSG_Weapons.Crossbow.SSG_Weapon_Crossbow_01_Physics'
		Scale = 1.0
		CastShadow=false
	End Object

	Begin Object Class=ForceFeedbackWaveform Name=ForceFeedbackWaveformShooting1
		Samples(0)=(LeftAmplitude=30,RightAmplitude=20,LeftFunction=WF_Constant,RightFunction=WF_Constant,Duration=0.100)
	End Object
	//WeaponFireWaveForm=ForceFeedbackWaveformShooting1
}
