class SSG_Trap_Cannon extends SSG_Trap_Base
	placeable;

//----------------------------------------------------------------------------------------------------------
var(SSG_Trap_Base) SkeletalMeshComponent	SkelMesh;
var(SSG_Trap_Base) Name                     SmokeSocketName;
var class<SSG_Proj_Base>                    ProjectileClass;
var SoundCue                                CannonFireCue;
var ParticleSystemComponent                 Smoke;
var bool						            bIsInFiringCooldown;

//----------------------------------------------------------------------------------------------------------
function PostBeginPlay()
{
	Super.PostBeginPlay();

	TrapMeshMIC = new class'MaterialInstanceConstant';
	TrapMeshMIC.SetParent( SkelMesh.GetMaterial(0) );
	SkelMesh.SetMaterial( 0, TrapMeshMIC );

	SkelMesh.AttachComponentToSocket( Smoke, SmokeSocketName );
}


//----------------------------------------------------------------------------------------------------------
function Tick( float DeltaTime )
{
	if( !bTrapActive )
	{
		bIsInFiringCooldown = false;
	}
	else if( !bIsInFiringCooldown )
	{
		ProjectileFire();

		if( Smoke.bIsActive )
		{
			Smoke.SetActive( false );
		}

		Smoke.SetActive( true );
		bIsInFiringCooldown = true;
	}

	Super.Tick( DeltaTime );
}


//----------------------------------------------------------------------------------------------------------
simulated event Vector GetPhysicalFireStartLoc(optional vector AimDir)
{
    local SkeletalMeshSocket MeshSocket;
    local Vector SocketWorldLocation;
 
    if( SkelMesh != none )
    {
        MeshSocket = SkelMesh.GetSocketByName('CannonBarrel');
 
        if( MeshSocket != none )
        {
        	SkelMesh.GetSocketWorldLocationAndRotation( 'CannonBarrel', SocketWorldLocation );
            return SocketWorldLocation;
        }
    }
}


//----------------------------------------------------------------------------------------------------------
function Projectile ProjectileFire()
{
	local Vector		StartLoc, AimDir;
	local Projectile	SpawnedProjectile;

	AimDir = Vector(Rotation);
	StartLoc = GetPhysicalFireStartLoc(AimDir);

	// Spawn projectile
	SpawnedProjectile = Spawn( ProjectileClass, Self,, StartLoc, /*rotation*/, /*template*/, false );
	if( SpawnedProjectile != None && !SpawnedProjectile.bDeleteMe )
	{
		SpawnedProjectile.Init( AimDir );
	}

	PlaySound( CannonFireCue );

	// Return it up the line
	return SpawnedProjectile;
}


//----------------------------------------------------------------------------------------------------------
DefaultProperties
{
	TickGroup=TG_PreAsyncWork
	SecondsOfActivation=0.0
	SmokeSocketName="SmokeSocket"

	ProjectileClass=class'SSG_Proj_Cannonball_Fast'

	Begin Object Class=ParticleSystemComponent Name=CannonSmokeParticleSystem
		Template=ParticleSystem'SSG_Trap_Particles.cannonball.SSG_Particle_Cannon_Fire_PS_01'
        bAutoActivate=false
	End Object
	Smoke=CannonSmokeParticleSystem
	Components.Add(CannonSmokeParticleSystem)

	Begin Object Class=SkeletalMeshComponent Name=CannonSkeletalMeshComponent
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
		SkeletalMesh=SkeletalMesh'SSG_Traps.Cannon.SSG_Trap_Cannon_02'
		PhysicsAsset=PhysicsAsset'SSG_Traps.Cannon.SSG_Trap_Cannon_02_Physics'
	End Object
	SkelMesh=CannonSkeletalMeshComponent
	Components.Add( CannonSkeletalMeshComponent )

	CannonFireCue=SoundCue'SSG_TrapSounds.CannonFireCUE'

	//Begin Object Name=TrapStaticMeshComponent
	//	StaticMesh=StaticMesh'SSG_Traps.Cannon.SSG_Trap_Cannon'
	//End Object
}
