class SSG_Weap_Melee extends SSG_Weap_Base
	abstract;

var() const name HiltSocketName;
var() const name TipSocketName;
var name SwingFullBodyAnimationName1;
var name SwingFullBodyAnimationName2;
var name SwingUpperBodyAnimationName1;
var name SwingUpperBodyAnimationName2;

var array<Actor> SwingHitActors;
var array<int> Swings;
var const int MaxSwings;
var float WeapRangeUnrUnits;
var float SecondsSinceAttackBegin;
var float SecondsForEachHitSection;
var int NumChecksPerformed;
var bool bSwingTwice;
var bool bOnSecondSwing;
var bool bPlayedWallHitCue;
var float AttackCooldownSeconds;

var const int NumCheckHitSections;
var const float MinAttackAngle; // [-180, 180] where 0 is straight forward, 90 is to the left, -90 is to the right, +/-180 is directly behind
var const float MaxAttackAngle; // [-180, 180] where 0 is straight forward, 90 is to the left, -90 is to the right, +/-180 is directly behind

const PLAYER_HIT_RANGE_FORGIVENESS = 55.0;


//----------------------------------------------------------------------------------------------------------
simulated function CustomFire()
{
	IncrementFlashCount();
}


//----------------------------------------------------------------------------------------------------------
simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	SecondsForEachHitSection = FireInterval[0] / NumCheckHitSections;
}


//----------------------------------------------------------------------------------------------------------
function Tick( float DeltaTime )
{
	Super.Tick( DeltaTime );

	if( AttackCooldownSeconds > 0.0 )
	{
		AttackCooldownSeconds -= DeltaTime;
	}
}


//----------------------------------------------------------------------------------------------------------
function bool CheckAttackBlock( Actor BlockingActor )
{
	if( BlockingActor == None )
		return false;

	if( BlockingActor.IsA( 'WorldInfo' ) )
		return true;

	if( BlockingActor.IsA( 'StaticMeshActor' ) )
		return true;

	return false;
}


//----------------------------------------------------------------------------------------------------------
function RenderAttackParticle();


//----------------------------------------------------------------------------------------------------------
simulated function StartFire( byte FireModeNum )
{
	if( Swings[FireModeNum] == 0 || AttackCooldownSeconds > 0.0 )
		return;

	bSwingTwice = ( Swings[FireModeNum] == 1 );
	RenderAttackParticle();

	Super.StartFire( FireModeNum );
}


//----------------------------------------------------------------------------------------------------------
simulated function bool ShouldRefire()
{
	return bSwingTwice;
}


//----------------------------------------------------------------------------------------------------------
function RestoreAmmo( int Amount, optional byte FireModeNum )
{
	Swings[FireModeNum] = Min( Amount, MaxSwings );
}


//----------------------------------------------------------------------------------------------------------
function ConsumeAmmo( byte FireModeNum )
{
	if( HasAmmo( FireModeNum ) )
	{
	   --Swings[FireModeNum];
	}
}


//----------------------------------------------------------------------------------------------------------
simulated function bool HasAmmo( byte FireModeNum, optional int Ammount )
{
	return Swings[FireModeNum] > Ammount;
}


//----------------------------------------------------------------------------------------------------------
simulated function FireAmmunition()
{
	bPlayedWallHitCue = false;
	StopFire( CurrentFireMode );
	SwingHitActors.Remove( 0, SwingHitActors.Length );

	if( bSwingTwice )
	{
		bSwingTwice = false;
		bOnSecondSwing = true;
		SecondsSinceAttackBegin = 0.0;
		PawnAttackFullBodyAnimationName = SwingFullBodyAnimationName2;
		PawnAttackUpperBodyAnimationName = SwingUpperBodyAnimationName2;
	}
	else
	{
		bOnSecondSwing = false;
		PawnAttackFullBodyAnimationName = SwingFullBodyAnimationName1;
		PawnAttackUpperBodyAnimationName = SwingUpperBodyAnimationName1;
	}
	
	if( HasAmmo( CurrentFireMode ) )
	{
		Super.FireAmmunition();
	}
}


//----------------------------------------------------------------------------------------------------------
simulated state Swinging extends WeaponFiring
{
	//----------------------------------------------------------------------------------------------------------
	simulated event Tick( float DeltaTime )
	{
		Super.Tick( DeltaTime );
		//TraceSwing();
		PerformSwingSectionCheck( DeltaTime );
	}


	//----------------------------------------------------------------------------------------------------------
	simulated event BeginState( name PreviousStateName )
	{
		Super.BeginState( PreviousStateName );
		NumChecksPerformed = 0;
		SecondsSinceAttackBegin = 0.0;
	}
	

	//----------------------------------------------------------------------------------------------------------
	simulated event EndState( Name NextStateName )
	{
		Super.EndState( NextStateName );
		
		if( !bSwingTwice )
		{
			AttackCooldownSeconds = WEAPON_ANIM_BLEND_SECONDS;
			ResetSwings();
		}
	}
}


//----------------------------------------------------------------------------------------------------------
function ResetSwings()
{
	bSwingTwice = false;
	RestoreAmmo( MaxSwings );
}


//----------------------------------------------------------------------------------------------------------
function bool CheckSwingHitActors( Actor HitActor )
{
	local int i;
	
	for( i = 0; i < SwingHitActors.Length; ++i )
	{
		if( SwingHitActors[i] == HitActor )
		{
			return false;
		}
	}
	
	return true;
}


//----------------------------------------------------------------------------------------------------------
function bool AddToSwingHitActors( Actor HitActor )
{
	local int i;
	
	for( i = 0; i < SwingHitActors.Length; ++i )
	{
		if( SwingHitActors[i] == HitActor )
		{
			return false;
		}
	}
	
	SwingHitActors.AddItem( HitActor );
	return true;
}


//----------------------------------------------------------------------------------------------------------
function TraceSwing()
{
	local Actor HitActor, WallHitActor;
	local Vector HitLoc, HitNorm, WeapTip, WeapHilt, Momentum;
	local Vector WallHitLoc, WallHitNorm, HitActorCheckLoc;
	local int DamageAmount;
	
	WeapTip = GetSocketLocation( TipSocketName );
	WeapHilt = GetSocketLocation( HiltSocketName );
	DamageAmount = FCeil( InstantHitDamage[CurrentFireMode] );
	
	foreach TraceActors( class'Actor', HitActor, HitLoc, HitNorm, WeapTip, WeapHilt )
	{
		if( HitActor != self && AddToSwingHitActors( HitActor ) )
		{
			HitActorCheckLoc = HitActor.Location;
			HitActorCheckLoc.Z = Instigator.Location.Z + 100.0;
			WallHitActor = Trace( WallHitLoc, WallHitNorm, HitActorCheckLoc, Instigator.Location );
			if( CheckAttackBlock( WallHitActor ) )
				continue;

			Momentum = Normal( WeapTip - WeapHilt ) * InstantHitMomentum[CurrentFireMode];
			HitActor.TakeDamage( DamageAmount, Instigator.Controller, HitLoc, Momentum, InstantHitDamageTypes[0] );
			PlayImpactEffects(HitActor.Location);
		}
	}
}


//----------------------------------------------------------------------------------------------------------
function bool IsHittableActor( Actor HitActor )
{
	if( InStr( HitActor.Name, "Decal",, true ) == -1 )
		return true;

	return false;
}


//----------------------------------------------------------------------------------------------------------
function PerformSwingSectionCheck( float DeltaTime )
{
	local int CheckSectionNum;
	local float CheckAngleSize, MinCheckAngle, MaxCheckAngle;


	CheckSectionNum = FFloor( ( SecondsSinceAttackBegin * AttackSpeedScale ) / SecondsForEachHitSection );
	if( bOnSecondSwing )
		CheckSectionNum = NumCheckHitSections - CheckSectionNum - 1;

	CheckAngleSize = ( MaxAttackAngle - MinAttackAngle ) / NumCheckHitSections;
	MaxCheckAngle = MaxAttackAngle - ( CheckSectionNum * CheckAngleSize );
	MinCheckAngle = MaxAttackAngle - ( ( CheckSectionNum + 1 ) * CheckAngleSize );
	CheckForHit( MinCheckAngle, MaxCheckAngle );

	SecondsSinceAttackBegin += DeltaTime;
}


//----------------------------------------------------------------------------------------------------------
function CheckForHit( float MinCheckAngle, float MaxCheckAngle )
{
	local Actor HitActor, WallHitActor;
	local Vector HitLoc, Momentum, WallHitLoc, WallHitNorm, HitActorCheckLoc;
	local int DamageAmount;
	local float AngleDeg;
	local Vector HitActorLocDiff;

	DamageAmount = FCeil( InstantHitDamage[CurrentFireMode] );

	foreach VisibleCollidingActors( class'Actor', HitActor, WeapRangeUnrUnits, Instigator.Location, true )
	{
		if( HitActor == self || HitActor == Instigator )
			continue;

		if( CheckSwingHitActors( HitActor ) && IsHittableActor( HitActor ) )
		{
			HitActorLocDiff = HitActor.Location - Instigator.Location;
			HitActorLocDiff.Z = 0.0;
			
			if( HitActor.IsA( 'SSG_Pawn' ) && SSG_Pawn( HitActor ).Controller != None )
			{
				if( VSizeSq( HitActorLocDiff ) > ( WeapRangeUnrUnits + PLAYER_HIT_RANGE_FORGIVENESS ) * ( WeapRangeUnrUnits + PLAYER_HIT_RANGE_FORGIVENESS ) )
					continue;
			}

			AngleDeg = RadToDeg * acos( Normal( Vector( Instigator.Rotation ) ) dot Normal( HitActorLocDiff ) );
			if( Rotator( HitActorLocDiff ).Yaw - ( Instigator.Rotation.Yaw ) < 0 )
				AngleDeg *= -1.0;

			if( AngleDeg < MinCheckAngle || AngleDeg > MaxCheckAngle )
				continue;

			SwingHitActors.AddItem( HitActor );
			HitActorCheckLoc = HitActor.Location;
			HitActorCheckLoc.Z = Instigator.Location.Z + 100.0;
			WallHitActor = Trace( WallHitLoc, WallHitNorm, HitActorCheckLoc, Instigator.Location );
			if( CheckAttackBlock( WallHitActor ) && !bPlayedWallHitCue )
			{
				PlayImpactEffects( HitActor.Location );
				bPlayedWallHitCue = true;
				continue;
			}

			Momentum = Normal( HitActorLocDiff ) * InstantHitMomentum[ CurrentFireMode ];
			HitActor.TakeDamage( DamageAmount, Instigator.Controller, HitLoc, Momentum, InstantHitDamageTypes[0] );
		}
	}
}


//----------------------------------------------------------------------------------------------------------
DefaultProperties
{
	MaxSwings=2
	Swings(0)=2

	SecondsSinceAttackBegin=0.0
	SecondsForEachHitSection=0.0
	NumChecksPerformed=0

	WeapRangeUnrUnits=100.0
	NumCheckHitSections=4
	MinAttackAngle=-90.0
	MaxAttackAngle=90.0
	
	HiltSocketName="HiltSocket"
	TipSocketName="TipSocket"

	EquipTime=+0.0
	PutDownTime=+0.0

	bMeleeWeapon=true
	bInstantHit=true
	bCanThrow=false
	bSwingTwice=false
	bPlayedWallHitCue=false
	AttackCooldownSeconds=0.0
	
	FiringStatesArray(0)="Swinging"
	
	WeaponFireTypes(0)=EWFT_Custom
	InstantHitDamageTypes(0)=class'SSG_DmgType_Melee'
	InstantHitDamageTypes(1)=class'SSG_DmgType_Melee'
}
