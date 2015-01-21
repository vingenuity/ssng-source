package
{
	import flash.display.MovieClip;
	import flash.external.ExternalInterface;
	import flash.text.TextField;
	import fl.transitions.easing.*;
	import fl.transitions.Tween;
	
	public class LevelDetailPopup extends MovieClip
	{
		public var text_level_number:TextField;
		public var text_high_score:TextField;
		public var text_high_scorer_name:TextField;
		public var text_high_scorer_amount:TextField;
		
		private static const fade_tween_length_seconds:Number = 0.75;
		private const fade_in_tween:Tween = new Tween( this, "alpha", Regular.easeOut, 0, 1, fade_tween_length_seconds, true );
		private var fade_out_tween:Tween;
		private var level_id:uint;
		
		
		// Constructor
		public function LevelDetailPopup( level_ID:uint, posX:Number, posY:Number )
		{
			level_id = level_ID;
			alpha = 0;
			x = posX;
			y = posY;
			scaleX = 0.6;
			scaleY = 0.6;
		}
		
		
		
		//Tweens
		public function FadeIn()
		{
			ExternalInterface.call( "LocalizeAndPopulateLevelDetailPopup", level_id );
			fade_in_tween.start();
		}
		
		public function FadeOut()
		{
			//not sure why I have to do this instead of another private const...
			//if it's not done this way, both tweens end up being the same.
			fade_out_tween = new Tween( this, "alpha", Regular.easeOut, 1, 0, fade_tween_length_seconds, true );
			fade_out_tween.start();
		}
	}
}
