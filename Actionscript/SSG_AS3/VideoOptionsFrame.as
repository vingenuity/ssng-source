package
{
	import flash.display.MovieClip;
	import flash.text.TextField;
    import scaleform.clik.events.ButtonEvent;
	
	public class VideoOptionsFrame extends MovieClip
	{
		public var text_title:TextField;
		
		public var text_resolution:TextField;
		public var mc_resolution_stepper:SSG_OptionStepper;
		
		public var text_graphics_level:TextField;
		public var mc_graphics_level_stepper:SSG_OptionStepper;
		
		public var text_fullscreen:TextField;
		public var mc_checkbox_fullscreen:SSG_CheckBox;
		
		public var text_gamma:TextField;
		public var mc_slider_gamma:SSG_Slider;
		
		public var button_cancel:SSG_Button;
		public var button_accept:SSG_Button;
		
		
		// Constructor
		public function VideoOptionsFrame()
		{
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
	}
}
