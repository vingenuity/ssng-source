
/*DEPRECATED*/
class SSG_Save_AllPlayers extends Object
	implements (SSG_Save_SaveGameInterface);

var array<string> PlayerNames;

const SAVEGAME_REVISION = 1;

//----------------------------------------------------------------------------------------------------------
function AddPlayer(string pName)
{
	PlayerNames.AddItem(pName);
}

//----------------------------------------------------------------------------------------------------------
function SaveToDisk()
{
	class'Engine'.static.BasicSaveObject(self, "../../Saves/AllPlayers.ssg", true, self.const.SAVEGAME_REVISION, false);
}

//----------------------------------------------------------------------------------------------------------
function LoadFromDisk()
{
	class'Engine'.static.BasicLoadObject(self, "../../Saves/AllPlayers.ssg", true, self.const.SAVEGAME_REVISION);
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
}
