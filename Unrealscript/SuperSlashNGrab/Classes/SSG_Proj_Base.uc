class SSG_Proj_Base extends UDKProjectile;

//----------------------------------------------------------------------------------------------------------
var ParticleSystem			ProjFlightTemplate;
var ParticleSystem			ProjExplosionTemplate;
var ParticleSystemComponent	ProjEffects;
var SoundCue				ProjAmbientSound;
var SoundCue				ProjExplosionSound;


//----------------------------------------------------------------------------------------------------------
simulated function PostBeginPlay()
{
	local AudioComponent AmbientComponent;

	Super.PostBeginPlay();

	ProjEffects = WorldInfo.MyEmitterPool.SpawnEmitterCustomLifetime(ProjFlightTemplate);
	ProjEffects.SetAbsolute(false, false, false);
	ProjEffects.bUpdateComponentInTick = true;
	AttachComponent(ProjEffects);

	if( ProjAmbientSound != None )
	{
		AmbientComponent = CreateAudioComponent( ProjAmbientSound, true, true );
		if( AmbientComponent != None )
		{
			AmbientComponent.bShouldRemainActiveIfDropped = true;
		}
	}
}


//----------------------------------------------------------------------------------------------------------
function Init( Vector Direction )
{
	Super.Init( Direction );
	Velocity.Z = 0;
}


//----------------------------------------------------------------------------------------------------------
simulated function Explode(vector HitLocation, vector HitNormal)
{
	if( ProjExplosionSound != None )
	{
		PlaySound( ProjExplosionSound );
	}

	Super.Explode( HitLocation, HitNormal );
}


//----------------------------------------------------------------------------------------------------------
simulated function ProcessTouch( Actor Other, Vector HitLocation, Vector HitNormal )
{
	if ( Other != Instigator )
    {
		//WorldInfo.MyDecalManager.SpawnDecal ( DecalMaterial'SandboxContent.Materials.DM_Paintball_Splash', HitLocation, Rotator( -HitNormal ), 128, 128, 256, false, FRand() * 360, none );
		Other.TakeDamage( Damage, InstigatorController, Location, MomentumTransfer * Normal( Velocity ), MyDamageType,, self );
		if( ProjExplosionSound != None )
		{
			PlaySound( ProjExplosionSound );
		}

        Destroy();
    }
}


//----------------------------------------------------------------------------------------------------------
DefaultProperties
{
	MyDamageType=class'SSG_DmgType_Projectile'
	DamageRadius=2.0

	Begin Object Class=StaticMeshComponent Name=ProjStaticMeshComponent
    End Object
    Components.Add( ProjStaticMeshComponent )
}
