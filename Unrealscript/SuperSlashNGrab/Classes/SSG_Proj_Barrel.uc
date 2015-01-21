class SSG_Proj_Barrel extends Projectile;

//----------------------------------------------------------------------------------------------------------
var StaticMeshComponent StaticMeshComponent1;

var MaterialInstanceConstant BarrelMaterial;

var ParticleSystem BarrelTrail[4];

var ParticleSystem ActiveTrailTemplate;
var ParticleSystemComponent ActiveTrail;

var int SpawnPlayerID;
var float SecondsSinceSpawn;

var(Sounds) SoundCue BreakSoundCue;


//----------------------------------------------------------------------------------------------------------
function Tick( float DeltaTime )
{
	local Rotator BarrelRotation;

	Super.Tick( DeltaTime );

	SecondsSinceSpawn += DeltaTime;
	BarrelRotation.Pitch = RadToUnrRot * SecondsSinceSpawn * 7.0;
	SetRotation( BarrelRotation );

	if( Physics != PHYS_Falling )
		Explode( Location, Vect( 0, 0, 1 ) );
}


//----------------------------------------------------------------------------------------------------------
function SetColor(int PlayerNum)
{
	local StaticMeshComponent BarrelComponent;
	local LinearColor PlayerColor;

	BarrelComponent = StaticMeshComponent(ZeroColliderComponent);

	BarrelMaterial = new class'MaterialInstanceConstant';
	BarrelMaterial.SetParent( BarrelComponent.GetMaterial(0) );
	BarrelComponent.SetMaterial( 0, BarrelMaterial );
	PlayerColor = class'SSG_PlayerController'.default.PlayerColors[PlayerNum];
	BarrelMaterial.SetVectorParameterValue( 'Player_Color', PlayerColor);
}


//----------------------------------------------------------------------------------------------------------
function PrepareForPlayer(int PlayerID)
{
	SpawnPlayerID = PlayerID;
	SetPhysics(PHYS_Falling);
	SetColor(PlayerID);
	ActiveTrailTemplate = BarrelTrail[PlayerID];
	if(ActiveTrail == none)
	{
		ActiveTrail = new class'ParticleSystemComponent';
		ActiveTrail.SetTemplate(ActiveTrailTemplate);
		//ActiveTrail.SetTranslation(vect(0,0,100));
		AttachComponent(ActiveTrail);
		
	}
	ActiveTrail.ActivateSystem();
}


//----------------------------------------------------------------------------------------------------------
simulated function ProcessTouch(Actor Other, Vector HitLocation, Vector HitNormal)
{
	if( Other.IsA( 'SSG_Proj_Barrel' ) || Other.IsA( 'SSG_Pawn' ) )
	{
		return;
	}
	Explode(HitLocation, HitNormal);
}


//----------------------------------------------------------------------------------------------------------
simulated singular event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal )
{
	if( Other.IsA( 'SSG_Proj_Barrel' ) || Other.IsA( 'SSG_Pawn' ) )
	{
		return;
	}
	Explode(HitLocation, HitNormal);
}


//----------------------------------------------------------------------------------------------------------
simulated function Explode(vector HitLocation, vector HitNormal)
{
	local SSG_PlayerController PC;

	PlaySound( BreakSoundCue );
	ActiveTrail.DeactivateSystem();
	Super.Explode( HitLocation, HitNormal );

	foreach WorldInfo.AllControllers( class'SSG_PlayerController', PC )
	{
		if( LocalPlayer( PC.Player ).ControllerId == SpawnPlayerID )
		{
			PC.DelayedSpawn();
			break;
		}
	}
}


//----------------------------------------------------------------------------------------------------------
DefaultProperties
{
	SecondsSinceSpawn=0.0

	Velocity=(X=0.0,Y=0.0,Z=-500.0)

	Begin Object Class=StaticMeshComponent Name=StaticMeshComponent1
		StaticMesh=StaticMesh'SSG_Character_Particles.RespawnBarrels.SSG_Props_RespawnBarrel_01'
		Translation=(X=0.0,Y=0.0,Z=-48.0)
		//bAllowApproximateOcclusion=TRUE
		//bForceDirectLightMap=TRUE
		//bUsePrecomputedShadows=TRUE
	End Object
	CollisionComponent=StaticMeshComponent1
	ZeroColliderComponent=StaticMeshComponent1
	Components.Add(StaticMeshComponent1)

	Physics=PHYS_Falling
	bStatic=false
	bMovable=true

	BreakSoundCue=SoundCue'SSG_WeaponSounds.Impacts.HitWoodCrate'

	BarrelTrail[0]=ParticleSystem'SSG_Character_Particles.RespawnBarrels.SSG_Particles_RespawnBarrels_Trail_PS_01'
	BarrelTrail[1]=ParticleSystem'SSG_Character_Particles.RespawnBarrels.SSG_Particles_RespawnBarrels_Trail_PS_02'
	BarrelTrail[2]=ParticleSystem'SSG_Character_Particles.RespawnBarrels.SSG_Particles_RespawnBarrels_Trail_PS_03'
	BarrelTrail[3]=ParticleSystem'SSG_Character_Particles.RespawnBarrels.SSG_Particles_RespawnBarrels_Trail_PS_04'
}
