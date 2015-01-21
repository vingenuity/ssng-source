package
{
	import flash.display.MovieClip;
	import flash.geom.ColorTransform;
	
	public class PlaceIndicator extends MovieClip
	{
		var background_color:ColorTransform;
		
		
		//Constructor
		public function PlaceIndicator()
		{
			background_color = new ColorTransform();
			background_color.color = 0xffffff;
			
			SetBackgroundColor( 255, 255, 255 );
			SetPlace( 1 );
		}
		
		
		//---------------------------------------------------------------------------------------------------
		public function SetBackgroundColor( red:Number = 255, green:Number = 255, blue:Number = 255 )
		{
			background_color.redOffset = red;
			background_color.greenOffset = green;
			background_color.blueOffset = blue;
			background_color.alphaOffset = -128;
			
			//mc_image_background.transform.colorTransform = background_color;
		}
		
		//---------------------------------------------------------------------------------------------------
		public function SetPlace( place:uint )
		{
			switch( place )
			{
				case 1:
					gotoAndStop( "First" );
					break;
				case 2:
					gotoAndStop( "Second" );
					break;
				case 3:
					gotoAndStop( "Third" );
					break;
				case 4:
				default:
					gotoAndStop( "Fourth" );
					break;
			}
		}
	}
	
}
