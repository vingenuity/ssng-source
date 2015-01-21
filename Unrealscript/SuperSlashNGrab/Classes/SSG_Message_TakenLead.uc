class SSG_Message_TakenLead extends SSG_LocalMessage;

var SoundNodeWave TakenLeadSounds[4];

var int LeadPlayerIndex;

var string LocalizationSection;

//----------------------------------------------------------------------------------------------------------
static function SoundNodeWave AnnouncementSound(int MessageIndex, PlayerController PC)
{
	return default.TakenLeadSounds[MessageIndex];
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
	return class'Text_Localizer'.static.GetLocalizedStringWithName(default.LocalizationSection, "announcerMessageTakenLead"$switch);
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

	ConvertedColor.R = class'SSG_PlayerController'.Default.PlayerColors[switch].R*255;
	ConvertedColor.G = class'SSG_PlayerController'.Default.PlayerColors[switch].G*255;
	ConvertedColor.B = class'SSG_PlayerController'.Default.PlayerColors[switch].B*255;
	ConvertedColor.A = class'SSG_PlayerController'.Default.PlayerColors[switch].A*255;
	return ConvertedColor;
}

//----------------------------------------------------------------------------------------------------------
DefaultProperties
{
	TakenLeadSounds[0]=SoundNodeWave'SSG_AnnouncerSounds.TakeTheLead.SSG_Announcer_Lead_Blue_02'
	TakenLeadSounds[1]=SoundNodeWave'SSG_AnnouncerSounds.TakeTheLead.SSG_Announcer_Lead_Pink_02'
	TakenLeadSounds[2]=SoundNodeWave'SSG_AnnouncerSounds.TakeTheLead.SSG_Announcer_Lead_Orange_02'
	TakenLeadSounds[3]=SoundNodeWave'SSG_AnnouncerSounds.TakeTheLead.SSG_Announcer_Lead_Green_02'

	LocalizationSection="SSG_Message_TakenLead"
}
