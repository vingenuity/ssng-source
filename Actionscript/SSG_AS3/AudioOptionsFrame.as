package
{
	import flash.external.ExternalInterface;
	import flash.display.MovieClip;
	import flash.text.TextField;
    import scaleform.clik.events.ButtonEvent;
    import scaleform.clik.events.SliderEvent;
	
	public class AudioOptionsFrame extends MovieClip
	{
		public var text_title:TextField;
		
		public var text_volume_music:TextField;
		public var mc_slider_volume_music:SSG_Slider;
		
		public var text_volume_sound:TextField;
		public var mc_slider_volume_sound:SSG_Slider;
		
		public var text_volume_voice:TextField;
		public var mc_slider_volume_voice:SSG_Slider;
		
		public var button_cancel:SSG_Button;
		public var button_accept:SSG_Button;
		
		
		// Constructor
		public function AudioOptionsFrame()
		{
		}
		
		public function AttachListeners()
		{
			mc_slider_volume_music.addEventListener( SliderEvent.VALUE_CHANGE, OnMusicValueChange );
			mc_slider_volume_sound.addEventListener( SliderEvent.VALUE_CHANGE, OnSoundValueChange );
			mc_slider_volume_voice.addEventListener( SliderEvent.VALUE_CHANGE, OnVoiceValueChange );
		}
		
		public function DetachListeners()
		{
			mc_slider_volume_music.removeEventListener( SliderEvent.VALUE_CHANGE, OnMusicValueChange );
			mc_slider_volume_sound.removeEventListener( SliderEvent.VALUE_CHANGE, OnSoundValueChange );
			mc_slider_volume_voice.removeEventListener( SliderEvent.VALUE_CHANGE, OnVoiceValueChange );
		}
		
		
		// Button Presses
		public function SetCancelPressFunction( press_function:Function )
		{
			button_cancel.addEventListener( ButtonEvent.CLICK, press_function );
		}
		
		public function SetAcceptPressFunction( press_function:Function )
		{
			button_accept.addEventListener( ButtonEvent.CLICK, press_function );
		}
		
		
		// Slider Changes
		public function OnMusicValueChange( slider_event:SliderEvent )
		{
			ExternalInterface.call( "SetMusicGroupVolume", mc_slider_volume_music.value );
		}
		
		public function OnSoundValueChange( slider_event:SliderEvent )
		{
			ExternalInterface.call( "SetSoundGroupVolume", mc_slider_volume_sound.value );
			PlayUDKSound( "MenuSounds", "PlayTestSound" );
		}
		
		public function OnVoiceValueChange( slider_event:SliderEvent )
		{
			ExternalInterface.call( "SetVoiceGroupVolume", mc_slider_volume_voice.value );
			PlayUDKSound( "MenuSounds", "PlayTestVoice" );
		}
	}
}
