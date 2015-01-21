class SSG_Bot_Shield extends SSG_Bot;

var() int ShieldUpRange;

state Chase
{


//////////////////////////////////////////////////////
Begin:
	//confirm the target
	if(MonitoredPawn != none)
	{
		//if in range
		if(VSize(MonitoredPawn.Location - Pawn.Location) < ShieldUpRange)
		{
			//attack them
			GotoState('BlockAndApproach');
		}
		else
		{
			//go towards them
			MoveToward(MonitoredPawn, MonitoredPawn, BotPathTolerance+8, false, false);//hacky tolerance
		}
	}
	//else switch to revert
	else
	{
		GotoState('Revert');
	}
}

state BlockAndApproach
{
	//------------------------------------------------
	event MonitoredPawnAlert()
	{
		LastKnownTargetLocation = LastSeenPos;
		GotoState('Curious');
	}
	
	//------------------------------------------------
	event EnemyNotVisible()
	{
		LastKnownTargetLocation = LastSeenPos;
		GotoState('Curious');
	}

	//------------------------------------------------
	function Contemplate()
	{
		GotoState('BlockAndApproach', 'Begin');
	}

	//------------------------------------------------
	event EndState(Name NextStateName)
	{
		Pawn.StopFiring();
	}

//////////////////////////////////////////////////////
Begin:
	//confirm the target
	if(MonitoredPawn != none)
	{
		//if in range
		if(VSize(MonitoredPawn.Location - Pawn.Location) <= AttackRange)
		{
			//attack them
			GotoState('Attacking');
		}
		else
		{
			//go towards them
			SSG_Pawn_ShieldBot(Pawn).BotBlock(false);
			MoveToward(MonitoredPawn, MonitoredPawn, BotPathTolerance, false, true);//hacky tolerance
		}
	}
	//else switch to revert
	else
	{
		GotoState('Revert');
	}
}


//----------------------------------------------------------------------------------------------------------
DefaultProperties
{
	ShieldUpRange = 512
	AttackRange = 128
}
