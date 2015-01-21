class SSG_Trap_Trigger_MultiUse extends SSG_Trap_Trigger
	ClassGroup( Traps, Triggers )
	placeable;

//----------------------------------------------------------------------------------------------------------
	var SoundCue 				BreakSoundCue;



//----------------------------------------------------------------------------------------------------------
function UpdateActivation()
{
	local SSG_Trap_Base Trap;

	if( SecondsSinceActive >= SecondsAfterActiveBeforeFire && !bActivatedTraps )
	{
		foreach TrapsToTrigger( Trap )
		{
			if( Trap == None )
				continue;

			Trap.bTrapActive = true;
			if( bResetLoopCount )
				Trap.CurrentLoopNum = Trap.NumLoopsActive;
		}
		
		ActivateTriggerEvent( class'SSG_SeqEvent_TriggerUsed' );
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
	SkelMesh.PlayAnim( TriggerAnim, SecondsOfActivation, false );

	//BCD: Play Use Sound
	PlaySound( BreakSoundCue );
}


//----------------------------------------------------------------------------------------------------------
DefaultProperties
{
	BreakSoundCue=SoundCue'SSG_TrapSounds.Triggers.HitMetalTriggerMultiUseCue'
	SecondsOfActivation=1.5
	TriggerAnim=SSG_Trap_TriggerLever_01

	Begin Object Name=TriggerSkeletalMeshComponent
		SkeletalMesh=SkeletalMesh'SSG_Traps.TriggerLever.SSG_Trap_TriggerLever_Metal_01'
	End Object
}
