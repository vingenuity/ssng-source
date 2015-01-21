class SSG_Message_KilledPlayer extends SSG_LocalMessage;

//----------------------------------------------------------------------------------------------------------
var SoundNodeWave KilledPlayerSounds[16];

var string LocalizationSection;

//----------------------------------------------------------------------------------------------------------
static function SoundNodeWave AnnouncementSound(int MessageIndex, PlayerController PC)
{
	return default.KilledPlayerSounds[MessageIndex];
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
	return class'Text_Localizer'.static.GetLocalizedStringWithName(default.LocalizationSection, "announcerMessageKilledPlayer"$switch);
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

	ConvertedColor.R = class'SSG_PlayerController'.Default.PlayerColors[switch/4].R*255;
	ConvertedColor.G = class'SSG_PlayerController'.Default.PlayerColors[switch/4].G*255;
	ConvertedColor.B = class'SSG_PlayerController'.Default.PlayerColors[switch/4].B*255;
	ConvertedColor.A = class'SSG_PlayerController'.Default.PlayerColors[switch/4].A*255;
	return ConvertedColor;
}


//----------------------------------------------------------------------------------------------------------
DefaultProperties
{
	KilledPlayerSounds[0]=SoundNodeWave'MiscSounds.silence'
	KilledPlayerSounds[1]=SoundNodeWave'SSG_AnnouncerSounds.Betrayal.SSG_Betrayal_02'
	KilledPlayerSounds[2]=SoundNodeWave'SSG_AnnouncerSounds.Betrayal.SSG_Betrayal_02'
	KilledPlayerSounds[3]=SoundNodeWave'SSG_AnnouncerSounds.Betrayal.SSG_Betrayal_02'
	KilledPlayerSounds[4]=SoundNodeWave'SSG_AnnouncerSounds.Betrayal.SSG_Betrayal_02'
	KilledPlayerSounds[5]=SoundNodeWave'MiscSounds.silence'
	KilledPlayerSounds[6]=SoundNodeWave'SSG_AnnouncerSounds.Betrayal.SSG_Betrayal_02'
	KilledPlayerSounds[7]=SoundNodeWave'SSG_AnnouncerSounds.Betrayal.SSG_Betrayal_02'
	KilledPlayerSounds[8]=SoundNodeWave'SSG_AnnouncerSounds.Betrayal.SSG_Betrayal_02'
	KilledPlayerSounds[9]=SoundNodeWave'SSG_AnnouncerSounds.Betrayal.SSG_Betrayal_02'
	KilledPlayerSounds[10]=SoundNodeWave'MiscSounds.silence'
	KilledPlayerSounds[11]=SoundNodeWave'SSG_AnnouncerSounds.Betrayal.SSG_Betrayal_02'
	KilledPlayerSounds[12]=SoundNodeWave'SSG_AnnouncerSounds.Betrayal.SSG_Betrayal_02'
	KilledPlayerSounds[13]=SoundNodeWave'SSG_AnnouncerSounds.Betrayal.SSG_Betrayal_02'
	KilledPlayerSounds[14]=SoundNodeWave'SSG_AnnouncerSounds.Betrayal.SSG_Betrayal_02'
	KilledPlayerSounds[15]=SoundNodeWave'MiscSounds.silence'

	LocalizationSection="SSG_Message_KilledPlayer"
}
