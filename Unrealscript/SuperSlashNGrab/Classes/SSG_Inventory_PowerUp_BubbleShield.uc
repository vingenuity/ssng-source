class SSG_Inventory_PowerUp_BubbleShield extends SSG_Inventory_PowerUp;

//----------------------------------------------------------------------------------------------------------
var ParticleSystem  ShieldParticleSystemByPlayer[4];


//----------------------------------------------------------------------------------------------------------
DefaultProperties
{
	PickupSound=SoundCue'MiscSounds.PowerUp2CUE'
	PickupParticleSystem=ParticleSystem'SSG_PowerUps_01.Shield.SSG_Powerups_Shield_Pickup_02'
	OnPlayerParticleSystem=ParticleSystem'SSG_PowerUps_01.Shield.SSG_Powerups_Shield_Active_PS_01'

	ShieldParticleSystemByPlayer(0)=ParticleSystem'SSG_PowerUps_01.Shield.SSG_Powerups_Shield_Active_PS_01'
	ShieldParticleSystemByPlayer(1)=ParticleSystem'SSG_PowerUps_01.Shield.SSG_Powerups_Shield_Active_PS_02'
	ShieldParticleSystemByPlayer(2)=ParticleSystem'SSG_PowerUps_01.Shield.SSG_Powerups_Shield_Active_PS_03'
	ShieldParticleSystemByPlayer(3)=ParticleSystem'SSG_PowerUps_01.Shield.SSG_Powerups_Shield_Active_PS_04'
}
