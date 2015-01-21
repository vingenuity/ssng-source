class SSG_Trap_Trigger_Toggle extends SSG_Trap_Trigger
	ClassGroup( Traps, Triggers )
	placeable;

//----------------------------------------------------------------------------------------------------------
var bool    bTriggerOn;
var Name    TriggerTurnOnAnim;
var Name    TriggerTurnOffAnim;


//----------------------------------------------------------------------------------------------------------
function UpdateActivation()
{
	local SSG_Trap_Base Trap;

	if( SecondsSinceActive >= SecondsAfterActiveBeforeFire && !bActivatedTraps )
	{
		bTriggerOn = !bTriggerOn;

		foreach TrapsToTrigger( Trap )
		{
			if( Trap == None )
				continue;

			Trap.bTrapActive = !Trap.bTrapActive;
			if( bResetLoopCount )
				Trap.CurrentLoopNum = Trap.NumLoopsActive;
		}

		if( bTriggerOn )
			ActivateTriggerEvent( class'SSG_SeqEvent_TriggerTurnedOn' );
		else
			ActivateTriggerEvent( class'SSG_SeqEvent_TriggerTurnedOff' );
	
		bActivatedTraps = true;
	}
}


//----------------------------------------------------------------------------------------------------------
event TakeDamage(int DamageAmount, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	if( bTrapActive )
		return;

	if( EventInstigator == None || EventInstigator.Pawn == None )
		return;

	if( DamageType == class'SSG_DmgType_Projectile' )
		return;

	Super.TakeDamage( DamageAmount, EventInstigator, HitLocation, Momentum, DamageType, HitInfo, DamageCauser );
	if( bTriggerOn )
		TriggerAnim = TriggerTurnOffAnim;
	else
		TriggerAnim = TriggerTurnOnAnim;

	SkelMesh.PlayAnim( TriggerAnim, SecondsOfActivation, false );

	//BCD: Play activation sound
	PlaySound(SoundCue'SSG_TrapSounds.Triggers.HitMetalTriggerToggleCue');
}


//----------------------------------------------------------------------------------------------------------
DefaultProperties
{
	bTriggerOn=false
	SecondsOfActivation=0.6667
	SecondsAfterActiveBeforeFire=0.3333
	TriggerTurnOnAnim=SSG_Trap_TriggerLever_OneWay_Start_01
	TriggerTurnOffAnim=SSG_Trap_TriggerLever_OneWay_Return_01

	Begin Object Name=TriggerSkeletalMeshComponent
		SkeletalMesh=SkeletalMesh'SSG_Traps.TriggerLever.SSG_Trap_TriggerLever_Metal_01'
	End Object
}
