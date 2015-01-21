class SSG_Proj_Cannonball extends SSG_Proj_Base;

/** decal for explosion */
var MaterialInterface ExplosionDecal;
var ParticleSystem ExplosionParticle;
var float DecalWidth, DecalHeight;

//----------------------------------------------------------------------------------------------------------
simulated function ProcessTouch( Actor Other, Vector HitLocation, Vector HitNormal )
{
	if ( Other != Instigator )
    {
		//WorldInfo.MyDecalManager.SpawnDecal ( DecalMaterial'SandboxContent.Materials.DM_Paintball_Splash', HitLocation, Rotator( -HitNormal ), 128, 128, 256, false, FRand() * 360, none );
		Other.TakeDamage( Damage, InstigatorController, Location, MomentumTransfer * Normal( Velocity ), MyDamageType,, self );
        //Destroy();
    }
}

//----------------------------------------------------------------------------------------------------------
/**
 * Spawn Explosion Effects
 */
simulated function SpawnExplosionEffects(vector HitLocation, vector HitNormal)
{
	local Vector DecalSpawnLocation;
	local MaterialInstanceTimeVarying MITV_Decal;

	// this code is mostly duplicated in:  UTGib, UTProjectile, UTVehicle, UTWeaponAttachment be aware when updating
	if (ExplosionDecal != None && Pawn(ImpactedActor) == None )
	{
		DecalSpawnLocation = HitLocation - CylinderComponent.CollisionRadius * HitNormal;
		WorldInfo.MyEmitterPool.SpawnEmitter( ExplosionParticle, HitLocation, Rotator( -HitNormal ) );

		if( MaterialInstanceTimeVarying(ExplosionDecal) != none )
		{
			// hack, since they don't show up on terrain anyway
			if ( Terrain(ImpactedActor) == None )
			{
				MITV_Decal = new(self) class'MaterialInstanceTimeVarying';
				MITV_Decal.SetParent( ExplosionDecal );

				WorldInfo.MyDecalManager.SpawnDecal(MITV_Decal, DecalSpawnLocation, rotator(-HitNormal), DecalWidth, DecalHeight, 10.0, FALSE );
				//here we need to see if we are an MITV and then set the burn out times to occur
				//MITV_Decal.SetScalarStartTime( DecalDissolveParamName, DurationOfDecal );
			}
		}
		else
		{
			WorldInfo.MyDecalManager.SpawnDecal( ExplosionDecal, DecalSpawnLocation, rotator(-HitNormal), DecalWidth, DecalHeight, 10.0, true );
		}
	}
}

//----------------------------------------------------------------------------------------------------------
simulated function Destroyed()
{
	SpawnExplosionEffects(Location, vector(Rotation) * -1);
	super.Destroyed();
}

//----------------------------------------------------------------------------------------------------------
DefaultProperties
{
	bCanBeDamaged=false

	Speed=1000.0
	Damage=1.0
	DamageRadius=1.0
	MomentumTransfer=40000.0

	DecalHeight = 120.0
	DecalWidth = 120.0
	ExplosionDecal=MaterialInstanceTimeVarying'SSG_Decals_01.ExplosionMarks.SSG_Decal_Cannonball_Hit_DecalMITV_01'
	ExplosionParticle=ParticleSystem'SSG_Trap_Particles.cannonball.SSG_Particle_CannonBall_Hit_PS_01'

	ProjFlightTemplate=ParticleSystem'SSG_Trap_Particles.cannonball.SSG_Particles_CannonBall_PS_01'

	ProjAmbientSound=SoundCue'SSG_TrapSounds.CannonballCUE'
	ProjExplosionSound=SoundCue'SSG_TrapSounds.CannonballExplosionCUE'
	MyDamageType=class'SSG_DmgType_Cannon'

	Begin Object Name=CollisionCylinder
		CollisionRadius=20
		CollisionHeight=20
	End Object
}
