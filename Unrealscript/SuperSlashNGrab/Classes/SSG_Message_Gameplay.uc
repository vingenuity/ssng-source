class SSG_Message_Gameplay extends SSG_LocalMessage;

//----------------------------------------------------------------------------------------------------------
var SoundNodeWave GameplaySounds[2];

var string LocalizationSection;

//----------------------------------------------------------------------------------------------------------
static function SoundNodeWave AnnouncementSound(int MessageIndex, PlayerController PC)
{
	return default.GameplaySounds[MessageIndex];
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
	return class'Text_Localizer'.static.GetLocalizedStringWithName(default.LocalizationSection, "announcerMessageGameplay"$switch);
}

//----------------------------------------------------------------------------------------------------------
static function color GetColor(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	local Color ConvertedColor;
	ConvertedColor.R = 255;
	ConvertedColor.G = 255;
	ConvertedColor.B = 255;
	ConvertedColor.A = 255;
	return ConvertedColor;
}


//----------------------------------------------------------------------------------------------------------
DefaultProperties
{
	GameplaySounds[0]=SoundNodeWave'MiscSounds.silence'

	LocalizationSection="SSG_Message_Gameplay"
}
