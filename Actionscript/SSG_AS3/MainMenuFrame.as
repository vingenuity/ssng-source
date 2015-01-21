package
{
	import flash.display.MovieClip;
	import flash.text.TextField;
    import scaleform.clik.events.ButtonEvent;
	
	public class MainMenuFrame extends MovieClip
	{
		public var text_title:TextField;
		
		public var button_play_game:SSG_Button;
		public var button_options:SSG_Button;
		public var button_credits:SSG_Button;
		public var button_quit:SSG_Button;
		
		
		// Constructor
		public function MainMenuFrame()
		{
		}
		
		
		// Button Presses
		public function SetPlayGamePressFunction( press_function:Function )
		{
			button_play_game.addEventListener( ButtonEvent.CLICK, press_function );
		}
		
		public function SetOptionsPressFunction( press_function:Function )
		{
			button_options.addEventListener( ButtonEvent.CLICK, press_function );
		}
		
		public function SetCreditsPressFunction( press_function:Function )
		{
			button_credits.addEventListener( ButtonEvent.CLICK, press_function );
		}
		
		public function SetQuitPressFunction( press_function:Function )
		{
			button_quit.addEventListener( ButtonEvent.CLICK, press_function );
		}
	}
}
