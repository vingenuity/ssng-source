class SSG_Inventory_PowerUp extends SSG_Inventory_Base
	abstract;

//----------------------------------------------------------------------------------------------------------
var() ParticleSystem   PickupParticleSystem;
var() ParticleSystem   OnPlayerParticleSystem;


//----------------------------------------------------------------------------------------------------------
DefaultProperties
{
	bDropOnDeath = false
	RespawnTime = 9999
}
