
/*DEPRECATED*/
class SSG_Save_ProfileObject extends Object
	implements (SSG_Save_SaveGameInterface);



var string ProfileName;

var int NumDeaths;

var int NumGoldCollected;

var int PlayerNumInLastSession;

var int Highscores[4];

const SAVEGAME_REVISION = 1;



//----------------------------------------------------------------------------------------------------------
function GenerateProfile(SSG_PlayerController PlayerProfile)
{
	local LocalPlayer CurrentPlayerAsLocalPlayer;
	local int i;

	CurrentPlayerAsLocalPlayer = LocalPlayer(PlayerProfile.Player);
	if(CurrentPlayerAsLocalPlayer != none)
	{
		PlayerNumInLastSession = CurrentPlayerAsLocalPlayer.ControllerId;
	}
	else
	{
		PlayerNumInLastSession = PlayerProfile.PlayerNum;
	}
	ProfileName = PlayerProfile.ThiefName;
	NumGoldCollected = PlayerProfile.LifetimeGold;
	NumDeaths = PlayerProfile.LivesLived;
	for(i = 0; i < 4; i++)
	{
		Highscores[i] = PlayerProfile.Highscores[i];
	}
}

//----------------------------------------------------------------------------------------------------------
function SaveToDisk()
{
	class'Engine'.static.BasicSaveObject(self, "../../Saves/"$ProfileName$"profile.ssg", true, self.const.SAVEGAME_REVISION, false);
}

//----------------------------------------------------------------------------------------------------------
function LoadFromDisk(string ProfileForLoad)
{
	class'Engine'.static.BasicLoadObject(self, "../../Saves/"$ProfileForLoad$"profile.ssg", true, self.const.SAVEGAME_REVISION);
}

//----------------------------------------------------------------------------------------------------------
function ExportToProfile(out SSG_PlayerController PlayerProfile)
{   
	local int i;

	PlayerProfile.ThiefName = ProfileName;
	PlayerProfile.LifetimeGold = NumGoldCollected;
	PlayerProfile.LivesLived = NumDeaths;
	for(i = 0; i < 4; i++)
	{
		 PlayerProfile.Highscores[i] = Highscores[i];
	}
	//player num intentionally ignored
}

//----------------------------------------------------------------------------------------------------------
function ExportToPlayerNum(int ControllerIndex)
{
	local SSG_PlayerController CurrentPlayer;
	local LocalPlayer CurrentPlayerAsLocalPlayer;
	local int i;

	foreach class'WorldInfo'.static.GetWorldInfo().AllControllers(class'SSG_PlayerController', CurrentPlayer)
	{
		CurrentPlayerAsLocalPlayer = LocalPlayer(CurrentPlayer.Player);
		if(CurrentPlayerAsLocalPlayer != none)
		{
			if(CurrentPlayerAsLocalPlayer.ControllerId == ControllerIndex)
			{
				CurrentPlayer.ThiefName = ProfileName;
				CurrentPlayer.LifetimeGold = NumGoldCollected;
				CurrentPlayer.LivesLived = NumDeaths;
				for(i = 0; i < 4; i++)
				{
					CurrentPlayer.Highscores[i] = Highscores[i];
				}
			}
		}
	}
}

//----------------------------------------------------------------------------------------------------------
function ExportToPreviousPlayerNum()
{
	local SSG_PlayerController CurrentPlayer;
	local LocalPlayer CurrentPlayerAsLocalPlayer;
	local int i;

	foreach class'WorldInfo'.static.GetWorldInfo().AllControllers(class'SSG_PlayerController', CurrentPlayer)
	{
		CurrentPlayerAsLocalPlayer = LocalPlayer(CurrentPlayer.Player);
		if(CurrentPlayerAsLocalPlayer != none)
		{
			if(CurrentPlayerAsLocalPlayer.ControllerId == PlayerNumInLastSession)
			{
				CurrentPlayer.ThiefName = ProfileName;
				CurrentPlayer.LifetimeGold = NumGoldCollected;
				CurrentPlayer.LivesLived = NumDeaths;
				for(i = 0; i < 4; i++)
				{
					CurrentPlayer.Highscores[i] = Highscores[i];
				}
			}
		}
	}
}

//----------------------------------------------------------------------------------------------------------
function string Serialize()
{
	local string SerializedString;
	local JsonObject SerializedObject;

	SerializedObject = new class'JsonObject';
	SerializedObject.SetStringValue("ProfileName", ProfileName);
	SerializedObject.SetIntValue("NumDeaths", NumDeaths);
	SerializedObject.SetIntValue("NumGoldCollected", NumGoldCollected);
	SerializedObject.SetIntValue("PlayerNumInLastSession", PlayerNumInLastSession);
	
	SerializedString = class'JsonObject'.static.EncodeJson(SerializedObject);

	return SerializedString;
}

//----------------------------------------------------------------------------------------------------------
function Deserialize(JsonObject data)
{
	ProfileName = data.GetStringValue("ProfileName");
	NumDeaths = data.GetIntValue("NumDeaths");
	NumGoldCollected = data.GetIntValue("NumGoldCollected");
	PlayerNumInLastSession = data.GetIntValue("PlayerNumInLastSession");
}

//----------------------------------------------------------------------------------------------------------
DefaultProperties
{
	NumDeaths=1
	NumGoldCollected=0
	PlayerNumInLastSession=0
	ProfileName="none"
	Highscores[0]=0
	Highscores[1]=0
	Highscores[2]=0
	Highscores[3]=0
}
