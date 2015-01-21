class SSG_Save_HighScore extends Object
	implements (SSG_Save_SaveGameInterface);

const NUM_LEVELS = 4;
const HIGHSCORE_LENGTH = 3;

struct HighScoreEntry
{
	var int LevelScore;
	var string LevelWinner;

	structdefaultproperties
	{
		LevelScore=0;
		LevelWinner="none";
	}

};

struct LevelHighScore
{
	var array<HighScoreEntry> HighScoreTable;
};

var array<LevelHighScore> AllHighScores;


var int LevelScore[4];

var string LevelWinner[4];


const SAVEGAME_REVISION = 1;

//----------------------------------------------------------------------------------------------------------
/**@return the index of the new highscore (starting at 0), -1 if not on the list*/
function int InsertScoreIntoList(SSG_PlayerController ScoringPlayer, int LevelIndex)
{
	local int i;
	local HighScoreEntry PlayerHighScore;

	for(i = 0; i < AllHighScores[LevelIndex].HighScoreTable.Length; i++)
	{
		if(AllHighScores[LevelIndex].HighScoreTable[i].LevelScore < ScoringPlayer.MoneyEarned)
		{
			//insert new highscore
			PlayerHighScore.LevelScore = ScoringPlayer.MoneyEarned;
			PlayerHighScore.LevelWinner = ScoringPlayer.ThiefName;
			AllHighScores[LevelIndex].HighScoreTable.InsertItem(i, PlayerHighScore);
			return i;
		}
	}
	if(AllHighScores[LevelIndex].HighScoreTable.Length < HIGHSCORE_LENGTH)
	{
		PlayerHighScore.LevelScore = ScoringPlayer.MoneyEarned;
		PlayerHighScore.LevelWinner = ScoringPlayer.ThiefName;
		AllHighScores[LevelIndex].HighScoreTable.AddItem(PlayerHighScore);
		return AllHighScores[LevelIndex].HighScoreTable.Length - 1;
	}
	else
	{
		return -1;
	}
}


//----------------------------------------------------------------------------------------------------------
function SaveToDisk()
{
	class'Engine'.static.BasicSaveObject(self, "../../Saves/HighScores.ssg", true, self.const.SAVEGAME_REVISION, false);
}

//----------------------------------------------------------------------------------------------------------
function LoadFromDisk()
{
	local LevelHighScore CurrentLevel;
	AllHighScores.Add(NUM_LEVELS);
	foreach AllHighScores(CurrentLevel)
	{
		CurrentLevel.HighScoreTable.Add(HIGHSCORE_LENGTH);
	}
	class'Engine'.static.BasicLoadObject(self, "../../Saves/HighScores.ssg", true, self.const.SAVEGAME_REVISION);
}

//----------------------------------------------------------------------------------------------------------
function string Serialize()
{
	local string SerializedString;
	local JsonObject SerializedObject;

	SerializedObject = new class'JsonObject';
	SerializedObject.SetIntValue("Level1Score", LevelScore[0]);
	SerializedObject.SetIntValue("Level2Score", LevelScore[1]);
	SerializedObject.SetIntValue("Level3Score", LevelScore[2]);
	SerializedObject.SetIntValue("Level4Score", LevelScore[3]);

	
	SerializedString = class'JsonObject'.static.EncodeJson(SerializedObject);

	return SerializedString;
}

//----------------------------------------------------------------------------------------------------------
function Deserialize(JsonObject data)
{
	LevelScore[0] = data.GetIntValue("Level1Score");
	LevelScore[1] = data.GetIntValue("Level2Score");
	LevelScore[2] = data.GetIntValue("Level3Score");
	LevelScore[3] = data.GetIntValue("Level4Score");
}


DefaultProperties
{

	LevelScore(0)=0
	LevelScore(1)=0
	LevelScore(2)=0
	LevelScore(3)=0

	LevelWinner(0)="none"
	LevelWinner(1)="none"
	LevelWinner(2)="none"
	LevelWinner(3)="none"

}
