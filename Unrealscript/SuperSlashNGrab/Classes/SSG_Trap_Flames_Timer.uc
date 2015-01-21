class SSG_Trap_Flames_Timer extends SSG_Trap_Flames
	placeable;

//----------------------------------------------------------------------------------------------------------
var(SSG_Trap_Base) bool bRequireTriggerActivation;
var(SSG_Trap_Base) float SecondsDelayBeforeStart;
var(SSG_Trap_Base) float SecondsBetweenActivations;
var float SecondsSinceDeactive;


//----------------------------------------------------------------------------------------------------------
function Tick( float DeltaTime )
{
	if( NumLoopsActive != 0 && CurrentLoopNum <= 0 )
		return;

	if( bRequireTriggerActivation && !bTrapActive )
	{
		return;
	}
	else if( bRequireTriggerActivation && bTrapActive )
	{
		bRequireTriggerActivation = false;
	}

	if( SecondsDelayBeforeStart > 0.0 )
	{
		SecondsDelayBeforeStart -= DeltaTime;
		return;
	}

	Super.Tick( DeltaTime );

	if( SecondsSinceDeactive >= SecondsBetweenActivations )
	{
		SecondsSinceDeactive = 0.0;
		bTrapActive = true;
	}
	else if( !bTrapActive )
	{
		SecondsSinceDeactive += DeltaTime;
	}
}


//----------------------------------------------------------------------------------------------------------
DefaultProperties
{
	bTrapActive=true
	bRequireTriggerActivation=false

	SecondsOfActivation=1.15

	SecondsDelayBeforeStart=0.0
	SecondsBetweenActivations=3.0
	SecondsSinceDeactive=0.0

	Begin Object Name=TrapFlameParticleSystem
        Template=ParticleSystem'SSG_Trap_Particles.Fire.SSG_Fire_PS_01'
	End Object
}
