class SSG_Proj_Arrow extends SSG_Proj_Base;

//----------------------------------------------------------------------------------------------------------
var ParticleSystem ExplosionParticle;


//----------------------------------------------------------------------------------------------------------
simulated function SpawnExplosionEffects( Vector HitLocation, Vector HitNormal )
{
	WorldInfo.MyEmitterPool.SpawnEmitter( ExplosionParticle, HitLocation, Rotator( -HitNormal ) );
}


//----------------------------------------------------------------------------------------------------------
simulated function Destroyed()
{
	SpawnExplosionEffects( Location, Vector( Rotation ) * -1.0 );
	Super.Destroyed();
}


//----------------------------------------------------------------------------------------------------------
DefaultProperties
{
	Speed=1500.0
	Damage=1.0
	MomentumTransfer=40000.0
	LifeSpan=2.0

	ProjFlightTemplate=ParticleSystem'SSG_Trap_Particles.Bolt.SSG_Weapon_Crossbow_Bolt_PS_01'
	MyDamageType=class'SSG_DmgType_Projectile'
	ExplosionParticle=ParticleSystem'SSG_Weapon_Particles.BoltHit.SSG_Particle_BoltHit_PS_01'
}
