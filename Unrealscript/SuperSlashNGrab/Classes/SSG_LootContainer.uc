class SSG_LootContainer extends Actor
	ClassGroup( LootContainer )
	placeable;

//----------------------------------------------------------------------------------------------------------
var float							ThrowForce;
var() int							NumSmallTreasureMin;
var() int							NumSmallTreasureMax;
var() int							NumMediumTreasureMin;
var() int							NumMediumTreasureMax;
var() int							NumLargeTreasureMin;
var() int							NumLargeTreasureMax;
var Vector							LocOffset;
var() StaticMeshComponent			StaticMesh;
var MaterialInstanceConstant		MIC;
var() ParticleSystemComponent		SmashPSC;
var() MaterialInstanceTimeVarying   SplinterDecal;
var bool							bIsParticlePlaying;
var() bool                          bPreventDecalSpawn;
var() bool                          bPreventMeshBasedVarOverride;
var() float							ParticleScale;
var() float                         DecalSize;
var() float							FresnelGlowMinDistance;
var() float							FresnelGlowMaxDistance;
var(Sounds) SoundCue				BreakSoundCue;


//----------------------------------------------------------------------------------------------------------
function PostBeginPlay()
{
	Super.PostBeginPlay();

	if( NumSmallTreasureMax < NumSmallTreasureMin )
		NumSmallTreasureMax = NumSmallTreasureMin;

	if( NumMediumTreasureMax < NumMediumTreasureMin )
		NumMediumTreasureMax = NumMediumTreasureMin;

	if( NumLargeTreasureMax < NumLargeTreasureMin )
		NumLargeTreasureMax = NumLargeTreasureMin;

	SetMeshDependentVariables();
	SmashPSC.SetScale( ParticleScale );

	MIC = new class'MaterialInstanceConstant';
	MIC.SetParent( StaticMesh.GetMaterial(0) );
	StaticMesh.SetMaterial( 0, MIC );
}


//----------------------------------------------------------------------------------------------------------
function SetMeshDependentVariables()
{
	if( bPreventMeshBasedVarOverride )
		return;

	if( StaticMesh.StaticMesh == StaticMesh'SSG_Props_01.Meshes.SSG_Environment_LC_Props_Wheatsack_01'
		|| StaticMesh.StaticMesh == StaticMesh'SSG_Props_02.Meshes.SSG_Environment_Props_HayBale_01')
	{
		SmashPSC.SetTemplate( ParticleSystem'SSG_Environment_Particles.OtherDebris.SSG_Particles_HayDebris_PS_01' );
		SplinterDecal=MaterialInstanceTimeVarying'SSG_Decals_01.Hay.SSG_Decal_Hay_DecalMITV_01';
		BreakSoundCue=SoundCue'SSG_WeaponSounds.Impacts.HitFlourSackCue';
		ParticleScale = 1.5;
		DecalSize = 100.0;
	}
	else if( StaticMesh.StaticMesh == StaticMesh'SSG_Props_01.Meshes.SSG_Environment_LC_Props_WoodPile')
	{
		SmashPSC.SetTemplate( ParticleSystem'SSG_Environment_Particles.WoodDebris.SSG_Particles_WoodDebris_PS_01' );
		SplinterDecal=MaterialInstanceTimeVarying'SSG_Decals_01.Wood_Splinter.SSG_Decal_Wood_Splinter_DecalMITV_01';
		BreakSoundCue=SoundCue'SSG_WeaponSounds.Impacts.BookshelfImpactCue';
		ParticleScale = 1.5;
		DecalSize = 100.0;
	}
	else if( StaticMesh.StaticMesh == StaticMesh'SSG_Props_01.Meshes.SSG_Environment_LC_Props_Wheatsack_01')
	{
		SmashPSC.SetTemplate( ParticleSystem'SSG_Environment_Particles.OtherDebris.SSG_Particles_HayDebris_PS_01' );
		SplinterDecal=MaterialInstanceTimeVarying'SSG_Decals_01.Hay.SSG_Decal_Hay_DecalMITV_01';
		BreakSoundCue=SoundCue'SSG_WeaponSounds.Impacts.HitFlourSackCue';
		ParticleScale = 1.5;
		DecalSize = 100.0;
	}
	else if( StaticMesh.StaticMesh == StaticMesh'SSG_Props_01.Meshes.SSG_Environment_LC_Props_Crate_01')
	{
		SmashPSC.SetTemplate( ParticleSystem'SSG_Environment_Particles.WoodDebris.SSG_Particles_WoodDebris_PS_01' );
		SplinterDecal=MaterialInstanceTimeVarying'SSG_Decals_01.Wood_Splinter.SSG_Decal_Wood_Splinter_DecalMITV_01';
		BreakSoundCue=SoundCue'SSG_WeaponSounds.Impacts.HitWoodCrate';
		ParticleScale = 1.5;
		DecalSize = 100.0;
	}
	else if( StaticMesh.StaticMesh == StaticMesh'SSG_Props_01.Meshes.SSG_Environment_LC_Prop_Bookshelf')
	{
		SmashPSC.SetTemplate( ParticleSystem'SSG_Environment_Particles.WoodDebris.SSG_Particles_WoodDebris_PS_01' );
		//SplinterDecal=MaterialInstanceTimeVarying'SSG_Decals_01.Wood_Splinter.SSG_Decal_Wood_Splinter_DecalMITV_01';
		BreakSoundCue=SoundCue'SSG_WeaponSounds.Impacts.BookshelfImpactCue';
		ParticleScale = 1.5;
		DecalSize = 100.0;
	}
	else if( StaticMesh.StaticMesh == StaticMesh'SSG_Props_01.Meshes.SSG_Environment_LC_Props_Barrel_01')
	{
		SmashPSC.SetTemplate( ParticleSystem'SSG_Environment_Particles.WoodDebris.SSG_Particles_WoodDebris_PS_01' );
		SplinterDecal=MaterialInstanceTimeVarying'SSG_Decals_01.Wood_Splinter.SSG_Decal_Wood_Splinter_DecalMITV_01';
		BreakSoundCue=SoundCue'SSG_WeaponSounds.Impacts.HitWoodBarrelCue';
		ParticleScale = 1.5;
		DecalSize = 75;
	}
	else if( StaticMesh.StaticMesh == StaticMesh'SSG_Props_01.Meshes.SSG_Environment_LC_Props_Table_Wood_01')
	{
		SmashPSC.SetTemplate( ParticleSystem'SSG_Environment_Particles.WoodDebris.SSG_Particles_WoodDebris_PS_01' );
		SplinterDecal=MaterialInstanceTimeVarying'SSG_Decals_01.Wood_Splinter.SSG_Decal_Wood_Splinter_DecalMITV_01';
		BreakSoundCue=SoundCue'SSG_WeaponSounds.Impacts.HitChairCue';
		ParticleScale = 1.5;
		DecalSize = 75;
	}
	else if( StaticMesh.StaticMesh == StaticMesh'SSG_Props_01.Meshes.SSG_Environment_LC_Props_Chair_Wood_01')
	{
		SmashPSC.SetTemplate( ParticleSystem'SSG_Environment_Particles.WoodDebris.SSG_Particles_WoodDebris_PS_01' );
		SplinterDecal=MaterialInstanceTimeVarying'SSG_Decals_01.Wood_Splinter.SSG_Decal_Wood_Splinter_DecalMITV_01';
		BreakSoundCue=SoundCue'SSG_WeaponSounds.Impacts.HitChairCue';
		ParticleScale = 1.5;
		DecalSize = 75;
	}
	else if( StaticMesh.StaticMesh == StaticMesh'SSG_Props_02.Meshes.SSG_Environment_LC_Props_Vase_01'
				|| StaticMesh.StaticMesh == StaticMesh'SSG_Props_02.Meshes.SSG_Environment_LS_Props_Urn_01')
	{
		SmashPSC.SetTemplate( ParticleSystem'SSG_Environment_Particles.OtherDebris.SSG_Particles_VaseDebris_PS_01' );
		SplinterDecal=MaterialInstanceTimeVarying'SSG_Decals_01.VaseDebris.SSG_Decal_VaseDebris_DecalMITV_01';
		BreakSoundCue=SoundCue'SSG_WeaponSounds.Impacts.UrnBreak02Sound_Cue';
		ParticleScale = 1.5;
		DecalSize = 100;
	}
	else
	{
		SmashPSC.SetTemplate( ParticleSystem'SSG_Environment_Particles.WoodDebris.SSG_Particles_WoodDebris_PS_01' );
		SplinterDecal=MaterialInstanceTimeVarying'SSG_Decals_01.Wood_Splinter.SSG_Decal_Wood_Splinter_DecalMITV_01';
		ParticleScale = 1.5;
		DecalSize = 100.0;
	}
}


//----------------------------------------------------------------------------------------------------------
function Tick( float DeltaTime )
{
	Super.Tick( DeltaTime );
	//SetFresnelGlow();
	CheckIfReadyToDestroy();
}


//----------------------------------------------------------------------------------------------------------
function CheckIfReadyToDestroy()
{
	if( bIsParticlePlaying && !SmashPSC.bIsActive )
		Destroy();
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
function TossInventory(Inventory Inv, optional vector ForceVelocity)
{
	local vector	POVLoc, TossVel;
	local rotator	POVRot;
	local Vector	X,Y,Z;

	if ( ForceVelocity != vect(0,0,0) )
	{
		TossVel = ForceVelocity;
	}
	else
	{
		GetActorEyesViewPoint(POVLoc, POVRot);
		TossVel = Vector(POVRot);
		TossVel = TossVel * ((Velocity Dot TossVel) + 500) + Vect(0,0,200);
	}

	GetAxes(Rotation, X, Y, Z);
	Inv.DropFrom( Location + LocOffset, TossVel);
}


//----------------------------------------------------------------------------------------------------------
event TakeDamage(int DamageAmount, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	//local int smallIndex;
	//local int mediumIndex;
	//local int largeIndex;
	//local int numSmallDrop;
	//local int numMediumDrop;
	//local int numLargeDrop;
	//local Inventory tossedTreasure;
	local SSG_LootSpawner spawner;

	PlaySound( BreakSoundCue );
	StaticMesh.SetHidden( true );
	SetCollision(false, false, false);

	spawner = Spawn( class'SSG_LootSpawner',,, Location + LocOffset, Rotation );
	spawner.NumSmallTreasureToDrop = NumSmallTreasureMin + Rand( ( NumSmallTreasureMax - NumSmallTreasureMin ) + 1 );
	spawner.NumMediumTreasureToDrop = NumMediumTreasureMin + Rand( ( NumMediumTreasureMax - NumMediumTreasureMin ) + 1 );
	spawner.NumLargeTreasureToDrop = NumLargeTreasureMin + Rand( ( NumLargeTreasureMax - NumLargeTreasureMin ) + 1 );

	//numSmallDrop = NumSmallTreasureMin + Rand( ( NumSmallTreasureMax - NumSmallTreasureMin ) + 1 );
	//numMediumDrop = NumMediumTreasureMin + Rand( ( NumMediumTreasureMax - NumMediumTreasureMin ) + 1 );
	//numLargeDrop = NumLargeTreasureMin + Rand( ( NumLargeTreasureMax - NumLargeTreasureMin ) + 1 );

	//for( smallIndex = 0; smallIndex < numSmallDrop; ++smallIndex )
	//{
	//	tossedTreasure = Spawn( class'SSG_Inventory_Treasure_Small' );
	//	TossInventory( tossedTreasure, CalculateRandom2DVector( ThrowForce ) );
	//}

	//for( mediumIndex = 0; mediumIndex < numMediumDrop; ++mediumIndex )
	//{
	//	tossedTreasure = Spawn( class'SSG_Inventory_Treasure_Medium' );
	//	TossInventory( tossedTreasure, CalculateRandom2DVector( ThrowForce ) );
	//}

	//for( largeIndex = 0; largeIndex < numLargeDrop; ++largeIndex )
	//{
	//	tossedTreasure = Spawn( class'SSG_Inventory_Treasure_Large' );
	//	TossInventory( tossedTreasure, CalculateRandom2DVector( ThrowForce ) );
	//}

	SmashPSC.SetScale( ParticleScale );
	SmashPSC.SetActive( true );
	bIsParticlePlaying = true;
	SpawnDecalBelowContainer();
	//WorldInfo.MyEmitterPool.SpawnEmitter( SmashPSC.Template, Location + LocOffset );

	//Destroy();
}


//----------------------------------------------------------------------------------------------------------
function SpawnDecalBelowContainer()
{
	local Vector HitLocation, HitNormal;
	local TraceHitInfo HitInfo;
	local float TraceDist, RandomRotation;

	if( bPreventDecalSpawn )
		return;

	RandomRotation = FRand() * 360.0 * DegToUnrRot;
	TraceDist = 1.5 * CylinderComponent( CollisionComponent ).CollisionHeight;
	Trace( HitLocation, HitNormal, Location - ( TraceDist * vect( 0.0, 0.0, 1.0 ) ), Location, false,, HitInfo, TRACEFLAG_PhysicsVolumes );
	WorldInfo.MyDecalManager.SpawnDecal( SplinterDecal, HitLocation, rotator( -HitNormal ), DecalSize, DecalSize, 10.0, false, RandomRotation );
}


//----------------------------------------------------------------------------------------------------------
function SetFresnelGlow()
{
	local float FresnelLevel;
	local float CheckFresnelLevel;
	local float DistanceBetweenPoints;
	local SSG_PlayerController PC;
	local LinearColor FresnelColor;

	FresnelLevel = 0.0;

	foreach WorldInfo.AllControllers( class'SSG_PlayerController', PC )
    {
		if( PC.Pawn == None )
			continue;

		DistanceBetweenPoints = VSize( PC.Pawn.Location - self.Location );
		CheckFresnelLevel = 1.0 - ( ( DistanceBetweenPoints - FresnelGlowMinDistance ) / ( FresnelGlowMaxDistance - FresnelGlowMinDistance ) );
		CheckFresnelLevel = FClamp( CheckFresnelLevel, 0.0, 1.0 );
		if( CheckFresnelLevel > FresnelLevel )
			FresnelLevel = CheckFresnelLevel;
    }

	FresnelColor.R = FresnelLevel;
	FresnelColor.G = FresnelLevel;
	FresnelColor.B = FresnelLevel;

	MIC.SetVectorParameterValue( 'Fresnel_Color', FresnelColor );
}


//----------------------------------------------------------------------------------------------------------
DefaultProperties
{
	bCollideActors=true
	bBlockActors=true
	bCanBeDamaged=true

	ThrowForce=500.0
	NumSmallTreasureMin=0
	NumSmallTreasureMax=0
	NumMediumTreasureMin=0
	NumMediumTreasureMax=0
	NumLargeTreasureMin=0
	NumLargeTreasureMax=0
	FresnelGlowMinDistance=250
	FresnelGlowMaxDistance=350

	LocOffset=(X=0.0,Y=0.0,Z=30.0)
	ParticleScale=1.0
	DecalSize=100.0
	bIsParticlePlaying=false
	bPreventDecalSpawn=false
	bPreventMeshBasedVarOverride=false

	BreakSoundCue=SoundCue'SSG_TrapSounds.MeadTrap.BarrelBreakCue'

	Begin Object Class=StaticMeshComponent Name=ContainerStaticMeshComponent
		CollideActors=true
		BlockActors=true
		StaticMesh=StaticMesh'SSG_Props_01.Meshes.SSG_Environment_LC_Props_Barrel_01'
	End Object
	StaticMesh=ContainerStaticMeshComponent
	Components.Add(ContainerStaticMeshComponent)

	Begin Object Class=ParticleSystemComponent Name=SmashParticleSystem
        bAutoActivate=false
	End Object
	SmashPSC=SmashParticleSystem
	Components.Add(SmashParticleSystem)

	Begin Object Class=CylinderComponent Name=CollisionCylinder
		CollisionRadius=40.0
		CollisionHeight=100.0
		BlockActors=false
		CollideActors=true
		Translation=(Z=70.0)
	End Object
	CollisionComponent=CollisionCylinder
	Components.Add( CollisionCylinder )
}
