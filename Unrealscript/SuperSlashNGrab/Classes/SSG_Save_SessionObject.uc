class SSG_Save_SessionObject extends Object
	implements (SSG_Save_SaveGameInterface);


var string PlayerNames[4];

var int NextLevel;

const SAVEGAME_REVISION = 0;

//----------------------------------------------------------------------------------------------------------
function GenerateSession()
{
	local SSG_PlayerController currentPlayer;
	local LocalPlayer CurrentPlayerAsLocalPlayer;
	local int CurrentPlayerIndex;

	foreach class'WorldInfo'.static.GetWorldInfo().AllControllers(class'SSG_PlayerController', currentPlayer)
	{
		CurrentPlayerAsLocalPlayer = LocalPlayer(currentPlayer.Player);
		if (CurrentPlayerAsLocalPlayer != none)
		{
			CurrentPlayerIndex = CurrentPlayerAsLocalPlayer.ControllerId;
		}
		else
		{
			CurrentPlayerIndex = currentPlayer.PlayerNum;
		}
		//currentPlayer.PlayerReplicationInfo.PlayerName = "IYAMAPLAYER"$CurrentPlayerIndex;
		PlayerNames[CurrentPlayerIndex] = currentPlayer.ThiefName;
	}
}

//----------------------------------------------------------------------------------------------------------
function SaveToDisk()
{
	class'Engine'.static.BasicSaveObject(self, "../../Saves/LastSession.ssg", true, self.const.SAVEGAME_REVISION, false);
}

//----------------------------------------------------------------------------------------------------------
function LoadFromDisk()
{
	class'Engine'.static.BasicLoadObject(self, "../../Saves/LastSession.ssg", true, self.const.SAVEGAME_REVISION);
}

//----------------------------------------------------------------------------------------------------------
function string Serialize()
{
	local string SerializedString;
	local JsonObject SerializedObject;

	SerializedObject = new class'JsonObject';
	SerializedObject.SetStringValue("Player1Name", PlayerNames[0]);
	SerializedObject.SetStringValue("Player2Name", PlayerNames[1]);
	SerializedObject.SetStringValue("Player3Name", PlayerNames[2]);
	SerializedObject.SetStringValue("Player4Name", PlayerNames[3]);

	
	SerializedString = class'JsonObject'.static.EncodeJson(SerializedObject);

	return SerializedString;
}

//----------------------------------------------------------------------------------------------------------
function Deserialize(JsonObject data)
{
	PlayerNames[0] = data.GetStringValue("Player1Name");
	PlayerNames[1] = data.GetStringValue("Player2Name");
	PlayerNames[2] = data.GetStringValue("Player3Name");
	PlayerNames[3] = data.GetStringValue("Player4Name");
}

//----------------------------------------------------------------------------------------------------------
DefaultProperties
{
	PlayerNames(0)="none"
	PlayerNames(1)="none"
	PlayerNames(2)="none"
	PlayerNames(3)="none"
	nextLevel = 0
}
