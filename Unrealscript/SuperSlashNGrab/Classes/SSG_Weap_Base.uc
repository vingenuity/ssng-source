class SSG_Weap_Base extends UDKWeapon
	abstract;

//This enum is used in the scaleform HUD to present popups to the player when they pick up weapons and for the corner icon.
enum EWeaponID
{
	ID_None, // = 0
	ID_Sword, // = 1
	ID_Spear, // = 2
	ID_Crossbow, // = 3
	ID_Shield, // = 4
};

var EWeaponID WeaponID;

var float MaxDecalRangeSq;

/** default impact effect to use if a material specific one isn't found */
var MaterialImpactEffect DefaultImpactEffect, DefaultAltImpactEffect;

var bool bSuppressSounds;
var(Sounds) SoundCue FiringSound;
var(Sounds) SoundCue ImpactSound;

var() const name WeaponAnimationName;
var name PawnAttackFullBodyAnimationName;
var name PawnAttackUpperBodyAnimationName;
var float AnimationPlaySpeed;
var float AttackSpeedScale;
var float AttackAnimationStartTime;
var bool bLoopAnimation;

var() float     SecondsBetweenFires;
var float       SecondsSinceLastFire;

var Vector LockerOffset;
var Rotator LockerRotation;

var ParticleSystemComponent AttackingParticleComponent;
var ParticleSystem AttackingParticleTemplate;
var Color AttackingParticleColor;


//----------------------------------------------------------------------------------------------------------
const WEAPON_ANIM_BLEND_SECONDS = 0.15;


//----------------------------------------------------------------------------------------------------------
simulated function PostBeginPlay()
{
	local LinearColor OwnerColor;
	local LocalPlayer LocPlayer;
	local SSG_PlayerController PC;

	Super.PostBeginPlay();

	PC = SSG_PlayerController( Instigator.Controller );
	if( PC == None )
		return;

	LocPlayer = LocalPlayer( PC.Player );
	if( LocPlayer == None )
		return;

	OwnerColor = class'SSG_PlayerController'.default.PlayerColors[ LocPlayer.ControllerID ];
	AttackingParticleColor.R = OwnerColor.R * 255;
	AttackingParticleColor.G = OwnerColor.G * 255;
	AttackingParticleColor.B = OwnerColor.B * 255;
	AttackingParticleColor.A = 255;

	SecondsSinceLastFire = SecondsBetweenFires;
}


//----------------------------------------------------------------------------------------------------------
function Tick( float DeltaTime )
{
	Super.Tick( DeltaTime );

	if( SecondsSinceLastFire < SecondsBetweenFires && GetStateName() != 'WeaponFiring' && GetStateName() != 'Swinging' )
	{
		SecondsSinceLastFire += DeltaTime;
	}
}


//----------------------------------------------------------------------------------------------------------
static function string GetLocalString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2
	)
{
	return "";
}



//----------------------------------------------------------------------------------------------------------
function Vector GetSocketLocation( Name SocketName )
{
	local Vector SocketLocation;
	local Rotator WeapRotation;
	local SkeletalMeshComponent SMC;
	
	SMC = SkeletalMeshComponent( Mesh );
	
	if( SMC != none && SMC.GetSocketByName( SocketName ) != none )
	{
		SMC.GetSocketWorldLocationAndRotation( SocketName, SocketLocation, WeapRotation );
	}
	
	return SocketLocation;
}

//----------------------------------------------------------------------------------------------------------
function bool IsSecondaryWeapon()
{
	return ( SSG_Weap_Sword( self ) == None );
}


//----------------------------------------------------------------------------------------------------------
function name GetDesiredSocketName()
{
	return class'SSG_Pawn'.default.WeaponSocket;
}


//----------------------------------------------------------------------------------------------------------
simulated function TimeWeaponFiring( byte FireModeNum )
{
	if( !IsTimerActive('RefireCheckTimer') )
	{
		SetTimer( ( GetFireInterval(FireModeNum) / AttackSpeedScale ), true, nameof(RefireCheckTimer) );
	}
}


//----------------------------------------------------------------------------------------------------------
simulated function FireAmmunition()
{
	local SSG_Pawn SSGP;

	SSGP = SSG_Pawn( Instigator );
	if( SSGP == None )
		return;

	AttackSpeedScale = SSGP.PawnSpeedScale;

	Super.FireAmmunition();

	PlayFiringSound();

	if( SSGP.Velocity == Vect( 0.0, 0.0, 0.0 ) )
		SSG_Pawn(Owner).FullBodyAnimSlot.PlayCustomAnim( PawnAttackFullBodyAnimationName, ( AnimationPlaySpeed * AttackSpeedScale ),,, bLoopAnimation,, AttackAnimationStartTime );
	else
		SSG_Pawn(Owner).UpperBodyAnimSlot.PlayCustomAnim( PawnAttackUpperBodyAnimationName, ( AnimationPlaySpeed * AttackSpeedScale ),,, bLoopAnimation,, AttackAnimationStartTime );

	PlayWeaponAnimation( WeaponAnimationName, ( GetFireInterval( CurrentFireMode ) / AttackSpeedScale ) );
}

//----------------------------------------------------------------------------------------------------------
//This is more or less a direct copy of UTWeapon's PlayFiringSound
simulated function PlayFiringSound()
{
	if ( FiringSound != None )
	{
		MakeNoise(1.0);
		WeaponPlaySound( FiringSound );
	}
}

//----------------------------------------------------------------------------------------------------------
//This is more or less a direct copy of UTWeapon's WeaponPlaySound
simulated function WeaponPlaySound(SoundCue Sound, optional float NoiseLoudness)
{
	// if we are a listen server, just play the sound.  It will play locally
	// and be replicated to all other clients.
	if( Sound != None && Instigator != None && !bSuppressSounds  )
	{
		Instigator.PlaySound(Sound, false, true);
	}
}

//----------------------------------------------------------------------------------------------------------
/**
 * Spawn any effects that occur at the impact point.  It's called from the pawn.
 */
simulated function PlayImpactEffects(vector HitLocation)
{
	//TODO clean this up for decal and particle spawning
	local vector NewHitLoc, HitNormal, FireDir, WaterHitNormal;
	local Actor HitActor;
	local TraceHitInfo HitInfo;
	local MaterialImpactEffect ImpactEffect;
	local MaterialInterface MI;
	local MaterialInstanceTimeVarying MITV_Decal;
	local int DecalMaterialsLength;
	//local Vehicle V;
	local SSG_Pawn P;

	//FIX: Do better with this
	PlaySound( ImpactSound );

	P = SSG_Pawn(Owner);
	HitNormal = Normal(Owner.Location - HitLocation);
	FireDir = -1 * HitNormal;
	if ( (P != None) && EffectIsRelevant(HitLocation, false) )
	{
		if ( /*bMakeSplash &&*/ !WorldInfo.bDropDetail && P.IsPlayerPawn() && P.IsLocallyControlled() )
		{
			HitActor = Trace(NewHitLoc, WaterHitNormal, HitLocation, P.Location+P.eyeheight*vect(0,0,1), true,, HitInfo, TRACEFLAG_PhysicsVolumes | TRACEFLAG_Bullet);
		}
		HitActor = Trace(NewHitLoc, HitNormal, (HitLocation - (HitNormal * 32)), HitLocation + (HitNormal * 32), true,, HitInfo, TRACEFLAG_Bullet);
		if(Pawn(HitActor) != none)
		{
			CheckHitInfo(HitInfo, Pawn(HitActor).Mesh, -HitNormal, NewHitLoc);
		}
		//SetImpactedActor(HitActor, HitLocation, HitNormal, HitInfo);
		// figure out the impact sound to use

		//SOUNDS
		ImpactEffect = GetImpactEffect(HitInfo.PhysMaterial);
		/*
		V = Vehicle(HitActor);
		if (ImpactEffect.Sound != None && !bSuppressSounds)
		{
			// if hit a vehicle controlled by the local player, always play it full volume
			if (V != None && V.IsLocallyControlled() && V.IsHumanControlled())
			{
				PlayerController(V.Controller).ClientPlaySound(ImpactEffect.Sound);
			}
			else
			{
				if ( BulletWhip != None )
				{
					CheckBulletWhip(FireDir, HitLocation);
				}
				PlaySound(ImpactEffect.Sound, true,,, HitLocation);
			}
		}*/

		// Pawns handle their own hit effects
		if ( HitActor != None && (Pawn(HitActor) == None || Vehicle(HitActor) != None) )
		{
			// this code is mostly duplicated in:  UTGib, UTProjectile, UTVehicle, UTWeaponAttachment be aware when updating
			if ( !WorldInfo.bDropDetail
				&& (Pawn(HitActor) == None)
				&& (VSizeSQ(Owner.Location - HitLocation) < MaxDecalRangeSq)
				&& (((WorldInfo.GetDetailMode() != DM_Low) && !class'Engine'.static.IsSplitScreen()) || (P.IsLocallyControlled() && P.IsHumanControlled())) )
			{
				// if we have a decal to spawn on impact
				DecalMaterialsLength = ImpactEffect.DecalMaterials.length;
				if( DecalMaterialsLength > 0 )
				{
					MI = ImpactEffect.DecalMaterials[Rand(DecalMaterialsLength)];
					if( MI != None )
					{
						if( MaterialInstanceTimeVarying(MI) != none )
						{
							// hack, since they don't show up on terrain anyway
							if ( Terrain(HitActor) == None )
							{
								MITV_Decal = new(self) class'MaterialInstanceTimeVarying';
								MITV_Decal.SetParent( MI );

								WorldInfo.MyDecalManager.SpawnDecal( MITV_Decal, HitLocation, rotator(-HitNormal), ImpactEffect.DecalWidth,
									ImpactEffect.DecalHeight, 10.0, false,, HitInfo.HitComponent, true, false, HitInfo.BoneName, HitInfo.Item, HitInfo.LevelIndex );
								//here we need to see if we are an MITV and then set the burn out times to occur
								MITV_Decal.SetScalarStartTime( ImpactEffect.DecalDissolveParamName, ImpactEffect.DurationOfDecal );
							}
						}
						else
						{
							WorldInfo.MyDecalManager.SpawnDecal( MI, HitLocation, rotator(-HitNormal), ImpactEffect.DecalWidth,
								ImpactEffect.DecalHeight, 10.0, false,, HitInfo.HitComponent, true, false, HitInfo.BoneName, HitInfo.Item, HitInfo.LevelIndex );
						}
					}
				}
			}

			if (ImpactEffect.ParticleTemplate != None)
			{
				//if (!bAlignToSurfaceNormal) //assumes all arrows will stick straight out
				//{
					HitNormal = normal(FireDir - ( 2 *  HitNormal * (FireDir dot HitNormal) ) ) ;
				//}
				WorldInfo.MyEmitterPool.SpawnEmitter(ImpactEffect.ParticleTemplate, HitLocation, rotator(HitNormal), HitActor);
			}
		}
	}
	//else if ( BulletWhip != None )
	//{
	//	CheckBulletWhip(FireDir, HitLocation);
	//}
}

//----------------------------------------------------------------------------------------------------------
/** returns the impact sound that should be used for hits on the given physical material */
simulated function MaterialImpactEffect GetImpactEffect(PhysicalMaterial HitMaterial)
{
	if (SSG_Pawn(Owner).FiringMode > 0)
	{
		return DefaultAltImpactEffect;
	}
	else
	{
		return DefaultImpactEffect;
	}
}

//----------------------------------------------------------------------------------------------------------
simulated state WeaponFiring
{
	//----------------------------------------------------------------------------------------------------------
	simulated event BeginState( name PreviousStateName )
	{
		local SSG_Pawn SSGP;

		Super.BeginState( PreviousStateName );

		SSGP = SSG_Pawn( Instigator );
		if( SSGP != none )
		{
			SSGP.bIsFiringWeapon = true;
		}
	}
	

	//----------------------------------------------------------------------------------------------------------
	simulated event EndState( name NextStateName )
	{
		local SSG_Pawn SSGP;

		Super.EndState( NextStateName );

		SSGP = SSG_Pawn( Instigator );
		if( SSGP != none )
		{
			SSGP.bIsFiringWeapon = false;
			SSGP.FullBodyAnimSlot.StopCustomAnim( WEAPON_ANIM_BLEND_SECONDS );
			SSGP.UpperBodyAnimSlot.StopCustomAnim( WEAPON_ANIM_BLEND_SECONDS );
		}

		SecondsSinceLastFire = 0.0;
	}
}


//----------------------------------------------------------------------------------------------------------
DefaultProperties
{
	WeaponID=ID_None
	bCanThrow=false //No weapons in this game can be dropped.

	bSuppressSounds=false
	FiringSound=SoundCue'MiscSounds.SilenceCue'
	ImpactSound=SoundCue'SSG_WeaponSounds.Impacts.ImpactWallCue'
	PickupSound=SoundCue'SSG_WeaponSounds.WeaponPickupCue'
	AttackingParticleColor=(R=255,G=255,B=255,A=255)


	PawnAttackFullBodyAnimationName=SSG_Animations_Character_Hit_Torso_01
	PawnAttackUpperBodyAnimationName=SSG_Animations_Character_Hit_Torso_01
	AnimationPlaySpeed=1.0
	AttackSpeedScale=1.0
	AttackAnimationStartTime=0.0
	bLoopAnimation=false

	SecondsBetweenFires=0.0
	SecondsSinceLastFire=0.0

	RespawnTime=0.0
	
	Begin Object Class=SkeletalMeshComponent Name=WeapSkeletalMeshComponent
		bCacheAnimSequenceNodes=false
		AlwaysLoadOnClient=true
		AlwaysLoadOnServer=true
		CastShadow=true
		BlockRigidBody=true
		bUpdateSkelWhenNotRendered=false
		bIgnoreControllersWhenNotRendered=true
		bUpdateKinematicBonesFromAnimation=true
		bCastDynamicShadow=true
		RBChannel=RBCC_Untitled3
		RBCollideWithChannels=(Untitled3=true)
		bOverrideAttachmentOwnerVisibility=true
		bAcceptsDynamicDecals=false
		bHasPhysicsAssetInstance=true
		TickGroup=TG_PreAsyncWork
		bChartDistanceFactor=true
		RBDominanceGroup=20
		Scale=1.f
		bAllowAmbientOcclusion=false
		bUseOnePassLightingOnTranslucency=true
		bPerBoneMotionBlur=true
	  MinDistFactorForKinematicUpdate=0.0
	End Object
	Mesh=WeapSkeletalMeshComponent
	DroppedPickupMesh = WeapSkeletalMeshComponent
	PickupFactoryMesh = WeapSkeletalMeshComponent
	Components.Add( WeapSkeletalMeshComponent )

	//DefaultImpactEffect=(ParticleTemplate=ParticleSystem'SSG_Character_Particles.Blood.SSG_Particles_Blood_Spray_PS_01')
	//DefaultAltImpactEffect=(ParticleTemplate=ParticleSystem'SSG_Character_Particles.Blood.SSG_Particles_Blood_Spray_PS_01')

	MaxDecalRangeSQ=16000000.0
	LockerOffset=(X=0, Y=0, Z=0)
	LockerRotation=(Roll=0, Pitch=0, Yaw=0)
}
