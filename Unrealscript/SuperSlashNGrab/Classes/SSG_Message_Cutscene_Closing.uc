class SSG_Message_Cutscene_Closing extends SSG_LocalMessage;

//----------------------------------------------------------------------------------------------------------
const NUMBER_OF_MESSAGES = 16;
var float SubtitleLengthSeconds[ NUMBER_OF_MESSAGES ];

var string LocalizationSection;

//----------------------------------------------------------------------------------------------------------
static function SoundNodeWave AnnouncementSound(int MessageIndex, PlayerController PC)
{
	return SoundNodeWave'MiscSounds.silence';
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
	return class'Text_Localizer'.static.GetLocalizedStringWithName(default.LocalizationSection, "narratorSpeech"$switch);
}

//----------------------------------------------------------------------------------------------------------
static function float GetSubtitleLengthSeconds( int MessageIndex )
{
	return default.SubtitleLengthSeconds[MessageIndex];
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
	SubtitleLengthSeconds[0]=6.3;
	SubtitleLengthSeconds[1]=3.5;
	SubtitleLengthSeconds[2]=5.0;
	SubtitleLengthSeconds[3]=6.4;
	SubtitleLengthSeconds[4]=6.2;
	SubtitleLengthSeconds[5]=5.6;
	SubtitleLengthSeconds[6]=5.4;
	SubtitleLengthSeconds[7]=3.2;
	SubtitleLengthSeconds[8]=4.0;
	SubtitleLengthSeconds[9]=6.9;
	SubtitleLengthSeconds[10]=2.4;
	SubtitleLengthSeconds[11]=5.3;
	SubtitleLengthSeconds[12]=2.9;
	SubtitleLengthSeconds[13]=6.1;
	SubtitleLengthSeconds[14]=2.9;
	SubtitleLengthSeconds[15]=2.0;

	LocalizationSection="SSG_Message_Cutscene_Closing"
}
