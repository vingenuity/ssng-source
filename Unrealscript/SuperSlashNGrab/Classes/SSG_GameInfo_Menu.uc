class SSG_GameInfo_Menu extends UDKGame;

//++++++++++++++++++++++++++++++++++++++++++++ Load and Save ++++++++++++++++++++++++++++++++++++++++++++++//
//----------------------------------------------------------------------------------------------------------
exec function SaveProfile()
{
	local SSG_Save_SessionObject CurrentSession;

	CurrentSession = new class'SSG_Save_SessionObject';
	CurrentSession.GenerateSession();
	CurrentSession.SaveToDisk();
}


//----------------------------------------------------------------------------------------------------------
exec function LoadAllProfiles()
{
	local SSG_PlayerController CurrentPlayer;
	local LocalPlayer CurrentPlayerAsLocalPlayer;
	local SSG_Save_SessionObject CurrentSession;
	local int CurrentPlayerIndex;

	CurrentSession = new class'SSG_Save_SessionObject';
	CurrentSession.LoadFromDisk();

	foreach WorldInfo.AllControllers(class'SSG_PlayerController', CurrentPlayer)
	{
		CurrentPlayerAsLocalPlayer = LocalPlayer(CurrentPlayer.Player);
		if (CurrentPlayerAsLocalPlayer != none)
		{
			CurrentPlayerIndex = CurrentPlayerAsLocalPlayer.ControllerId;
			CurrentPlayer.ThiefName = CurrentSession.PlayerNames[CurrentPlayerIndex];
		}
	}
}


DefaultProperties
{

	PlayerControllerClass=class'SuperSlashNGrab.SSG_PlayerController'
}
