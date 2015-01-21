package
{
	import flash.display.MovieClip;
	import fl.transitions.easing.*;
	import fl.transitions.Tween;
	import fl.transitions.TweenEvent;
	
	
	public class DirectionalArrow extends MovieClip
	{
		var alphaDownTween:Tween;
		var alphaUpTween:Tween;
		var alphaIncreasing:Boolean;
		var loopsRemaining:uint;
		
		// Constructor
		public function DirectionalArrow()
		{
			alphaDownTween = new Tween( mc_big_arrow, "alpha", None.easeNone, 1, 0, 0.5, true );
			alphaDownTween.addEventListener( TweenEvent.MOTION_FINISH, LoopAnimationWhileLoopsRemaining );
			alphaDownTween.stop();
			
			alphaUpTween = new Tween( mc_big_arrow, "alpha", None.easeNone, 0, 1, 0.5, true );
			alphaUpTween.addEventListener( TweenEvent.MOTION_FINISH, LoopAnimationWhileLoopsRemaining );
			alphaUpTween.stop();
		}
		
		
		
		//Usage functions (For Unreal)
		public function Hide()
		{
			mc_big_arrow.alpha = 0;
		}
		
		public function Play( orientation_degrees:Number )
		{
			mc_big_arrow.rotation = orientation_degrees;
			loopsRemaining = 4;
			alphaUpTween.start();
		}
		
		public function Show( orientation_degrees:Number )
		{
			mc_big_arrow.rotation = orientation_degrees;
			mc_big_arrow.alpha = 1;
		}
		
		
		
		//Animation controlling function
		private function LoopAnimationWhileLoopsRemaining( tween_event:TweenEvent )
		{
			if( tween_event.type != TweenEvent.MOTION_FINISH )
				return;
			
			if( tween_event.target == alphaUpTween )
			{
				alphaDownTween.start();
			}
			else if( loopsRemaining > 0 )
			{
				--loopsRemaining;
				alphaUpTween.start();
			}
			//Use this to loop the animation for display purposes
//			else
//				PlayDirectionIndicator( mc_big_arrow.rotation + 45 );
		}
	}
}
