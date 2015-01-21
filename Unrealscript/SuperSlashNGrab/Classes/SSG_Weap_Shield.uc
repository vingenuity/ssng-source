class SSG_Weap_Shield extends SSG_Weap_Base;

//----------------------------------------------------------------------------------------------------------
var bool bIsActive;
var bool bIsShieldOut;
var int NumBeginFireCalls;
var name ShieldPullOutAnimationName;
var name ShieldHoldAnimationName;


//----------------------------------------------------------------------------------------------------------
simulated function CustomFire()
{
	return;
}


//----------------------------------------------------------------------------------------------------------
simulated function bool ShouldRefire()
{
	return bIsActive;
}


//----------------------------------------------------------------------------------------------------------
function RemoveShield()
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
simulated function FireAmmunition()
{
	if( bIsShieldOut )
	{
		bLoopAnimation = true;
		PawnAttackFullBodyAnimationName = ShieldHoldAnimationName;
		PawnAttackUpperBodyAnimationName = ShieldHoldAnimationName;
	}
	else
	{
		bIsShieldOut = true;
		bLoopAnimation = false;
		PawnAttackFullBodyAnimationName = ShieldPullOutAnimationName;
		PawnAttackUpperBodyAnimationName = ShieldPullOutAnimationName;
	}

	Super.FireAmmunition();
}


//----------------------------------------------------------------------------------------------------------
simulated function BeginFire( Byte FireModeNum )
{
	local SSG_Pawn SSGP;

	Super.BeginFire( FireModeNum );

	SSGP = SSG_Pawn( Instigator );
	if( SSGP != None )
	{
		SSGP.bIsShielding = true;
	}

	bIsActive = true;
	++NumBeginFireCalls;
}


//----------------------------------------------------------------------------------------------------------
simulated function EndFire( byte FireModeNum )
{
	local SSG_Pawn SSGP;

	Super.EndFire( FireModeNum );

	SSGP = SSG_Pawn( Instigator );
	if( SSGP != None )
	{
		SSGP.bIsShielding = false;
	}

	bIsActive = false;
	bIsShieldOut = false;

	if( NumBeginFireCalls == 1 )
		RemoveShield();

	NumBeginFireCalls = 0;
}


//----------------------------------------------------------------------------------------------------------
function name GetDesiredSocketName()
{
	return class'SSG_Pawn'.default.WeaponSocket2;
}


//----------------------------------------------------------------------------------------------------------
simulated state WeaponFiring
{
	//----------------------------------------------------------------------------------------------------------
	simulated event EndState( name NextStateName )
	{
		Super.EndState( NextStateName );
		RemoveShield();
	}
}


//----------------------------------------------------------------------------------------------------------
DefaultProperties
{
	WeaponID=ID_Shield
	bIsActive=false
	bIsShieldOut=false
	NumBeginFireCalls=0

	FiringStatesArray(0)=WeaponFiring
	FiringStatesArray(1)=WeaponFiring

	WeaponFireTypes(0)=EWFT_Custom
	WeaponFireTypes(1)=EWFT_Custom

	FireInterval(0)=+0.2
	FireInterval(1)=+0.2

	EquipTime=+0.0
	PutDownTime=+0.0

	LockerOffset=(X=60.0,Y=20.0,Z=-20.0)
	LockerRotation=(Yaw=16384,Pitch=4096)

	PawnAttackFullBodyAnimationName=None
	PawnAttackUpperBodyAnimationName=None
	ShieldPullOutAnimationName=SSG_Animations_Character_Shield_Torso_01
	ShieldHoldAnimationName=SSG_Animations_Character_ShieldLoop_Torso_01
	AnimationPlaySpeed=1.0

	Begin Object Name=WeapSkeletalMeshComponent
		CollideActors=true
		BlockActors=true
		Scale=1.5
		Rotation=(Yaw=32768,Pitch=16384)
		SkeletalMesh=SkeletalMesh'SSG_Weapons.Shield.SSG_Weapon_Shield_01'
	  	PhysicsAsset=PhysicsAsset'SSG_Weapons.Shield.SSG_Weapon_Shield_01_Physics'
	End Object
}
