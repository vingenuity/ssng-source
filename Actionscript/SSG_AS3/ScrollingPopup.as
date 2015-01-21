package
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.ColorTransform;

	//---------------------------------------------------------------------------------------------------
	public class ScrollingPopup extends MovieClip
	{
		public static const TYPE_TIMER:int = 0;
		public static const TYPE_TREASURE:int = 1;
		public static const TYPE_HEALTH:int = 2;
		public static const TYPE_CROSSBOW:int = 3;
		public static const TYPE_SHIELD:int = 4;
		public static const TYPE_MEDAL:int = 5;
		
		private static const ALPHA_LOST_PER_FRAME:int = 5;
		private static const SCROLL_SPEED_PIXELS_PER_FRAME:int = 3;
		private static const IMAGE_WIDTH_AND_HEIGHT:Number = 80.0;
		
		var mc_popup_image:MovieClip;
		var image_color:ColorTransform;
		var text_color:ColorTransform;
		
		var birth_time:int;
		var lifetime_seconds:int;
		
		//---------------------------------------------------------------------------------------------------
		public function ScrollingPopup( popup_type:int, spawn_time:int, lifetime_secs:int = 3 )
		{
			image_color = new ColorTransform();
			text_color = new ColorTransform();
			text_color.color = 0xffffff;
			
			birth_time = spawn_time;
			lifetime_seconds = lifetime_secs;
			
			this.addEventListener( Event.ENTER_FRAME, this.FadeOut );
			this.addEventListener( Event.ENTER_FRAME, this.ScrollUpwards );
			
			AddImageFromPopupType( popup_type );
		}
		
		
		
		//Construction Assistant
		//---------------------------------------------------------------------------------------------------
		private function AddImageFromPopupType( popup_type:int )
		{
			switch( popup_type )
			{
				case TYPE_TIMER:
					mc_popup_image = new TimerMC;
					break; 
				case TYPE_TREASURE:
					mc_popup_image = new TreasureMC;
					break;
				case TYPE_HEALTH:
					mc_popup_image = new HeartMC;
					break;
				case TYPE_CROSSBOW:
					mc_popup_image = new CrossbowMC;
				break;
				case TYPE_SHIELD:
					mc_popup_image = new ShieldMC;
					break;
				case TYPE_MEDAL:
					mc_popup_image = new MedalMC;
					break;
				default:
					break;
			}
			addChild( mc_popup_image );
			mc_popup_image.x = -( IMAGE_WIDTH_AND_HEIGHT / 2 );
			mc_popup_image.y = 0.0;
			mc_popup_image.width = IMAGE_WIDTH_AND_HEIGHT;
			mc_popup_image.height = IMAGE_WIDTH_AND_HEIGHT;
		}
		
		
		
		//Setters
		//---------------------------------------------------------------------------------------------------
		public function SetText( text:String )
		{
			mc_popup_text.text = text;
		}
		
		//---------------------------------------------------------------------------------------------------
		public function SetTextColor( red:Number = 255, green:Number = 255, blue:Number = 255 )
		{
			text_color.redOffset = red;
			text_color.greenOffset = green;
			text_color.blueOffset = blue;
			
		    mc_popup_text.transform.colorTransform = text_color;
		}
		
		
		
		//Timer Functions
		//---------------------------------------------------------------------------------------------------
		private function FadeOut( e:Event )
		{
			image_color.alphaOffset -= ALPHA_LOST_PER_FRAME;
		    mc_popup_image.transform.colorTransform = image_color;
			text_color.alphaOffset -= ALPHA_LOST_PER_FRAME;
		    mc_popup_text.transform.colorTransform = text_color;
		}
		
		//---------------------------------------------------------------------------------------------------
		private function ScrollUpwards( e:Event )
		{
			this.y -= SCROLL_SPEED_PIXELS_PER_FRAME;
		}
	}
}
