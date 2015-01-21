package
{
	import fl.transitions.easing.*;
	import fl.transitions.Tween;
	import fl.transitions.TweenEvent;
	import flash.display.MovieClip;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.utils.Timer;
	
	
	public class SubtitleClip extends MovieClip
	{
		const FADE_LENGTH_SECONDS = 0.3;
		
		private var fade_in_tween:Tween;
		private var fade_out_tween:Tween;
		private var shown_timer:Timer;
		
		public var text_subtitle:TextField;
		
		
		// Constructor
		public function SubtitleClip()
		{
		}
		
		
		// Actions
		public function Show( subtitle_text:String, seconds_to_show:Number )
		{
			text_subtitle.text = subtitle_text;
			//Before this function is called, text_subtitle.text and seconds_to_show should be set by outsiders.
			fade_in_tween = new Tween( this, "alpha", Regular.easeOut, 0.0, 1.0, FADE_LENGTH_SECONDS, true );
			
			shown_timer = new Timer( seconds_to_show * 1000.0, 1 );
			shown_timer.addEventListener( TimerEvent.TIMER_COMPLETE, this.HideEvent );
			shown_timer.start();
		}
		
		public function Hide()
		{
			HideEvent( null );
		}
		
		private function HideEvent( timer_event:TimerEvent )
		{
			if( this.alpha < 0.75 ) //Check to prevent double fading
				return;
			
			fade_out_tween = new Tween( this, "alpha", Regular.easeOut, 1.0, 0.0, FADE_LENGTH_SECONDS, true );
			//fade_out_tween.addEventListener( TweenEvent.MOTION_FINISH, Clear );
		}
		
		public function Clear()
		{
			text_subtitle.text = "";
		}
	}
}
