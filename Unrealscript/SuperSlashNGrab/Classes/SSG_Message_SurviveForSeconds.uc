class SSG_Message_SurviveForSeconds extends SSG_LocalMessage;

enum SECONDS_TO_INDEX
{
	EMSS_10, EMSS_30
}; //@TODO associate this enum with the number of seconds for survival at each level/event

var array<SoundNodeWave> SurviveSecondsSound;

var string LocalizationSection;

//----------------------------------------------------------------------------------------------------------
static function SoundNodeWave AnnouncementSound(int MessageIndex, PlayerController PC)
{
	return default.SurviveSecondsSound[MessageIndex];
}


//----------------------------------------------------------------------------------------------------------
static function string GetString(
	optional int Switch,
	optional bool bPRI1HUD,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	return class'Text_Localizer'.static.GetLocalizedStringWithName(default.LocalizationSection, "announcerMessageSurviveSeconds"$switch);
}

DefaultProperties
{
	SurviveSecondsSound(0)=SoundNodeWave'MiscSounds.silence'; 

	LocalizationSection="SSG_Message_SurviveSeconds"
}
