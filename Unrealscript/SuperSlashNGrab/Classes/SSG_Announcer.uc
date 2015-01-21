/*Derived from UTAnnouncer*/
class SSG_Announcer extends Info
	config(Game);


var globalconfig byte AnnouncerLevel;				// 0=none, 1=no possession announcements, 2=all

/** class of currently playing announcement */
var class<LocalMessage> PlayingAnnouncementClass;

var int PlayingAnnouncementIndex;

/** Queued announcer messages */
var SSG_QueuedMessage Queue;

var SSG_PlayerController PlayerOwner;

/** the sound cue used for announcer sounds. We then use a wave parameter named Announcement to insert the actual sound we want to play.
 * (this allows us to avoid having to change a whole lot of cues together if we want to change SoundCue options for the announcements)
 */
var SoundCue AnnouncerSoundCue;

/** the sound cue used for all UTVoice sounds. We then use a wave parameter named Announcement to insert the actual sound we want to play.
 * (this allows us to avoid having to change a whole lot of cues together if we want to change SoundCue options for the announcements)
 */
var SoundCue UTVoiceSoundCue;

/** currently playing AudioComponent */
var AudioComponent CurrentAnnouncementComponent;

function Destroyed()
{
	local SSG_QueuedMessage A;

	Super.Destroyed();

	if (CurrentAnnouncementComponent != none)
	{
		if (PlayerOwner != none)
		{
			PlayerOwner.DetachComponent(CurrentAnnouncementComponent);
		}
		CurrentAnnouncementComponent = none;
	}

	for ( A=Queue; A!=None; A=A.nextAnnouncement )
		A.Destroy();
}

function PostBeginPlay()
{
	Super.PostBeginPlay();

	PlayerOwner = SSG_PlayerController(Owner);
}

function PlayNextAnnouncement()
{
	local SSG_QueuedMessage PlayedAnnouncement;

	PlayingAnnouncementClass = None;

	if ( Queue != None )
	{
		PlayedAnnouncement = Queue;
		Queue = PlayedAnnouncement.nextAnnouncement;
		PlayAnnouncementNow(PlayedAnnouncement.AnnouncementClass, PlayedAnnouncement.MessageIndex);
		PlayingAnnouncementClass = PlayedAnnouncement.AnnouncementClass;
		PlayingAnnouncementIndex = PlayedAnnouncement.MessageIndex;
		PlayedAnnouncement.Destroy();
	}
}

function PlayAnnouncementNow(class<SSG_LocalMessage> InMessageClass, int MessageIndex)
{
	local SoundNodeWave ASound;
	local bool bUsingVoiceCue;

	ASound = InMessageClass.Static.AnnouncementSound(MessageIndex, PlayerOwner);

	if ( ASound != None )
	{
		if (CurrentAnnouncementComponent != none)
		{
			if (PlayerOwner != none)
			{
				PlayerOwner.DetachComponent(CurrentAnnouncementComponent);
			}
			CurrentAnnouncementComponent = none;
		}


		CurrentAnnouncementComponent = PlayerOwner.CreateAudioComponent(AnnouncerSoundCue, false, false);
		bUsingVoiceCue = FALSE;
		

		// CurrentAnnouncementComponent will be none if -nosound option used
		if ( CurrentAnnouncementComponent != None )
		{
			CurrentAnnouncementComponent.SetWaveParameter('Announcement', ASound);
			if( bUsingVoiceCue )
			{
				UTVoiceSoundCue.Duration = ASound.Duration;
				UTVoiceSoundCue.VolumeMultiplier = InMessageClass.Default.AnnouncementVolume;
			}
			else
			{
				AnnouncerSoundCue.Duration = ASound.Duration;
				AnnouncerSoundCue.VolumeMultiplier = InMessageClass.Default.AnnouncementVolume;
			}
			CurrentAnnouncementComponent.bAutoDestroy = true;
			CurrentAnnouncementComponent.bShouldRemainActiveIfDropped = true;
			CurrentAnnouncementComponent.bAllowSpatialization = false;
			CurrentAnnouncementComponent.bAlwaysPlay = TRUE;
			CurrentAnnouncementComponent.Play();
		}
		PlayingAnnouncementClass = InMessageClass;
		PlayingAnnouncementIndex = MessageIndex;

		// NOTE: Audio always plays back in real-time, so we'll scale our duration by the world's time dilation
		SetTimer(ASound.Duration * WorldInfo.TimeDilation + 0.05, false,'AnnouncementFinished');
	}
	else
	{
		//`log("NO SOUND FOR "$InMessageClass@MessageIndex@OptionalObject@OptionalObject.name);
		PlayNextAnnouncement();
	}
}

function AnnouncementFinished(AudioComponent AC)
{
	if ((PlayerOwner != none) && (CurrentAnnouncementComponent != none))
	{
		PlayerOwner.DetachComponent(CurrentAnnouncementComponent);
	}
	CurrentAnnouncementComponent = None;
	PlayingAnnouncementClass = None;
	PlayNextAnnouncement();
}

function PlayAnnouncement(class<SSG_LocalMessage> InMessageClass, int MessageIndex)
{
	if ( InMessageClass.Static.AnnouncementLevel(MessageIndex) > AnnouncerLevel )
	{
		return;
	}

	if ( (CurrentAnnouncementComponent == None) || CurrentAnnouncementComponent.bFinished )
	{
		PlayingAnnouncementClass = None;
		CurrentAnnouncementComponent = None;
	}

	if ( PlayingAnnouncementClass == None )
	{
		if ( (InMessageClass.default.AnnouncementDelay == 0.0) /*|| ((PRI != None) && !PRI.bBot)*/ )
		{
			// play immediately
			PlayAnnouncementNow(InMessageClass, MessageIndex);
			return;
		}
		else
		{
			// NOTE: Audio always plays back in real-time, so we'll scale our delay by the world's time dilation
			SetTimer(InMessageClass.default.AnnouncementDelay * WorldInfo.TimeDilation, false,'AnnouncementFinished');
		}
	}

	if ( InMessageClass.static.AddAnnouncement(self, MessageIndex))
	{
		if ( CurrentAnnouncementComponent != None )
		{
			CurrentAnnouncementComponent.Stop();
			if (PlayerOwner != none)
			{
				PlayerOwner.DetachComponent(CurrentAnnouncementComponent);
			}
			CurrentAnnouncementComponent = None;
		}
		PlayNextAnnouncement();
	}
}

defaultproperties
{
	AnnouncerSoundCue=SoundCue'SSG_AnnouncerSounds.SSG_Announcer_Cue'
}
