class SSG_Bot_Map extends SSG_Bot;

event NewHome(SSG_PatrolNode NextHome)
{
	Home = NextHome.Location;
}

event NewHomeByIndex(int index)
{
	local SSG_POI_LevelSelectNode CurrentNode;
	foreach WorldInfo.AllNavigationPoints(class'SSG_POI_LevelSelectNode', CurrentNode)
	{
		if(CurrentNode.LevelSelectIndex == index)
		{
			NewHome(CurrentNode);
		}
	}
}

auto state MapMode
{

	function Contemplate()
	{
		GotoState('MapMode', 'Continuous');
	}

Begin:


Continuous:
	if(VSize(Pawn.Location - Home) > BotPathTolerance)
	{
		NavigationHandle.ClearConstraints();
        NavigationHandle.PathGoalList = none;
		NavigationHandle.SetFinalDestination(Home);
		class'NavmeshPath_Toward'.static.TowardPoint(NavigationHandle,Home);
		class'NavMeshGoal_At'.static.AtLocation(NavigationHandle, Home);
		if(NavigationHandle.PointReachable(Home))
		{
			MoveTo(Home);
		}
		else if(NavigationHandle.FindPath())
		{

			while( NavigationHandle.GetNextMoveLocation( NextDestinationInPath, BotPathTolerance) )
			{
			    MoveTo(NextDestinationInPath);
			}
		}
	}
	else
	{
		Pawn.ZeroMovementVariables();
	}

}

DefaultProperties
{
	PathName="MapBot"
}
