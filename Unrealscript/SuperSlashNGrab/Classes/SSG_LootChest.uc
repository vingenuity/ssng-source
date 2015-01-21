class SSG_LootChest extends Actor
	ClassGroup( LootContainer )
	placeable;

//----------------------------------------------------------------------------------------------------------
var name                        ChestAnim;
var float						ThrowForce;
var() int						NumSmallTreasureMin;
var() int						NumSmallTreasureMax;
var() int						NumMediumTreasureMin;
var() int						NumMediumTreasureMax;
var() int						NumLargeTreasureMin;
var() int						NumLargeTreasureMax;
var bool                        bIsOpen;
var Vector						LocOffset;
var() SkeletalMeshComponent		SkelMesh;
var MaterialInstanceConstant    MIC;
var() float						FresnelGlowMinDistance;
var() float						FresnelGlowMaxDistance;
var(Sounds) SoundCue            OpenSoundCue;


//----------------------------------------------------------------------------------------------------------
const TREASURE_SPEW_ANGLE = 75.0;


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

	MIC = new class'MaterialInstanceConstant';
	MIC.SetParent( SkelMesh.GetMaterial(0) );
	SkelMesh.SetMaterial( 0, MIC );
}


//----------------------------------------------------------------------------------------------------------
function Tick( float DeltaTime )
{
	Super.Tick( DeltaTime );
}


//----------------------------------------------------------------------------------------------------------
event TakeDamage(int DamageAmount, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	local SSG_LootSpawner spawner;

	if( bIsOpen )
		return;

	PlaySound( OpenSoundCue );

	spawner = Spawn( class'SSG_LootSpawner',,, Location + LocOffset, Rotation );
	spawner.NumSmallTreasureToDrop = NumSmallTreasureMin + Rand( ( NumSmallTreasureMax - NumSmallTreasureMin ) + 1 );
	spawner.NumMediumTreasureToDrop = NumMediumTreasureMin + Rand( ( NumMediumTreasureMax - NumMediumTreasureMin ) + 1 );
	spawner.NumLargeTreasureToDrop = NumLargeTreasureMin + Rand( ( NumLargeTreasureMax - NumLargeTreasureMin ) + 1 );
	spawner.TreasureThrowAngle = TREASURE_SPEW_ANGLE;

	SkelMesh.PlayAnim( ChestAnim, 0.5, false );
	bIsOpen = true;
}


//----------------------------------------------------------------------------------------------------------
function SetFresnelGlow( bool isActive )
{
	local float FresnelLevel;
	local float CheckFresnelLevel;
	local float DistanceBetweenPoints;
	local SSG_PlayerController PC;
	local LinearColor FresnelColor;

	FresnelLevel = 0.0;

	if( isActive )
	{
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

	ThrowForce=500.0
	NumSmallTreasureMin=0
	NumSmallTreasureMax=0
	NumMediumTreasureMin=0
	NumMediumTreasureMax=0
	NumLargeTreasureMin=0
	NumLargeTreasureMax=0
	bIsOpen=false
	FresnelGlowMinDistance=250
	FresnelGlowMaxDistance=350

	LocOffset=(X=0.0,Y=0.0,Z=85.0)

	ChestAnim=SSG_Environment_Prop_Chest_01
	OpenSoundCue=SoundCue'MiscSounds.ChestCUE'

	Begin Object class=AnimNodeSequence Name=MeshSequenceA
	End Object

	Begin Object Class=SkeletalMeshComponent Name=ChestSkelMeshComponent
		CollideActors=true
		BlockActors=true
		SkeletalMesh=SkeletalMesh'SSG_Props_01.Meshes.SSG_Environment_Props_Chest_01'
		AnimSets(0)=AnimSet'SSG_Props_01.Anims.SSG_Environment_Props_Chest_ANIM_02'
		Animations=MeshSequenceA
		Translation=(X=-40.0,Y=70.0,Z=0.0)
	End Object
	SkelMesh=ChestSkelMeshComponent
	Components.Add(ChestSkelMeshComponent)

	Begin Object Class=CylinderComponent Name=CollisionCylinder
		CollisionRadius=60.0
		CollisionHeight=100.0
		BlockNonZeroExtent=true
		BlockZeroExtent=true
		BlockActors=true
		CollideActors=true
	End Object
	CollisionComponent=CollisionCylinder
	Components.Add( CollisionCylinder )
}
