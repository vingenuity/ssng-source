class SSG_PowerUpEmitter extends Actor;

//----------------------------------------------------------------------------------------------------------
var ParticleSystemComponent PowerUpParticleSystem;


//----------------------------------------------------------------------------------------------------------
DefaultProperties
{
	bIgnoreBaseRotation=true

	Begin Object Class=ParticleSystemComponent Name=PowerUpSystem
		bAutoActivate=false
	End Object
	PowerUpParticleSystem=PowerUpSystem
	Components.Add(PowerUpSystem)
}
