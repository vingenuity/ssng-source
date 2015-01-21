class SSG_Bot extends UDKBot;


var() int SightRange;
var() int AttackRange;
var() int HearingRange;
var() float LengthOfMeadEffect;
var bool DebugCaresAboutHumans;
var() bool bIsCurious;

var SSG_Pawn TargetPlayer;
var Vector TargetAttractor;
var Vector LastKnownTargetLocation;

var() Vector Home; 
var Vector nextDestinationInPath;

var() string PathName;

var array<SSG_PatrolNode> PatrolPath;

var() Actor StationaryOrientationTarget;

var string ReasonIAmNotMoving;

/** Structure defining a pre-made character in the game. */
struct CharacterInfo
{
	/** Short unique string . */
	var string CharID;

	/** This defines which 'set' of parts we are drawing from. */
	var string FamilyID;

	/** Friendly name for character. */
	var localized string CharName;

	/** Localized description of the character. */
	var localized string Description;

	/** Preview image markup for the character. */
	var string PreviewImageMarkup;

	/** Faction to which this character belongs (e.g. IronGuard). */
	var string Faction;

	/** AI personality */
	//var CustomAIData AIData;
};


var int stateNodeIterator;
var SSG_PatrolNode stateCurrentNodeTarget;

var int BotPathTolerance;
var() float WaitTimeAtNodes;
var float TimeWaitedSoFar;

function NewMeadWander();
function EndMead();


//----------------------------------------------------------------------------------------------------------
function Tick( float DeltaTime )
{
	super.Tick(DeltaTime);
	TimeWaitedSoFar+=DeltaTime;
	if(SSG_GameInfo(WorldInfo.Game).CurrentSection == SSG_Pawn_Bot(Pawn).SectionNumber ||  SSG_Pawn_Bot(Pawn).SectionNumber == -1)
	{
		Contemplate();
	}
	else if(GetStateName() != 'DoNothing')
	{
		PushState('DoNothing');
	}
}

//----------------------------------------------------------------------------------------------------------
function Contemplate();

//----------------------------------------------------------------------------------------------------------
function Initialize(float InSkill, const out CharacterInfo BotInfo)
{
	//Stripped from UTBot
}

//----------------------------------------------------------------------------------------------------------
event Possess(Pawn inPawn, bool bVehicleTransition)
{
	local SSG_PatrolNode currentNode;
	local SSG_Pawn_Bot PossesionTargetAsSSG;

    super.Possess(inPawn, bVehicleTransition);
	PossesionTargetAsSSG = SSG_Pawn_Bot(inPawn);
    Pawn.SetMovementPhysics();
	Home = Pawn.Location;
	NavigationHandle = new(self) class'NavigationHandle';
	PathName = PossesionTargetAsSSG.PatrolName;
	//search for all patrolNodes and add the relevant ones to my patrol path
	foreach AllActors(class'SSG_PatrolNode', currentNode)
	{
		if(currentNode.BotNames.Find(PathName) != INDEX_NONE)
		{
			PatrolPath.AddItem(currentNode);
		}
	}
	if(PatrolPath.Length > 0)
	{
		stateCurrentNodeTarget = PatrolPath[0];
	}

	StationaryOrientationTarget = PossesionTargetAsSSG.LookAtTargetWhenIdle;
	AttackRange = PossesionTargetAsSSG.RangeToBeginAttacking;
	HearingRange = PossesionTargetAsSSG.AlertRange;
	WaitTimeAtNodes = PossesionTargetAsSSG.TimeToWaitAtNodes;
	bIsCurious = PossesionTargetAsSSG.bBotIsCurious;

	if(!(SSG_GameInfo(WorldInfo.Game).CurrentSection == SSG_Pawn_Bot(Pawn).SectionNumber ||  SSG_Pawn_Bot(Pawn).SectionNumber == -1))
	{
		PushState('DoNothing');
	}

}

//----------------------------------------------------------------------------------------------------------
function StartMonitoring(Pawn P, float MaxDist)
{
	MonitoredPawn = P;
	MonitorStartLoc = P.Location;
	MonitorMaxDistSq = MaxDist * MaxDist;
}

//----------------------------------------------------------------------------------------------------------
function DoAlertGuard(Vector AlertSource)
{
	if(VSize(Pawn.Location - AlertSource) < HearingRange)
	{
		TargetAttractor = AlertSource;
		GotoState('Investigating');
	}
}

//----------------------------------------------------------------------------------------------------------
event onSSGMead(SeqAct_SSGMead action)
{
	DoMead();
}

//----------------------------------------------------------------------------------------------------------
function DoMead()
{
	//Removed the mead state
	//GotoState('Mead', 'Begin');
}

//----------------------------------------------------------------------------------------------------------
auto state Revert
{
	//------------------------------------------------
	event SeePlayer(Pawn SeenPlayer)
	{
		if(DebugCaresAboutHumans)
		{
			TargetPlayer = SSG_Pawn(SeenPlayer);
			if(TargetPlayer != none)
			{
				if(VSize(TargetPlayer.Location - Pawn.Location) < SightRange && Abs(TargetPlayer.Location.z - Pawn.Location.z) < 64.0)
				{       
					StartMonitoring(TargetPlayer, SightRange);
					Enemy = TargetPlayer;
					//chase
					GotoState('Chase');
				}
			}
		}
	}

	//------------------------------------------------
	function Contemplate()
	{
		GotoState('Revert', 'Begin');
	}

///////////////////////////////////////
Begin:
	//If we have no home, we're already there
	if(PatrolPath.Length == 0)
	{
		ReasonIAmNotMoving="HOMELESS";
		Home = vect(0,0,0);
		GotoState('Idle');
	}
	//Otherwise go to nearest node
	for(stateNodeIterator = 0; stateNodeIterator < PatrolPath.Length; stateNodeIterator++)
	{
		if(VSize(PatrolPath[stateNodeIterator].Location - Pawn.Location) < VSize(stateCurrentNodeTarget.Location - Pawn.Location))
		{
			stateCurrentNodeTarget = PatrolPath[stateNodeIterator];
		}
		//if(stateCurrentNodeTarget.NextNode != none)
		//{
			Home = stateCurrentNodeTarget.Location;
		//}
	}
	if(VSize(Pawn.Location - Home) > BotPathTolerance)
	{
		NavigationHandle.ClearConstraints();
        NavigationHandle.PathGoalList = none;
		NavigationHandle.SetFinalDestination(Home);
		class'NavmeshPath_Toward'.static.TowardPoint(NavigationHandle,Home);
		class'NavMeshGoal_At'.static.AtLocation(NavigationHandle, Home);
		if(NavigationHandle.PointReachable(Home))
		{
			ReasonIAmNotMoving="Going Home";
			MoveTo(Home, none, -0.5*BotPathTolerance, true);
		}
		else if(NavigationHandle.FindPath())
		{

			while( NavigationHandle.GetNextMoveLocation( NextDestinationInPath, BotPathTolerance) )
			{
				ReasonIAmNotMoving="Finding Home";
			    MoveTo(NextDestinationInPath, none, -0.5*BotPathTolerance, true);
			}
			GotoState('Idle');
		}
		else
		{
			ReasonIAmNotMoving="NO PATH HOME";
		}
	}
	else
	{
		ReasonIAmNotMoving="Already Home";
		TimeWaitedSoFar = 0.0;
		GotoState('Idle');
	}

}

//----------------------------------------------------------------------------------------------------------
state Chase
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
		GotoState('Chase', 'Begin');
	}

//////////////////////////////////////////////////////
Begin:
	//confirm the target
	if(MonitoredPawn != none)
	{
		//if in range
		if(VSize(MonitoredPawn.Location - Pawn.Location) < AttackRange)
		{
			//attack them
			GotoState('Attacking');
		}
		else
		{
			//go towards them
			if(IsAimingAt(MonitoredPawn, 0.001))
			{
				MoveToward(MonitoredPawn, MonitoredPawn, BotPathTolerance+8, false, false);//hacky tolerance
			}
		}
	}
	//else switch to revert
	else
	{
		GotoState('Revert');
	}
}

//----------------------------------------------------------------------------------------------------------
state Attacking
{
	//------------------------------------------------
	event MonitoredPawnAlert()
	{
		LastKnownTargetLocation = LastSeenPos;
		GotoState('Curious');
	}
	
	//------------------------------------------------
	function Contemplate()
	{
		GotoState('Attacking', 'Begin');
	}

	//------------------------------------------------
	event EnemyNotVisible()
	{
		LastKnownTargetLocation = LastSeenPos;
		GotoState('Curious');
	}
	
	//------------------------------------------------
	event EndState(Name NextStateName)
	{
		Pawn.StopFiring();
		Focus = none;
	}

//////////////////////////////////////////////////////
Begin:
	//if target is valid (exists, can see)
	if(MonitoredPawn != none)
	{
		// if target in range
		if(VSize(MonitoredPawn.Location - Pawn.Location) <= AttackRange+5) //slightly hacky tolerance
		{
			// attack them
			Pawn.ZeroMovementVariables();
			Focus = MonitoredPawn;
			Pawn.BotFire(false);
		}
		else
		{
			// else chase them
			GotoState('Chase');
		}
	}
	else
	{
		//else revert
		GotoState('Revert');
	}
}

//----------------------------------------------------------------------------------------------------------
state Idle
{
	//------------------------------------------------
	event SeePlayer(Pawn SeenPlayer)
	{
		if(DebugCaresAboutHumans)
		{
			TargetPlayer = SSG_Pawn(SeenPlayer);
			if(TargetPlayer != none)
			{
				if(VSize(TargetPlayer.Location - Pawn.Location) < SightRange && Abs(TargetPlayer.Location.z - Pawn.Location.z) < 64.0)
				{
					Home = Pawn.Location;
					StartMonitoring(TargetPlayer, SightRange);
					Enemy = TargetPlayer;
					//chase
					GotoState('Chase');
				}
			}
		}
	}
	
	//------------------------------------------------
	function Contemplate()
	{
		GotoState('Idle', 'Begin');
	}

////////////////////////////////////////////////////////////////
Begin:
	//walk between our nodes
	if(TimeWaitedSoFar < WaitTimeAtNodes)
	{
		//do nothing
		Pawn.ZeroMovementVariables();
		ReasonIAmNotMoving="Pausing";
	}
	//No path given/found
	else if(stateCurrentNodeTarget == none)
	{
		ReasonIAmNotMoving="WANDERING";
		if(IsZero(Home) || VSize(Home - Pawn.Location) < 128)
		{
			NavigationHandle.ClearConstraints();
			NavigationHandle.PathGoalList = none;
			//class'NavmeshPath_WithinDistanceEnvelope'.static.StayWithinEnvelopeToLoc(NavigationHandle,Pawn.Location, 2048, 1024);
			class'NavMeshGoal_Random'.static.FindRandom(NavigationHandle, 1024);
			if(NavigationHandle.FindPath())
			{
				Home = NavigationHandle.PathCache_GetGoalPoint();
				NavigationHandle.ClearConstraints();
				NavigationHandle.PathGoalList = none;
				NavigationHandle.SetFinalDestination(Home);
				class'NavmeshPath_Toward'.static.TowardPoint(NavigationHandle,Home);
				class'NavMeshGoal_At'.static.AtLocation(NavigationHandle, Home);
				NavigationHandle.GetNextMoveLocation( NextDestinationInPath, BotPathTolerance);
			}
			else
			{
				//Removed because it was being ignored anyways
				//`Warn("No valid path found! Check to make sure there is a valid pylon.");
				ReasonIAmNotMoving="NO VALID PATH";
				Home = vect(0,0,0);
			}
		}
		
		if(NavigationHandle.PointReachable(Home))
		{
			ReasonIAmNotMoving="Wandering";
			MoveTo(Home, none, -0.5*BotPathTolerance, true);	
		}
		else
		{
			if(NavigationHandle.FindPath())
			{
				ReasonIAmNotMoving="Wandering2";
				NavigationHandle.GetNextMoveLocation( NextDestinationInPath, BotPathTolerance);
			    MoveTo(NextDestinationInPath, none, -0.5*BotPathTolerance, true);				
			}
			else
			{
				ReasonIAmNotMoving="NO VALID PATH2";
				Home = vect(0,0,0);			
			}
		}
	}
	//One or more nodes in path
	else if(VSize(Pawn.Location - Home) > BotPathTolerance*0.75)
	{
		ReasonIAmNotMoving="MOVING";
		NavigationHandle.ClearConstraints();
        NavigationHandle.PathGoalList = none;
		NavigationHandle.SetFinalDestination(Home);
		class'NavmeshPath_Toward'.static.TowardPoint(NavigationHandle,Home);
		class'NavMeshGoal_At'.static.AtLocation(NavigationHandle, Home);
		if(NavigationHandle.PointReachable(Home))
		{
			ReasonIAmNotMoving="Walking";
			MoveTo(Home, none, -1*BotPathTolerance, true);	
		}
		else if(NavigationHandle.FindPath())
		{
			ReasonIAmNotMoving="INTOLERANT";
			while( NavigationHandle.GetNextMoveLocation( NextDestinationInPath, BotPathTolerance) )
			{
				ReasonIAmNotMoving="Pathing";
			    MoveTo(NextDestinationInPath, none, -1*BotPathTolerance, true);
			}
		}
		else
		{
			ReasonIAmNotMoving="Reverting";
			GotoState('Revert');
		}
	}
	else
	{
		ReasonIAmNotMoving="UNSURE";
		if(stateCurrentNodeTarget.NextNode != none)
		{
			TimeWaitedSoFar = 0.0;
			stateCurrentNodeTarget = stateCurrentNodeTarget.NextNode;
			Focus = stateCurrentNodeTarget;
			Pawn.ZeroMovementVariables();
		}
		else if(StationaryOrientationTarget != none)
		{
			ReasonIAmNotMoving="No Next Node";
			Pawn.ZeroMovementVariables();
			Focus = StationaryOrientationTarget;
		}
		else
		{
			ReasonIAmNotMoving="No Next Node";
			Pawn.ZeroMovementVariables();
		}
	Home = stateCurrentNodeTarget.Location;		
	}
}

//----------------------------------------------------------------------------------------------------------
state DoNothing
{
	ignores SeePlayer, DoAlertGuard, Contemplate;
Begin:
	Pawn.ZeroMovementVariables();
}

//----------------------------------------------------------------------------------------------------------
state Investigating
{
	//------------------------------------------------
	event SeePlayer(Pawn SeenPlayer)
	{
		if(DebugCaresAboutHumans)
		{
			TargetPlayer = SSG_Pawn(SeenPlayer);
			if(TargetPlayer != none)
			{
				if(VSize(TargetPlayer.Location - Pawn.Location) < SightRange && Abs(TargetPlayer.Location.z - Pawn.Location.z) < 64.0)
				{
					Home = Pawn.Location;
					StartMonitoring(TargetPlayer, SightRange);
					Enemy = TargetPlayer;
					//chase
					GotoState('Chase');
				}
			}
		}
	}

	//------------------------------------------------
	function Contemplate()
	{
		GotoState('Investigating', 'Begin');
	}

////////////////////////////////////////////////////////////////
Begin:

	if(VSize(Pawn.Location - TargetAttractor) > BotPathTolerance*2)
	{
		NavigationHandle.ClearConstraints();
        NavigationHandle.PathGoalList = none;
		NavigationHandle.SetFinalDestination(TargetAttractor);
		class'NavmeshPath_Toward'.static.TowardPoint(NavigationHandle,TargetAttractor);
		class'NavMeshGoal_At'.static.AtLocation(NavigationHandle, TargetAttractor);
		if(NavigationHandle.PointReachable(TargetAttractor))
		{
			MoveTo(TargetAttractor, none, -0.5*BotPathTolerance, true);
		}
		else if(NavigationHandle.FindPath())
		{

			while( NavigationHandle.GetNextMoveLocation( NextDestinationInPath, BotPathTolerance) )
			{
			    MoveTo(NextDestinationInPath, none, -0.5*BotPathTolerance, true);
			}
			
		}
		else
		{
			GotoState('Revert');
		}
	}
	else
	{
		GotoState('Revert');
	}

}


//----------------------------------------------------------------------------------------------------------
state Mead
{
	ignores SeePlayer, DoAlertGuard;
	
	//------------------------------------------------
	function NewMeadWander()
	{		
		NavigationHandle.ClearConstraints();
		NavigationHandle.PathGoalList = none;
		class'NavmeshPath_WithinDistanceEnvelope'.static.StayWithinEnvelopeToLoc(NavigationHandle,Pawn.Location, 2048, 1024);
		class'NavMeshGoal_Random'.static.FindRandom(NavigationHandle);
	}

	//------------------------------------------------
	function Contemplate()
	{
		GotoState('Mead', 'Contemplating');
	}

	//------------------------------------------------
	function EndMead()
	{
		GotoState('Revert');
	}
	
	//------------------------------------------------
	event BeginState(name n)
	{
		SetTimer(LengthOfMeadEffect, false, nameOf(EndMead));
	}

////////////////////////////////////////////////////////////////
Begin:
	SetTimer(LengthOfMeadEffect, false, nameOf(EndMead));//total length of mead wandering

////////////////////////////////////////////////////////////////
Contemplating:
	if(NavigationHandle.FindPath())
	{
		while( NavigationHandle.GetNextMoveLocation( NextDestinationInPath, BotPathTolerance) )
		{
		    MoveTo(NextDestinationInPath, none, -0.5*BotPathTolerance, true);
		}
	}
	else
	{
		NewMeadWander();
	}
}

//----------------------------------------------------------------------------------------------------------
state Curious
{
	//------------------------------------------------
	event SeePlayer(Pawn SeenPlayer)
	{
		if(DebugCaresAboutHumans)
		{
			TargetPlayer = SSG_Pawn(SeenPlayer);
			if(TargetPlayer != none)
			{
				if(VSize(TargetPlayer.Location - Pawn.Location) < SightRange && Abs(TargetPlayer.Location.z - Pawn.Location.z) < 64.0)
				{
					Home = Pawn.Location;
					StartMonitoring(TargetPlayer, SightRange);
					Enemy = TargetPlayer;
					//chase
					GotoState('Chase');
				}
			}
		}
	}

	//------------------------------------------------
	function Contemplate()
	{
		GotoState('Curious', 'Begin');
	}

////////////////////////////////////////////////////////////////
Begin:
	if(!bIsCurious)
	{
		GotoState('Revert');
	}
	else if(VSize(Pawn.Location - LastKnownTargetLocation) > BotPathTolerance*2)
	{
		NavigationHandle.ClearConstraints();
        NavigationHandle.PathGoalList = none;
		NavigationHandle.SetFinalDestination(LastKnownTargetLocation);
		class'NavmeshPath_Toward'.static.TowardPoint(NavigationHandle,LastKnownTargetLocation);
		class'NavMeshGoal_At'.static.AtLocation(NavigationHandle, LastKnownTargetLocation);
		if(NavigationHandle.PointReachable(LastKnownTargetLocation))
		{
			MoveTo(LastKnownTargetLocation);
		}
		else if(NavigationHandle.FindPath())
		{
			while( NavigationHandle.GetNextMoveLocation( NextDestinationInPath, BotPathTolerance) )
			{
			    MoveTo(NextDestinationInPath);
			}
		}
		else
		{
			GotoState('Revert');
		}
	}
	else
	{
		GotoState('Revert');
	}

}

DefaultProperties
{
	MonitoredPawn = None
	SightRange = 1024
	AttackRange = 128
	BotPathTolerance = 56
	HearingRange = 2048
	LengthOfMeadEffect = 10.0
	DebugCaresAboutHumans = true
	WaitTimeAtNodes=0.5
	TimeWaitedSoFar=0.0
	bIsCurious = false
	ReasonIAmNotMoving="UNINITIALIZED"
}
