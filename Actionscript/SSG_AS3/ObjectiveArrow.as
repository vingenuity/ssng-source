package
{
	import flash.display.MovieClip;
	import flash.geom.ColorTransform;
	
	public class ObjectiveArrow extends MovieClip
	{
		var background_color:ColorTransform;
		var outline_color:ColorTransform;
		
		//Constructor
		public function ObjectiveArrow()
		{
			background_color = new ColorTransform();
			background_color.color = 0xffffff;
			
			outline_color = new ColorTransform();
			outline_color.color = 0xffffff;
			
			SetBackgroundColor( 213, 173, 49 );
			SetOutlineColor( 246, 224, 148 );
		}
		
		
		
		//---------------------------------------------------------------------------------------------------
		public function SetBackgroundColor( red:Number = 255, green:Number = 255, blue:Number = 255 )
		{
			background_color.redOffset = red;
			background_color.greenOffset = green;
			background_color.blueOffset = blue;
			
			mc_image_arrow_back.transform.colorTransform = background_color;
		}
		
		//---------------------------------------------------------------------------------------------------
		public function SetOutlineColor( red:Number = 255, green:Number = 255, blue:Number = 255 )
		{
			outline_color.redOffset = red;
			outline_color.greenOffset = green;
			outline_color.blueOffset = blue;
			
			mc_image_arrow_outline.transform.colorTransform = outline_color;
		}
		
		//---------------------------------------------------------------------------------------------------
		public function SetRotation( rotation_degrees:Number )
		{
			this.mc_image_objective.rotation = -rotation_degrees;
			this.rotation = rotation_degrees;
		}
	}
}
