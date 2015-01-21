class SSG_Trap_Cannon_Timer extends SSG_Trap_Cannon
	placeable;

//----------------------------------------------------------------------------------------------------------
var(SSG_Trap_Base) bool bRequireTriggerActivation;
var(SSG_Trap_Base) float SecondsDelayBeforeStart;
var(SSG_Trap_Base) float SecondsBetweenActivations;
var float SecondsSinceDeactive;


//----------------------------------------------------------------------------------------------------------
function Tick( float DeltaTime )
{
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
	bRequireTriggerActivation=false
	SecondsDelayBeforeStart=0.0
	SecondsBetweenActivations=3.0
	SecondsSinceDeactive=0.0
	ProjectileClass=class'SSG_Proj_Cannonball_Slow'
}
