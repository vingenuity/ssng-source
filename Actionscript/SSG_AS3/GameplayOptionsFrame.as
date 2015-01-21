package
{
	import flash.display.MovieClip;
	import flash.text.TextField;
    import scaleform.clik.events.ButtonEvent;
    import scaleform.clik.events.SliderEvent;
	
	public class GameplayOptionsFrame extends MovieClip
	{
		public var text_title:TextField;
		
		public var text_language:TextField;
		public var mc_language_stepper:SSG_OptionStepper;
		
		public var text_rumble:TextField;
		public var mc_checkbox_rumble:SSG_CheckBox;
		
		public var button_cancel:SSG_Button;
		public var button_accept:SSG_Button;
		
		// Constructor
		public function GameplayOptionsFrame()
		{
			//mc_slider_gore_level.addEventListener( SliderEvent.VALUE_CHANGE, SetSliderBackToMaximum );
		}
		
		
		// Slider Event Handler
		public function SetSliderBackToMaximum( slider_event:SliderEvent )
		{
			//if( mc_slider_gore_level.value != 100 )
				//mc_slider_gore_level.value = 100;
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
