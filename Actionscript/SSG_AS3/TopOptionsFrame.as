package
{
	import flash.display.MovieClip;
	import flash.text.TextField;
    import scaleform.clik.events.ButtonEvent;
	
	public class TopOptionsFrame extends MovieClip
	{
		public var text_title:TextField;
		
		public var button_options_video:SSG_Button;
		public var button_options_audio:SSG_Button;
		public var button_options_gameplay:SSG_Button;
		public var button_back_main_menu:SSG_Button;
		
		
		// Constructor
		public function TopOptionsFrame()
		{
		}
		
		
		// Button Presses
		public function SetVideoOptionsPressFunction( press_function:Function )
		{
			button_options_video.addEventListener( ButtonEvent.CLICK, press_function );
		}
		
		public function SetAudioOptionsPressFunction( press_function:Function )
		{
			button_options_audio.addEventListener( ButtonEvent.CLICK, press_function );
		}
		
		public function SetGameplayOptionsPressFunction( press_function:Function )
		{
			button_options_gameplay.addEventListener( ButtonEvent.CLICK, press_function );
		}
		
		public function SetMainMenuPressFunction( press_function:Function )
		{
			button_back_main_menu.addEventListener( ButtonEvent.CLICK, press_function );
		}
	}
}
