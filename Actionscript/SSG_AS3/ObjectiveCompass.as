package
{
	import flash.display.MovieClip;
	import flash.geom.ColorTransform;
	
	public class ObjectiveCompass extends MovieClip
	{
		var arrow_background_color:ColorTransform;
		var arrow_outline_color:ColorTransform;
		
		
		public function ObjectiveCompass()
		{
			arrow_background_color = new ColorTransform();
			arrow_background_color.color = 0xffffff;
			
			arrow_outline_color = new ColorTransform();
			arrow_outline_color.color = 0xffffff;
			
			SetArrowBackgroundColor( 213, 173, 49 );
			SetArrowOutlineColor( 246, 224, 148 );
		}
		
		
		
		//---------------------------------------------------------------------------------------------------
		public function HideArrow()
		{
			mc_compass_arrow.visible = false;
		}
		
		//---------------------------------------------------------------------------------------------------
		public function ShowArrow()
		{
			mc_compass_arrow.visible = true;
		}
		
		//---------------------------------------------------------------------------------------------------
		public function SetArrowBackgroundColor( red:Number = 255, green:Number = 255, blue:Number = 255 )
		{
			arrow_background_color.redOffset = red;
			arrow_background_color.greenOffset = green;
			arrow_background_color.blueOffset = blue;
			
			mc_compass_arrow.mc_arrow_back.transform.colorTransform = arrow_background_color;
		}
		
		//---------------------------------------------------------------------------------------------------
		public function SetArrowOutlineColor( red:Number = 255, green:Number = 255, blue:Number = 255 )
		{
			arrow_outline_color.redOffset = red;
			arrow_outline_color.greenOffset = green;
			arrow_outline_color.blueOffset = blue;
			
			mc_compass_arrow.mc_arrow_outline.transform.colorTransform = arrow_outline_color;
		}
		
		//---------------------------------------------------------------------------------------------------
		public function SetArrowRotation( rotation_degrees:Number )
		{
			mc_compass_arrow.rotation = -rotation_degrees;
		}
	}
}
