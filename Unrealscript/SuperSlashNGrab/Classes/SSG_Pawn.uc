/**
 * Copyright 1998-2014 Epic Games, Inc. All Rights Reserved.
 */
class SSG_Pawn extends UDKPawn
	config(Game);

var MaterialInstanceConstant ThiefMaterial;
var Material BotHUDRingMaterial;
var PointLightComponent ThiefLight;
var SSG_Ring_Mesh InGameHealthHUD;

var SSG_Pawn PawnLastHitBy;
var float SecondsSinceLastHit;

// Extra Inventory
var PrimitiveComponent HeldObjectiveMesh;
var float MaxDeathThrowForce;

// Variables for traps that do damage when touched
var int						NumHarmfulTrapsTouching;
var bool					bIsTouchingHarmfulTrap;
var Array<SSG_Trap_Base>    TrapsCurrentlyTouching;

var int                     NumIceVolumesCurrentlyTouching;

var bool bHasSecondaryWeapon;
var bool bIsFiringWeapon;
var bool bIsShielding;
var ParticleSystemComponent SwordFirstSwingParticleSystem;
var ParticleSystemComponent SwordSecondSwingParticleSystem;
var ParticleSystemComponent FrostParticleSystem;

var bool bIsMeshHidden;
var bool bInBuddhaMode;
var int DamageTakenDuringBuddhaMode;

var int NumActorsTouchingAtSpawn;
var float PawnSpeedScale;

// power-up variables
var bool				bDoubleLoot;
var bool				bArrowCircle;
var bool				bBubbleShield;
var SSG_PowerUpEmitter  DoubleLootParticleSystem;
var SSG_PowerUpEmitter	ArrowCircleParticleSystem;
var SSG_PowerUpEmitter	BubbleShieldParticleSystem;

// damage timing variables
var bool    bIsInDamageCooldown;
var bool    bIsTogglingHidden;
var bool    bIsInPlayerHitCooldown;
var float   SecondsSinceToggleHidden;
var float   DamageToggleHiddenSeconds;
var float	SecondsSinceTakeDamage;
var float	DamageCooldownSeconds;
var float   SecondsSinceHitByPlayer;
var float   PlayerHitCooldownSeconds;

// loot drop percentages
var float   PercentageMeleeStealDrop_1stPlace;
var float   PercentageMeleeStealDrop_2ndPlace;
var float   PercentageMeleeStealDrop_3rdPlace;
var float   PercentageMeleeStealDrop_4thPlace;
var float   PercentageArrowStealDrop_1stPlace;
var float   PercentageArrowStealDrop_2ndPlace;
var float   PercentageArrowStealDrop_3rdPlace;
var float   PercentageArrowStealDrop_4thPlace;
var float   PercentageDeathDrop_1stPlace;
var float   PercentageDeathDrop_2ndPlace;
var float   PercentageDeathDrop_3rdPlace;
var float   PercentageDeathDrop_4thPlace;
var float   PercentageDeathLose_1stPlace;
var float   PercentageDeathLose_2ndPlace;
var float   PercentageDeathLose_3rdPlace;
var float   PercentageDeathLose_4thPlace;

// weapon sockets
var name EmoteSocket;
var name HatSocket;
var name AttackParticleSocket;
var name WeaponSocket, WeaponSocket2;


/** The pawn's light environment */
var DynamicLightEnvironmentComponent LightEnvironment;

var AnimNodePlayCustomAnim AttackAnimOverride;
var AnimNodeSlot FullBodyAnimSlot;
var AnimNodeSlot UpperBodyAnimSlot;

var MaterialImpactEffect TakeDamageEffect;
var MaterialInstanceTimeVarying BloodDecal;

var ParticleSystemComponent DeadEffectComponent;
var ParticleSystem DeadEffectTemplateBot;
var ParticleSystem DeadEffectTemplatePlayer1;
var ParticleSystem DeadEffectTemplatePlayer2;
var ParticleSystem DeadEffectTemplatePlayer3;
var ParticleSystem DeadEffectTemplatePlayer4;

var ParticleSystemComponent ConfusionEffectComponent;
var ParticleSystem ConfusionEffectTemplate;

//TODO these need to be in a damage type once we have drowning damage rather than killZ smoke and mirrors
var ParticleSystem DrownEffectTemplate;

var class<SSG_Sound_PawnSoundGroup> SoundGroupClass;

var StaticMesh ForwardFacingArrow;

const RAGDOLL_LIFESPAN_SECONDS = 15.0;
const SHIELD_PROECTION_DEGREES = 85.0;
const PLAYER_ON_PLAYER_MOMENTUM_SCALE_BOW = 0.8;
const PLAYER_ON_PLAYER_MOMENTUM_SCALE_MELEE = 1.5;
const ACCEL_RATE_NORMAL = 10000;
const ACCEL_RATE_ICE = 800;
const LOOT_POWER_UP_SECONDS = 15.0;
const ARROW_POWER_UP_SECONDS = 15.0;
const FROST_EFFECT_LENGTH_SECONDS = 5.0;
const FROST_SPEED_SCALE = 0.5;
const DAMAGE_FLASH_COLOR_STRENGTH = 1.0; // [0.0, 1.0] where 0.0 is no flash color and 1.0 is all flash color
const SECONDS_BEFORE_LAST_HIT_RESET = 3.0;
const SECONDS_OF_CONTROL_LOSS_MELEE = 0.3;
const SECONDS_OF_CONTROL_LOSS_ARROW = 0.1;
const MOMENTUM_SCALE = 2.0;
const RAG_DOLL_MOMENTUM_SCALE = 0.01;

//----------------------------------------------------------------------------------------------------------
enum EWeapAnimType
{
	EWAT_Default,
	EWAT_Pistol,
	EWAT_DualPistols,
	EWAT_ShoulderRocket,
	EWAT_Stinger
};

//----------------------------------------------------------------------------------------------------------
exec function SetRunSpeed( float F )
{
	GroundSpeed = F;
}

//----------------------------------------------------------------------------------------------------------
exec function ChangePlayerColor( byte R, byte G, byte B )
{
	local int matIndex;
	local Color NewColor;
	local LinearColor NewLinearColor;

	NewColor.R = R;
	NewColor.G = G;
	NewColor.B = B;
	NewColor.A = 255;

	NewLinearColor.R = R / 255.0;
	NewLinearColor.G = G / 255.0;
	NewLinearColor.B = B / 255.0;
	NewLinearColor.A = 1.0;

	ThiefMaterial.SetVectorParameterValue( 'Player Color', NewLinearColor );
	ThiefLight.SetLightProperties( 1.75, NewColor );
	for( matIndex = 0; matIndex < class'SSG_Ring_Mesh'.const.NUMBER_OF_MATERIALS; ++matIndex )
	{
		InGameHealthHUD.RingMaterial[ matIndex ].SetVectorParameterValue( 'Player Color', NewLinearColor );
	}
}

//----------------------------------------------------------------------------------------------------------
function int GetLootPlace()
{
	// returns a value between 0 and 4 where 1 represents 1st place, 2 represents 2nd place, and 0 represents bot
	local int place;
	local SSG_PlayerController MyPC, OtherPC;

	place = 1;
	MyPC = SSG_PlayerController( Controller );
	if( MyPC == None )
		return 0;

	foreach WorldInfo.AllControllers( class'SSG_PlayerController', OtherPC )
	{
		if( OtherPC == MyPC )
			continue;

		if( OtherPC.MoneyEarned > MyPC.MoneyEarned )
			++place;
	}

	return place;
}

//----------------------------------------------------------------------------------------------------------
function PostBeginPlay()
{
	local SSG_GameInfo GIasSSGGI;

	super.PostBeginPlay();

	ThiefMaterial = new class'MaterialInstanceConstant';
	ThiefMaterial.SetParent( Mesh.GetMaterial(0) );
	Mesh.SetMaterial( 0, ThiefMaterial );

	DoubleLootParticleSystem = Spawn( class'SSG_PowerUpEmitter',,,, Rot( 0, 0, 0 ) );
	DoubleLootParticleSystem.SetBase( self );
	ArrowCircleParticleSystem = Spawn( class'SSG_PowerUpEmitter',,,, Rot( 0, 0, 0 ) );
	ArrowCircleParticleSystem.SetBase( self );
	BubbleShieldParticleSystem = Spawn( class'SSG_PowerUpEmitter',,,, Rot( 0, 0, 0 ) );
	BubbleShieldParticleSystem.SetBase( self );

	AttackAnimOverride = AnimNodePlayCustomAnim(Mesh.Animations.FindAnimNode('AttackOverrideNode'));
	`Warn("Could not find AttackOverrideNode for mesh (" $ Mesh $ ")",AttackAnimOverride == None);

	FullBodyAnimSlot = AnimNodeSlot( Mesh.FindAnimNode('FullBodySlot') );
	`Warn( "Could not find Full Body Slot for mesh (" $ Mesh $ ")", FullBodyAnimSlot == None );
  
	UpperBodyAnimSlot = AnimNodeSlot( Mesh.FindAnimNode('UpperBodySlot') );
	`Warn( "Could not find Upper Body Slot for mesh (" $ Mesh $ ")", UpperBodyAnimSlot == None );

	GIasSSGGI = SSG_GameInfo(WorldInfo.Game);

	if(GIasSSGGI.bIsFullyLoaded)
	{
		CustomGravityScaling = 1.0;
	}
}

//----------------------------------------------------------------------------------------------------------
function PossessedBy(Controller C, bool bVehicleTransition)
{
	local PlayerController SSG_PC;
	local LocalPlayer Player;
	local Color LightColor;
	local LinearColor PlayerColor;
	
	Super.PossessedBy( C, bVehicleTransition );
	
	SSG_PC = PlayerController( C );

	if( SSG_PC == None )
	{
		InGameHealthHUD = Spawn( class'SSG_Ring_Mesh', /*No Owner*/, /*No Tag*/, /*Default Location*/, rot( 0, 0, 0 ) ); //Spawn HUD ring in world basis
		InGameHealthHUD.SetBase( self );

		InGameHealthHUD.RingMesh.SetMaterial( 0, BotHUDRingMaterial );
		InGameHealthHUD.RingMesh.SetMaterial( 1, BotHUDRingMaterial );
		InGameHealthHUD.RingMesh.SetMaterial( 2, BotHUDRingMaterial );
		InGameHealthHUD.RingMesh.SetMaterial( 3, BotHUDRingMaterial );
	}
	else
	{
		bIsInDamageCooldown = true;
		Player = LocalPlayer( SSG_PC.Player );
		PlayerColor = class'SSG_PlayerController'.default.PlayerColors[ Player.ControllerID ];
		
		ThiefMaterial.SetVectorParameterValue( 'Player Color', PlayerColor );
		
		InGameHealthHUD = Spawn( class'SSG_Ring_Mesh', /*No Owner*/, /*No Tag*/, /*Default Location*/, rot( 0, 0, 0 ) ); //Spawn HUD ring in world basis
		InGameHealthHUD.SetBase( self );
		
		InGameHealthHUD.RingMaterial[ 0 ].SetVectorParameterValue( 'Player Color', PlayerColor );
		InGameHealthHUD.RingMaterial[ 1 ].SetVectorParameterValue( 'Player Color', PlayerColor );
		InGameHealthHUD.RingMaterial[ 2 ].SetVectorParameterValue( 'Player Color', PlayerColor );
		InGameHealthHUD.RingMaterial[ 3 ].SetVectorParameterValue( 'Player Color', PlayerColor );
		
		ThiefLight.SetEnabled( true );
		LightColor.R = PlayerColor.R * 255;
		LightColor.G = PlayerColor.G * 255;
		LightColor.B = PlayerColor.B * 255;
		LightColor.A = 255;
		
		if( LocalPlayer( SSG_PC.Player ).ControllerID == 0 )
			ThiefLight.SetLightProperties( 2.2, LightColor );
		else if( LocalPlayer( SSG_PC.Player ).ControllerID == 1 )
			ThiefLight.SetLightProperties( 1.5, LightColor );
		else if( LocalPlayer( SSG_PC.Player ).ControllerID == 3 )
			ThiefLight.SetLightProperties( 2.0, LightColor );
		else if( LocalPlayer( SSG_PC.Player ).ControllerID == 2 )
			ThiefLight.SetLightProperties( 1.0, LightColor );
		
		ThiefLight.UpdateColorAndBrightness();
		
		InitForwardFacingArrow();
	}
}

//----------------------------------------------------------------------------------------------------------
function InitForwardFacingArrow()
{
	local StaticMeshComponent ForwardFacingComponent;
	local LinearColor InitArrowColor;
	local MaterialInstanceConstant MIC;
	local SSG_PlayerController CasSSGPC;
	local int ColorIndex;

	ForwardFacingComponent = new class'StaticMeshComponent';
	ForwardFacingComponent.SetStaticMesh(ForwardFacingArrow);
	
	MIC = new class'MaterialInstanceConstant';
	MIC.SetParent( ForwardFacingComponent.GetMaterial(0) );
	ForwardFacingComponent.SetMaterial( 0, MIC );
	ForwardFacingComponent.SetDepthPriorityGroup( SDPG_Foreground );

	CasSSGPC = SSG_PlayerController(Controller);
	ColorIndex = LocalPlayer(CasSSGPC.Player).ControllerId;
	InitArrowColor = CasSSGPC.PlayerColors[ColorIndex];
	MIC.SetVectorParameterValue( 'Player Color', InitArrowColor );

	ForwardFacingComponent.SetRotation(rot( 0, 16384, 0));
	ForwardFacingComponent.SetTranslation(vect(0, 0, -50));
	ForwardFacingComponent.SetScale(1.05);
	AttachComponent(ForwardFacingComponent);

}

//----------------------------------------------------------------------------------------------------------
function UpdateObjectiveMesh( SSG_Inventory_Objective Objective )
{
  if(HeldObjectiveMesh != None)
  {
    Mesh.DetachComponent(HeldObjectiveMesh);
    HeldObjectiveMesh = None;
  }
  HeldObjectiveMesh = new( self ) Objective.default.AttachmentMesh.Class( Objective.default.AttachmentMesh );
  HeldObjectiveMesh.SetRotation( HeldObjectiveMesh.Rotation + Objective.AttachmentMeshRotationOffset );
  HeldObjectiveMesh.SetTranslation( HeldObjectiveMesh.Translation + Objective.AttachmentMeshTranslationOffset );

  Mesh.AttachComponentToSocket( HeldObjectiveMesh, HatSocket );
}

//----------------------------------------------------------------------------------------------------------
function Tick( float DeltaTime )
{
	local int trapIndex;
	local SSG_Trap_Base trap;
	local SSG_Trap_Flames flameTrap;

	Super.Tick( DeltaTime );

	if( bInBuddhaMode )
		Health = HealthMax;

	if( !CollisionComponent.BlockActors && NumActorsTouchingAtSpawn == 0 )
	{
		bBlockActors=true;
		CollisionComponent.SetActorCollision( true, true );
	}

	if( bIsTouchingHarmfulTrap && !bIsInDamageCooldown )
	{
		for( trapIndex = 0; trapIndex < TrapsCurrentlyTouching.Length; ++trapIndex )
		{
			trap = TrapsCurrentlyTouching[ trapIndex ];
			if( trap.bTrapActive )
			{
				flameTrap = SSG_Trap_Flames( trap );
				if( flameTrap != None && !flameTrap.bHasStarted )
					continue;

				if( !bBubbleShield && ( flameTrap.IsA( 'SSG_Trap_Frost_Timer' ) || flameTrap.IsA( 'SSG_Trap_Frost_Trigger' ) ) )
				{
					EnablePawnFrostEffects();
				}

				TakeDamage( trap.DamageToGivePawn, none, trap.PawnHitLocation, trap.PawnHitNormal * 10000, trap.DamageTypeToApply );

				break;
			}
		}
	}

	if( bIsInDamageCooldown )
	{
		if( SecondsSinceTakeDamage >= DamageCooldownSeconds )
		{
			bIsInDamageCooldown = false;
			bIsTogglingHidden = false;
			SecondsSinceToggleHidden = 0.0;
			SecondsSinceTakeDamage = 0.0;
			bIsMeshHidden = false;
			ThiefMaterial.SetScalarParameterValue( 'DamageFlashOn', 0.0 );
			//Mesh.SetHidden( false );
			//Weapon.Mesh.SetHidden( false );
		}
		else
		{
			SecondsSinceToggleHidden += DeltaTime;
			SecondsSinceTakeDamage += DeltaTime;
		}

		if( bIsTogglingHidden && SecondsSinceToggleHidden >= DamageToggleHiddenSeconds && Health > 0 )
		{
			SecondsSinceToggleHidden -= DamageToggleHiddenSeconds;
			bIsMeshHidden = !bIsMeshHidden;
			if( bIsMeshHidden )
			{
				ThiefMaterial.SetScalarParameterValue( 'DamageFlashOn', DAMAGE_FLASH_COLOR_STRENGTH );
			}
			else
			{
				ThiefMaterial.SetScalarParameterValue( 'DamageFlashOn', 0.0 );
			}
			//Mesh.SetHidden( bIsMeshHidden );
			//Weapon.Mesh.SetHidden( bIsMeshHidden );
		}
	}
	
	if( bIsInPlayerHitCooldown )
	{
		if( SecondsSinceHitByPlayer >= PlayerHitCooldownSeconds )
		{
			bIsInPlayerHitCooldown = false;
			SecondsSinceHitByPlayer = 0.0;
		}
		else
		{
			SecondsSinceHitByPlayer += DeltaTime;
		}
	}

	if( PawnLastHitBy != None )
	{
		SecondsSinceLastHit += DeltaTime;

		if( SecondsSinceLastHit > SECONDS_BEFORE_LAST_HIT_RESET )
		{
			PawnLastHitBy = None;
			SecondsSinceLastHit = 0.0;
		}
	}
}


//----------------------------------------------------------------------------------------------------------
function EnablePawnFrostEffects()
{
	PawnSpeedScale = FROST_SPEED_SCALE;
	GroundSpeed = class'SSG_Pawn'.default.GroundSpeed * FROST_SPEED_SCALE;
	FrostParticleSystem.ActivateSystem();
	SetTimer( FROST_EFFECT_LENGTH_SECONDS, false, 'DisablePawnFrostEffects', self );
}


//----------------------------------------------------------------------------------------------------------
function DisablePawnFrostEffects()
{
	PawnSpeedScale = 1.0;
	FrostParticleSystem.DeactivateSystem();
	GroundSpeed = class'SSG_Pawn'.default.GroundSpeed;
}


//----------------------------------------------------------------------------------------------------------
function EnableDoubleLootPowerUp()
{
	bDoubleLoot = true;
	DoubleLootParticleSystem.PowerUpParticleSystem.SetTemplate( class'SSG_Inventory_PowerUp_DoubleLoot'.default.OnPlayerParticleSystem );
	DoubleLootParticleSystem.PowerUpParticleSystem.SetActive( true );
	SetTimer( LOOT_POWER_UP_SECONDS, false, 'DisableDoubleLootPowerUp', self );
}


//----------------------------------------------------------------------------------------------------------
function DisableDoubleLootPowerUp()
{
	bDoubleLoot = false;
	DoubleLootParticleSystem.PowerUpParticleSystem.SetActive( false );
	//BCD: Play Power Down Sound
	PlaySound(SoundCue'SSG_TrapSounds.Triggers.PowerUpRunsOutCue');
}


//----------------------------------------------------------------------------------------------------------
function EnableArrowCirclePowerUp()
{
	bArrowCircle = true;
	ArrowCircleParticleSystem.PowerUpParticleSystem.SetTemplate( class'SSG_Inventory_PowerUp_ArrowCircle'.default.OnPlayerParticleSystem );
	ArrowCircleParticleSystem.PowerUpParticleSystem.SetActive( true );
	SetTimer( ARROW_POWER_UP_SECONDS, false, 'DisableArrowCirclePowerUp', self );
}


//----------------------------------------------------------------------------------------------------------
function DisableArrowCirclePowerUp()
{
	bArrowCircle = false;
	ArrowCircleParticleSystem.PowerUpParticleSystem.SetActive( false );
	//BCD: Play Power Down Sound
	PlaySound(SoundCue'SSG_TrapSounds.Triggers.PowerUpRunsOutCue');
}


//----------------------------------------------------------------------------------------------------------
function EnableBubbleShieldPowerUp()
{
	local int PlayerId;

	PlayerId = LocalPlayer( PlayerController( Controller ).Player ).ControllerId;

	bBubbleShield = true;
	BubbleShieldParticleSystem.PowerUpParticleSystem.SetTemplate( class'SSG_Inventory_PowerUp_BubbleShield'.default.ShieldParticleSystemByPlayer[ PlayerId ] );
	BubbleShieldParticleSystem.PowerUpParticleSystem.SetActive( true );
}


//----------------------------------------------------------------------------------------------------------
function DisableBubbleShieldPowerUp()
{
	bBubbleShield = false;
	BubbleShieldParticleSystem.PowerUpParticleSystem.SetActive( false );
	//BCD: Play Power Down Sound
	PlaySound(SoundCue'SSG_TrapSounds.Triggers.PowerUpRunsOutCue');
}


//----------------------------------------------------------------------------------------------------------
function Touch( Actor Other, PrimitiveComponent OtherComp, Vector HitLocation, Vector HitNormal )
{
	local SSG_Pawn SSGP;

	Super.Touch( Other, OtherComp, HitLocation, HitNormal );

	if( !CollisionComponent.BlockActors && Other.bBlockActors )
		++NumActorsTouchingAtSpawn;

	SSGP = SSG_Pawn( Other );
	if( SSGP == None )
		return;

	if( !self.bIsShielding && !SSGP.bIsShielding )
		return;

	HitNormal.Z = 0;

	if( SSGP.bIsShielding )
	{
		self.Velocity.X = 0;
		self.Velocity.Y = 0;
		self.Velocity.Z = 0;
		self.AddVelocity( -HitNormal * 1000, HitLocation, None );
	}
	else if( self.bIsShielding )
	{
		SSGP.Velocity.X = 0;
		SSGP.Velocity.Y = 0;
		SSGP.Velocity.Z = 0;
		SSGP.AddVelocity( HitNormal * 1000, HitLocation, None );
	}
}


//----------------------------------------------------------------------------------------------------------
function UnTouch( Actor Other )
{
	Super.UnTouch( Other );

	if( !CollisionComponent.BlockActors && Other.bBlockActors )
		--NumActorsTouchingAtSpawn;
}


//----------------------------------------------------------------------------------------------------------
function UpdateAccelRate( float IceAccel )
{
	if( NumIceVolumesCurrentlyTouching == 0 )
		AccelRate = ACCEL_RATE_NORMAL;
	else
		AccelRate = ACCEL_RATE_ICE;
}


//----------------------------------------------------------------------------------------------------------
function AddDefaultInventory()
{
	local SSG_PlayerController PC;

	InvManager.CreateInventory( class'SuperSlashNGrab.SSG_Weap_Sword' );

	PC = SSG_PlayerController( Controller );
	if( PC != None && PC.IDOfCurrentWeapon > 1 )
	{
		if( PC.IDOfCurrentWeapon == 2 )
		{
			InvManager.CreateInventory( class'SuperSlashNGrab.SSG_Weap_Spear' );
		}
		else if( PC.IDOfCurrentWeapon == 3 )
		{
			InvManager.CreateInventory( class'SuperSlashNGrab.SSG_Weap_Bow' );
		}
		else if( PC.IDOfCurrentWeapon == 4 )
		{
			InvManager.CreateInventory( class'SuperSlashNGrab.SSG_Weap_Shield' );
		}
		
		bHasSecondaryWeapon = true;
	}
}


//----------------------------------------------------------------------------------------------------------
simulated event BecomeViewTarget( PlayerController playerControl )
{
   Super.BecomeViewTarget( playerControl );

   if ( LocalPlayer( playerControl.Player ) != None )
   {
        //set player controller to behind view and make mesh visible
        //playerControl.SetBehindView(true);
        //SetMeshVisibility( playerControl.bBehindView ); 
        //playerControl.bNoCrosshair = true;
   }
}


//----------------------------------------------------------------------------------------------------------
simulated function bool CalcCamera( float fDeltaTime, out vector out_CamLoc, out rotator out_CamRot, out float out_FOV )
{
   return false;
}

//----------------------------------------------------------------------------------------------------------
simulated function StartFire(byte FireModeNum)
{
	local SSG_Weap_Sword Sword;
	local SSG_Weap_Base InventoryWeapon, RemoveMeshWeapon;
	local SSG_InventoryManager LocalInvManager;
	
	if( ( bNoWeaponFiring || bIsFiringWeapon ) && FireModeNum != 0 )
	{
		return;
	}
	
	LocalInvManager = SSG_InventoryManager( InvManager );
	if( LocalInvManager == None )
		return;
	
	if( FireModeNum == 0 )
	{
		Sword = SSG_Weap_Sword( LocalInvManager.FindInventoryType( class'SSG_Weap_Sword', false ) );
		
		if( Sword != None && Sword.SecondsSinceLastFire >= Sword.SecondsBetweenFires )
		{
			Sword.StartFire( 0 );
		}
	}
	else if( bHasSecondaryWeapon )
	{
		foreach LocalInvManager.InventoryActors( class'SSG_Weap_Base', InventoryWeapon )
		{
			if( InventoryWeapon != None && InventoryWeapon.IsSecondaryWeapon() )
			{
				if( Weapon == InventoryWeapon && !Controller.IsA( 'SSG_Bot_Shield' ) ) //If we have our secondary weapon out (which should only happen for bots)
				{
					Weapon.StartFire( 0 );
				}
				else if( InventoryWeapon.SecondsSinceLastFire >= InventoryWeapon.SecondsBetweenFires )
				{
					foreach LocalInvManager.InventoryActors( class'SSG_Weap_Base', RemoveMeshWeapon )
					{
						Mesh.DetachComponent( RemoveMeshWeapon.Mesh );
					}

					Mesh.AttachComponentToSocket( InventoryWeapon.Mesh, InventoryWeapon.GetDesiredSocketName() );
					LocalInvManager.SetCurrentWeapon( InventoryWeapon );
					InventoryWeapon.StartFire( 0 );
				}
			}
		}
	}
}


//----------------------------------------------------------------------------------------------------------
simulated function WeaponFired(Weapon InWeapon, bool bViaReplication, optional vector HitLocation)
{
	local SSG_Weap_Base InWeaponAsSSGWeap;

	super.WeaponFired(InWeapon, bViaReplication, HitLocation);

	InWeaponAsSSGWeap = SSG_Weap_Base(InWeapon);
	if ( HitLocation != Vect(0,0,0) )
	{
		InWeaponAsSSGWeap.PlayImpactEffects(HitLocation);
	}
}


//----------------------------------------------------------------------------------------------------------
function bool IsInFrontOfShield( Vector ViewVec, Vector DirVec )
{
	local float AngleDeg;

	AngleDeg = RadToDeg * acos( Normal( ViewVec ) dot Normal( DirVec ) );

	if( AngleDeg <= SHIELD_PROECTION_DEGREES )
		return true;

	return false;
}

//----------------------------------------------------------------------------------------------------------
function PlayLanded(float impactVel)
{
	if(impactVel < -300)
	{
		SoundGroupClass.static.PlayLandSound(self);
	}
}

function TakeFallingDamage()
{
	//no falling damage
}

//----------------------------------------------------------------------------------------------------------
function TakeDamage( int Damage, Controller InstigatedBy, Vector HitLocation, Vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser )
{
	local int DamageToTake;
	local float MomentumLength, PercentToDrop, SecondsOfControlLoss;
	local LocalPlayer LocPlayer;
	local SSG_PlayerController SSG_PC;
	local int Place, AmountOfMoneyToDrop;

	if( InstigatedBy == Controller )
		return;

	if( bIsInDamageCooldown || bIsInPlayerHitCooldown )
		return;

	if( bIsShielding && InstigatedBy != None && InstigatedBy.Pawn.IsA( 'SSG_Pawn' ) && IsInFrontOfShield( Vector( self.Rotation ), HitLocation - self.Location ) )
	{
		return;
	}

	if( InstigatedBy != None && InstigatedBy.Pawn != None && InstigatedBy.Pawn.IsA( 'SSG_Pawn' ) )
	{
		PawnLastHitBy = SSG_Pawn( InstigatedBy.Pawn );
		SecondsSinceLastHit = 0.0;
	}

	MomentumLength = MOMENTUM_SCALE * VSize( Momentum );
	Momentum.Z = 0.0;
	Momentum = MomentumLength * Normal( Momentum );

	DamageToTake = Damage;

	if( InstigatedBy != None && Controller.GetTeamNum() == InstigatedBy.GetTeamNum() )
	{
		DamageToTake = 0;
		bIsInPlayerHitCooldown = true;
		SecondsSinceHitByPlayer = 0.0;

		if( Controller.IsA( 'SSG_PlayerController' ) )
		{
			SSG_PC = SSG_PlayerController( Controller );
			SecondsOfControlLoss = 0.0;

			if( DamageType == class'SSG_DmgType_Projectile' && bBubbleShield )
			{
				return;
			}
			
			if( DamageType == class'SSG_DmgType_Melee' && !bBubbleShield )
			{
				Momentum *= PLAYER_ON_PLAYER_MOMENTUM_SCALE_MELEE;
				SecondsOfControlLoss = SECONDS_OF_CONTROL_LOSS_MELEE;
			}
			else
			{
				Momentum *= PLAYER_ON_PLAYER_MOMENTUM_SCALE_BOW;
				SecondsOfControlLoss = SECONDS_OF_CONTROL_LOSS_ARROW;
			}

			Velocity = Vect( 0.0, 0.0, 0.0 );
			SSG_PC.TurnOffPlayerControl( SecondsOfControlLoss );

			if( SSG_PC.MoneyEarned <= 100 )
			{
				AmountOfMoneyToDrop = SSG_PC.MoneyEarned;
			}
			else if( bBubbleShield )
			{
				AmountOfMoneyToDrop = 0;
			}
			else
			{
				Place = GetLootPlace();
				if( Place == 0 )
					PercentToDrop = 1.0;
				else if( Place == 1 )
				{
					if( DamageType == class'SSG_DmgType_Projectile' )
						PercentToDrop = PercentageArrowStealDrop_1stPlace;
					else
						PercentToDrop = PercentageMeleeStealDrop_1stPlace;
				}
				else if( Place == 2 )
				{
					if( DamageType == class'SSG_DmgType_Projectile' )
						PercentToDrop = PercentageArrowStealDrop_2ndPlace;
					else
						PercentToDrop = PercentageMeleeStealDrop_2ndPlace;
				}
				else if( Place == 3 )
				{
					if( DamageType == class'SSG_DmgType_Projectile' )
						PercentToDrop = PercentageArrowStealDrop_3rdPlace;
					else
						PercentToDrop = PercentageMeleeStealDrop_3rdPlace;
				}
				else if( Place == 4 )
				{
					if( DamageType == class'SSG_DmgType_Projectile' )
						PercentToDrop = PercentageArrowStealDrop_4thPlace;
					else
						PercentToDrop = PercentageMeleeStealDrop_4thPlace;
				}

				AmountOfMoneyToDrop = max( SSG_PC.MoneyEarned * PercentToDrop, 100 );
				AmountOfMoneyToDrop = 100 * Round( ( AmountOfMoneyToDrop * 0.01 ) - 0.5 );
			}

			DropAmountOfTreasure( AmountOfMoneyToDrop );
			SSG_PC.MoneyEarned -= AmountOfMoneyToDrop;
			SSG_PC.MoneyEarnedSinceLastUpdate -= AmountOfMoneyToDrop;
		}
	}

	UpperBodyAnimSlot.PlayCustomAnim( 'SSG_Animations_Character_Hit_Torso_01', 1.0 );
	SoundGroupClass.static.PlayTakeHitSound(self, Damage);
	
	if( DamageToTake > 0 )
	{
		bIsInDamageCooldown = true;
		SecondsSinceTakeDamage = 0.0;

		if( bBubbleShield )
		{
			DisableBubbleShieldPowerUp();
			DamageToTake = 0;
		}
		else
		{
			SecondsSinceToggleHidden = 0.0;
			bIsTogglingHidden = true;
			bIsMeshHidden = true;
			ThiefMaterial.SetScalarParameterValue( 'DamageFlashOn', DAMAGE_FLASH_COLOR_STRENGTH );
			WorldInfo.MyEmitterPool.SpawnEmitter(TakeDamageEffect.ParticleTemplate, Location + ClampLength(HitLocation - Location, 28.0), rotator(/*HitNormal*/Momentum), self);
			SpawnDecalBelowPawn();
		}

		Velocity = Vect( 0.0, 0.0, 0.0 );

		if( Controller.IsA( 'SSG_PlayerController' ) )
		{
			SSG_PC = SSG_PlayerController( Controller );
			SSG_PC.TakenDamageSinceLastUpdate = true;
		}
	}

	Super.TakeDamage( DamageToTake, InstigatedBy, HitLocation, Momentum, DamageType, HitInfo, DamageCauser );

	if( Controller != None && Controller.IsA( 'SSG_PlayerController' ) )
	{
		SSG_PC = SSG_PlayerController( Controller );
		SSG_PC.StartNewControllerRumble( SSG_PC.HitRumble );

		if( SSG_PC.TakenDamageSinceLastUpdate && bInBuddhaMode )
		{
			++DamageTakenDuringBuddhaMode;
			
			if( DamageTakenDuringBuddhaMode > 2 && DamageTakenDuringBuddhaMode < 8 )
			{
				LocPlayer = LocalPlayer( SSG_PC.Player );
				ReleaseSkullParticle( LocPlayer.ControllerId + 1 );
			}
		}
	}

	if( InGameHealthHUD != None && Controller != None && Controller.IsA( 'SSG_PlayerController' ) )
		InGameHealthHUD.SetFillLevel( Health );

	if( Health <= 0 )
	{
		bIsMeshHidden = false;
		ThiefMaterial.SetScalarParameterValue( 'DamageFlashOn', 0.0 );
		Mesh.SetRBLinearVelocity( Momentum * RAG_DOLL_MOMENTUM_SCALE, true );
		//Mesh.SetHidden( false );
		//Weapon.Mesh.SetHidden( false );

		if( InGameHealthHUD != None )
			InGameHealthHUD.SetHidden( true );
	}
}


//----------------------------------------------------------------------------------------------------------
function PlayHit(float Damage, Controller InstigatedBy, vector HitLocation, class<DamageType> damageType, vector Momentum, TraceHitInfo HitInfo)
{
	local class<SSG_DamageType> LastHitDamageType;

	super.PlayHit(Damage, InstigatedBy, HitLocation, damageType, Momentum, HitInfo);

	LastHitDamageType = class<SSG_DamageType>(damageType);
	if(LastHitDamageType != none)
	{
		LastHitDamageType.static.SpawnHitEffect(self, Damage, Momentum, HitInfo.BoneName, HitLocation);
	}

}


//----------------------------------------------------------------------------------------------------------
function bool Died(Controller Killer, class<DamageType> DamageType, vector HitLocation)
{
    local bool deathAllowed;
	local LocalPlayer LocPlayer;
	local SSG_PlayerController PC;
	local SSG_PlayerController KillerAsSSGPC;
	local int Place, AmountOfMoneyToDrop, AmountOfMoneyToLose;
	local float PercentToDrop, PercentToLose;
	local class<SSG_DamageType> DeathDamageType;

	PC = SSG_PlayerController( Controller );
	Place = GetLootPlace();

    deathAllowed = super.Died( Killer, DamageType, HitLocation );
    if( deathAllowed )
    {
		bBlockActors = false;
		CollisionComponent.SetActorCollision( true, false );

		DoubleLootParticleSystem.PowerUpParticleSystem.SetActive( false );
		ArrowCircleParticleSystem.PowerUpParticleSystem.SetActive( false );
		BubbleShieldParticleSystem.PowerUpParticleSystem.SetActive( false );

		if( PC != None )
		{
			LocPlayer = LocalPlayer( PC.Player );

			if( PawnLastHitBy != None && PawnLastHitBy.Controller != None && PawnLastHitBy.Controller.IsA( 'SSG_PlayerController' ) )
			{
				SSG_PlayerController( PawnLastHitBy.Controller ).KilledPlayer( LocPlayer.ControllerId );
			}

			DeathDamageType = class<SSG_DamageType>(DamageType);
			PC.TimesDiedToType[DeathDamageType.default.DeathCauseType]++;

			PC.SetControlType( 0 );

			if( PC.MoneyEarned <= 100 )
			{
				AmountOfMoneyToDrop = PC.MoneyEarned;
				AmountOfMoneyToLose = 0;
			}
			else
			{
				if( Place == 0 )
				{
					PercentToDrop = 1.0;
					PercentToLose = 0.0;
				}
				else if( Place == 1 )
				{
					PercentToDrop = PercentageDeathDrop_1stPlace;
					PercentToLose = PercentageDeathLose_1stPlace;
				}
				else if( Place == 2 )
				{
					PercentToDrop = PercentageDeathDrop_2ndPlace;
					PercentToLose = PercentageDeathLose_2ndPlace;
				}
				else if( Place == 3 )
				{
					PercentToDrop = PercentageDeathDrop_3rdPlace;
					PercentToLose = PercentageDeathLose_3rdPlace;
				}
				else if( Place == 4 )
				{
					PercentToDrop = PercentageDeathDrop_4thPlace;
					PercentToLose = PercentageDeathLose_4thPlace;
				}

				AmountOfMoneyToDrop = max( PC.MoneyEarned * PercentToDrop, 100 );
				AmountOfMoneyToDrop = 100 * Round( ( AmountOfMoneyToDrop * 0.01 ) - 0.5 );

				AmountOfMoneyToLose = max( PC.MoneyEarned * PercentToLose, 100 );
				AmountOfMoneyToLose = 100 * Round( ( AmountOfMoneyToLose * 0.01 ) - 0.5 );
			}
			
			DropAmountOfTreasure( AmountOfMoneyToDrop );
			PC.MoneyEarned -= ( AmountOfMoneyToDrop + AmountOfMoneyToLose );
			PC.MoneyEarnedSinceLastUpdate -= ( AmountOfMoneyToDrop + AmountOfMoneyToLose );

			PC.StartNewControllerRumble( PC.DeathRumble );

			Destroy(); //may later be moved to postbegin play to destroy the old one
		}

		if( PC == None )
		{
			ReleaseSkullParticle( 0 );
		}
		else
		{
			ReleaseSkullParticle( LocPlayer.ControllerId + 1 );
		}


		if( InGameHealthHUD != None )
			InGameHealthHUD.Destroy();

		CylinderComponent.SetCylinderSize( CylinderComponent.CollisionRadius, CylinderComponent.CollisionHeight * 0.1 );
		CylinderComponent.SetActorCollision(false, false);
	}

	KillerAsSSGPC = SSG_PlayerController(Killer);
	if(KillerAsSSGPC != none)
	{
		KillerAsSSGPC.NumKills += 1;
		if(class<SSG_DmgType_Melee>(DamageType) != none)
		{
			KillerAsSSGPC.NumMeleeKills += 1;
		}
		else if(class<SSG_DmgType_Projectile>(DamageType) != none)
		{
			KillerAsSSGPC.NumRangedKills += 1;
		}
	}

	if(HeldObjectiveMesh != None)
	{
		Mesh.DetachComponent(HeldObjectiveMesh);
		HeldObjectiveMesh = None;
	}
	StopConfusionEffect();

	if(PC == none)
	{
		InitRagdoll();
		SetPawnRBChannels( true );
	}

	DeathDamageType = class<SSG_DamageType>(DamageType);
	if (DeathDamageType != none)
	{
		DeathDamageType.static.SpawnDeathEffect(self, HitLocation);
	}
	else if(class<KillZDamageType>(DamageType) != none)
	{
		WorldInfo.MyEmitterPool.SpawnEmitter(DrownEffectTemplate, Location, , self);
		SoundGroupClass.static.PlayDrownSound(self);
	}

	ThiefMaterial.SetScalarParameterValue( 'fresnelOn', 0.0 );

    return deathAllowed;
}


//----------------------------------------------------------------------------------------------------------
simulated function ReleaseSkullParticle( int playerNumber )
{
	local Vector SpawnLocation;

	if(DeadEffectComponent == none)
	{
		DeadEffectComponent = new(self) class'ParticleSystemComponent';

		if( playerNumber == 0 )
			DeadEffectComponent.SetTemplate( DeadEffectTemplateBot );
		else if( playerNumber == 1 )
			DeadEffectComponent.SetTemplate( DeadEffectTemplatePlayer1 );
		else if( playerNumber == 2 )
			DeadEffectComponent.SetTemplate( DeadEffectTemplatePlayer2 );
		else if( playerNumber == 3 )
			DeadEffectComponent.SetTemplate( DeadEffectTemplatePlayer3 );
		else if( playerNumber == 4 )
			DeadEffectComponent.SetTemplate( DeadEffectTemplatePlayer4 );
		else
			return;

		SpawnLocation = Location + Mesh.GetSocketByName( EmoteSocket ).RelativeLocation;
		WorldInfo.MyEmitterPool.SpawnEmitter( DeadEffectComponent.Template, SpawnLocation );
	}
}

//----------------------------------------------------------------------------------------------------------
simulated function PlayDying(class<DamageType> DamageType, vector HitLoc)
{
	Super.PlayDying( DamageType, HitLoc );

	//FullBodyAnimSlot.PlayCustomAnim( 'SSG_Animation_Thief_Death_01', 1.0, 0.0, 0.0, false, false );
	//FullBodyAnimSlot.SetActorAnimEndNotification( true );

	if(!(Controller == none || Controller.IsA('SSG_PlayerController')))
	{
		InitRagdoll();
		SetPawnRBChannels( true );
	}
}

//----------------------------------------------------------------------------------------------------------
State Dying
{
	event BeginState( Name PreviousStateName )
	{
		Super.BeginState( PreviousStateName );

		if ( bTearOff && (WorldInfo.NetMode == NM_DedicatedServer) )
		{
			LifeSpan = 2.0;
		}
		else
		{
			LifeSpan = RAGDOLL_LIFESPAN_SECONDS;
		}
	}

	event TakeDamage(int Damage, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
	{
		Velocity += 3 * momentum/(Mass + 200);
	}
}

//----------------------------------------------------------------------------------------------------------
function DropAmountOfTreasure( int AmountToDrop )
{
	local int numSmallDrop;
	local int numMediumDrop;
	local int numLargeDrop;
	local Vector spawnLocation;
	local SSG_LootSpawner spawner;

	while( AmountToDrop >= class'SSG_Inventory_Treasure_Large'.default.MonetaryValue )
	{
		++numLargeDrop;
	    AmountToDrop -=class'SSG_Inventory_Treasure_Large'.default.MonetaryValue;
	}
	
	while( AmountToDrop >= class'SSG_Inventory_Treasure_Medium'.default.MonetaryValue )
	{
		++numMediumDrop;
	    AmountToDrop -=class'SSG_Inventory_Treasure_Medium'.default.MonetaryValue;
	}
	
	while( AmountToDrop >= class'SSG_Inventory_Treasure_Small'.default.MonetaryValue )
	{
		++numSmallDrop;
	    AmountToDrop -=class'SSG_Inventory_Treasure_Small'.default.MonetaryValue;
	}

	spawnLocation = Location;
	spawnLocation.Z += 100;
	spawner = Spawn( class'SSG_LootSpawner',,, spawnLocation, Rotation );
	spawner.NumSmallTreasureToDrop = numSmallDrop;
	spawner.NumMediumTreasureToDrop = numMediumDrop;
	spawner.NumLargeTreasureToDrop = numLargeDrop;
}

//----------------------------------------------------------------------------------------------------------
event OnAnimEnd(AnimNodeSequence SeqNode, float PlayedTime, float ExcessTime)
{
	Super.OnAnimEnd( SeqNode, PlayedTime, ExcessTime );

	if( SeqNode.AnimSeqName == 'SSG_Animation_Thief_Death_01' )
	{
		FullBodyAnimSlot.PlayCustomAnim( 'SSG_Animation_Thief_DeadLoop_01', 1.0, 0.0, 0.0, true, true );
	}
}

//----------------------------------------------------------------------------------------------------------
function Vector CalculateRandom2DVector( float vectorLength )
{
    local Vector randomVector;

    randomVector = VRand();
    randomVector.Z = 0.25 * abs( randomVector.Z );
    randomVector = Normal( randomVector ) * vectorLength;

    return randomVector;
}


//----------------------------------------------------------------------------------------------------------
simulated singular event Rotator GetBaseAimRotation()
{
   local rotator   POVRot, tempRot;

   tempRot = Rotation;
   tempRot.Pitch = 0;
   SetRotation(tempRot);
   POVRot = Rotation;
   POVRot.Pitch = 0;

   return POVRot;
}


//----------------------------------------------------------------------------------------------------------
/** Change the type of weapon animation we are playing. */
simulated function SetWeapAnimType(EWeapAnimType AnimType)
{
	if (AimNode != None)
	{
		switch(AnimType)
		{
			case EWAT_Default:
				AimNode.SetActiveProfileByName('Default');
				break;
		}
	}
}

//----------------------------------------------------------------------------------------------------------
simulated function name GetMaterialBelowFeet()
{
	local vector HitLocation, HitNormal;
	local TraceHitInfo HitInfo;
	local SSG_PhysicalMaterialProperty PhysicalProperty;
	//local actor HitActor;
	local float TraceDist;

	TraceDist = 1.5 * GetCollisionHeight();

	//HitActor = Trace(HitLocation, HitNormal, Location - TraceDist*vect(0,0,1), Location, false,, HitInfo, TRACEFLAG_PhysicsVolumes);
	Trace(HitLocation, HitNormal, Location - TraceDist*vect(0,0,1), Location, false,, HitInfo, TRACEFLAG_PhysicsVolumes);
	if (HitInfo.PhysMaterial != None)
	{
		PhysicalProperty = SSG_PhysicalMaterialProperty(HitInfo.PhysMaterial.GetPhysicalMaterialProperty(class'SSG_PhysicalMaterialProperty'));
		if (PhysicalProperty != None)
		{
			return PhysicalProperty.MaterialType;
		}
	}
	return '';

}

//----------------------------------------------------------------------------------------------------------
function SpawnDecalBelowPawn()
{
	local vector HitLocation, HitNormal;
	local TraceHitInfo HitInfo;
	//local actor HitActor;
	local float TraceDist;

	TraceDist = 1.5 * GetCollisionHeight();

	//HitActor = Trace(HitLocation, HitNormal, Location - TraceDist*vect(0,0,1), Location, false,, HitInfo, TRACEFLAG_PhysicsVolumes);
	Trace(HitLocation, HitNormal, Location - TraceDist*vect(0,0,1), Location, false,, HitInfo, TRACEFLAG_PhysicsVolumes);
	//if(HitActor == none)
	//{
		WorldInfo.MyDecalManager.SpawnDecal(BloodDecal, HitLocation, rotator(-HitNormal), 120.0, 120.0, 10.0, FALSE ); //hacked vales for the size of the decal
	//}
}

//----------------------------------------------------------------------------------------------------------
event PlayFootStepSound( int FootDown )
{
    SoundGroupClass.static.PlayFootstepSound(self, FootDown);
}

//----------------------------------------------------------------------------------------------------------
function SpawnConfusionEffect()
{
	//Hacky and horribly inefficient; much of this probably belongs in postbeginplay
	if(ConfusionEffectComponent == none)
	{
		ConfusionEffectComponent = new(self) class'ParticleSystemComponent';
		ConfusionEffectComponent.SetTemplate(ConfusionEffectTemplate);
		Mesh.AttachComponentToSocket(ConfusionEffectComponent, EmoteSocket);
	}
	
	ConfusionEffectComponent.SetActive( false );
	ConfusionEffectComponent.ActivateSystem();
}

//----------------------------------------------------------------------------------------------------------
function StopConfusionEffect()
{
	if(ConfusionEffectComponent != none)
	{
		ConfusionEffectComponent.DeactivateSystem();
	}
}

//This function is a direct copypasta from UTPawn
simulated function SetPawnRBChannels(bool bRagdollMode)
{
  if(bRagdollMode)
  {
    Mesh.SetRBChannel(RBCC_Pawn);
    Mesh.SetRBCollidesWithChannel(RBCC_Default,TRUE);
    Mesh.SetRBCollidesWithChannel(RBCC_Pawn,TRUE);
    Mesh.SetRBCollidesWithChannel(RBCC_Vehicle,TRUE);
    Mesh.SetRBCollidesWithChannel(RBCC_Untitled3,FALSE);
    Mesh.SetRBCollidesWithChannel(RBCC_BlockingVolume,TRUE);
  }
  else
  {
    Mesh.SetRBChannel(RBCC_Untitled3);
    Mesh.SetRBCollidesWithChannel(RBCC_Default,FALSE);
    Mesh.SetRBCollidesWithChannel(RBCC_Pawn,FALSE);
    Mesh.SetRBCollidesWithChannel(RBCC_Vehicle,FALSE);
    Mesh.SetRBCollidesWithChannel(RBCC_Untitled3,TRUE);
    Mesh.SetRBCollidesWithChannel(RBCC_BlockingVolume,FALSE);
  }
}



//----------------------------------------------------------------------------------------------------------
defaultproperties
{
	bBlockActors=false
	bNoEncroachCheck=true

	PawnLastHitBy=None
	SecondsSinceLastHit=0.0

	bCanPickupInventory=true
	InventoryManagerClass=class'SSG_InventoryManager'
	MaxDeathThrowForce=350.0;

	NumHarmfulTrapsTouching=0
	bIsTouchingHarmfulTrap=false
	PawnSpeedScale=1.0

	NumIceVolumesCurrentlyTouching=0
	NumActorsTouchingAtSpawn=0

	bDoubleLoot=false
	bArrowCircle=false
	bBubbleShield=false

	bHasSecondaryWeapon=true
	bIsFiringWeapon=false
	bIsShielding=false

	bIsMeshHidden=false
	bIsInDamageCooldown=false
	bIsTogglingHidden=false
	bIsInPlayerHitCooldown=false
	SecondsSinceToggleHidden=0.0
	DamageToggleHiddenSeconds=0.18
	SecondsSinceTakeDamage=0.0
	DamageCooldownSeconds=2.0
	SecondsSinceHitByPlayer=0.0
	PlayerHitCooldownSeconds=0.1

	Health=3
	HealthMax=3
	GroundSpeed=650.0
	AccelRate=10000.0

	PercentageMeleeStealDrop_1stPlace=0.03
	PercentageMeleeStealDrop_2ndPlace=0.02
	PercentageMeleeStealDrop_3rdPlace=0.01
	PercentageMeleeStealDrop_4thPlace=0.01
	PercentageArrowStealDrop_1stPlace=0.015
	PercentageArrowStealDrop_2ndPlace=0.01
	PercentageArrowStealDrop_3rdPlace=0.005
	PercentageArrowStealDrop_4thPlace=0.005
	PercentageDeathDrop_1stPlace=0.1
	PercentageDeathDrop_2ndPlace=0.075
	PercentageDeathDrop_3rdPlace=0.05
	PercentageDeathDrop_4thPlace=0.05
	PercentageDeathLose_1stPlace=0.05
	PercentageDeathLose_2ndPlace=0.025
	PercentageDeathLose_3rdPlace=0.01
	PercentageDeathLose_4thPlace=0.01

	WeaponSocket=WeaponPoint
	WeaponSocket2=DualWeaponPoint
	HatSocket=HatSocket
	EmoteSocket=EmoteSocket
	AttackParticleSocket=AttackParticleSocket

	BotHUDRingMaterial=Material'SSG_Character_Particles.HUD.SSG_HUD_Ring_Guard_MAT_01'
	
	Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
	  TickGroup=TG_DuringAsyncWork
	  bEnabled=TRUE
	End Object
	LightEnvironment=MyLightEnvironment
	Components.Add(MyLightEnvironment)
	
	Begin Object Name=CollisionCylinder
	  BlockActors=false
	End Object

	Begin Object Class=SkeletalMeshComponent Name=PawnSkeletalMesh
	  bCacheAnimSequenceNodes=false
	  AlwaysLoadOnClient=true
	  AlwaysLoadOnServer=true
	  bOwnerNoSee=false
	  CastShadow=true
	  BlockRigidBody=true
	  bUpdateSkelWhenNotRendered=false
	  bIgnoreControllersWhenNotRendered=true
	  bUpdateKinematicBonesFromAnimation=true
	  bCastDynamicShadow=false
	  Translation=(Z=8.0)
	  LightEnvironment=MyLightEnvironment
	  bOverrideAttachmentOwnerVisibility=true
	  bAcceptsDynamicDecals=false
	  SkeletalMesh=SkeletalMesh'SSG_Characters.Thief.SSG_Character_Thief_01'
      Materials(0)=Material'SSG_Characters.Thief.SSG_Character_Thief_MAT_01'
	  AnimTreeTemplate=AnimTree'SSG_Animations.SSG_Thief_AnimTree'
	  AnimSets=( AnimSet'SSG_Animations.AnimSet.SSG_Character_AnimSet_01' )
	  PhysicsAsset=PhysicsAsset'SSG_Characters.thief.SSG_Character_Thief_PHS_01'
	  bHasPhysicsAssetInstance=true
	  bEnableFullAnimWeightBodies=true
	  TickGroup=TG_PreAsyncWork
	  MinDistFactorForKinematicUpdate=0.0
	  Scale=1.0
	End Object
	Mesh = PawnSkeletalMesh
	Components.Add( PawnSkeletalMesh )

	Begin Object Class=PointLightComponent Name=ThiefColorLight
		TickGroup=TG_DuringAsyncWork
		bEnabled=false;
		CastDynamicShadows=false;
		FalloffExponent=10.0;
	End Object
	ThiefLight=ThiefColorLight;
	Components.Add(ThiefColorLight);

	Begin Object Class=ParticleSystemComponent Name=PowerUpSystem
		TickGroup=TG_DuringAsyncWork
	End Object

	Begin Object Class=ParticleSystemComponent Name=FirstSwingSystem
		TickGroup=TG_DuringAsyncWork
		bAutoActivate=false
		Translation=(X=0.0,Y=40.0,Z=27.0)
		Rotation=(Roll=-16384)
		Template=ParticleSystem'SSG_Weapon_Particles.swordtrail.SSG_Particles_SwordArch_PS_01'
	End Object
	SwordFirstSwingParticleSystem=FirstSwingSystem
	Components.Add(FirstSwingSystem)

	Begin Object Class=ParticleSystemComponent Name=SecondSwingSystem
		TickGroup=TG_DuringAsyncWork
		bAutoActivate=false
		Translation=(X=0.0,Y=40.0,Z=27.0)
		Rotation=(Roll=16384,Pitch=32768)
		Template=ParticleSystem'SSG_Weapon_Particles.swordtrail.SSG_Particles_SwordArch_PS_01'
	End Object
	SwordSecondSwingParticleSystem=SecondSwingSystem
	Components.Add(SecondSwingSystem)

	Begin Object Class=ParticleSystemComponent Name=FrostSystem
		TickGroup=TG_DuringAsyncWork
		bAutoActivate=false
		Template=ParticleSystem'SSG_Character_Particles.Frost_Slowed.SSG_Particles_FrostSlowed_PS_01'
	End Object
	FrostParticleSystem=FrostSystem
	Components.Add(FrostSystem)

	TakeDamageEffect=(ParticleTemplate=ParticleSystem'SSG_Character_Particles.Blood.SSG_Particles_Blood_Spray_PS_01')
	BloodDecal=MaterialInstanceTimeVarying'SSG_Decals_01.Blood.SSG_Decal_Blood_Splatter_DecalMITV_01'

	DeadEffectTemplateBot=ParticleSystem'SSG_Character_Particles.DeathSkull.SSG_Particles_DeathSkull_PS_01'
	DeadEffectTemplatePlayer1=ParticleSystem'SSG_Character_Particles.DeathSkull.SSG_Particles_DeathSkull_PS_02'
	DeadEffectTemplatePlayer2=ParticleSystem'SSG_Character_Particles.DeathSkull.SSG_Particles_DeathSkull_PS_03'
	DeadEffectTemplatePlayer3=ParticleSystem'SSG_Character_Particles.DeathSkull.SSG_Particles_DeathSkull_PS_04'
	DeadEffectTemplatePlayer4=ParticleSystem'SSG_Character_Particles.DeathSkull.SSG_Particles_DeathSkull_PS_05'

	ConfusionEffectTemplate=ParticleSystem'SSG_Character_Particles.Drunk.SSG_Particle_Drunk_PS_01'
	
	DrownEffectTemplate=ParticleSystem'SSG_Environment_Particles.Water.SSG_Particles_WaterSplash_PS_01'

	ForwardFacingArrow=StaticMesh'SSG_Character_Particles.HUD.SSG_HUD_FacingArrow_02'

	SoundGroupClass=class'SSG_Sound_PawnSoundGroup'

	CustomGravityScaling=0.0
}
