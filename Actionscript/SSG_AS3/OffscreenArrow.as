package
{
	import flash.display.MovieClip;
	import flash.geom.ColorTransform;
	
	public class OffscreenArrow extends MovieClip
	{
		var background_color:ColorTransform;
		var outline_color:ColorTransform;
		var text_color:ColorTransform;
		
		//Constructor
		public function OffscreenArrow()
		{
			background_color = new ColorTransform();
			background_color.color = 0xffffff;
			
			outline_color = new ColorTransform();
			outline_color.color = 0xffffff;
			
			text_color = new ColorTransform();
			text_color.color = 0xffffff;
			
			SetOffscreenMode();
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
		public function SetTextColor( red:Number = 255, green:Number = 255, blue:Number = 255 )
		{
			text_color.redOffset = red;
			text_color.greenOffset = green;
			text_color.blueOffset = blue;
			
			mc_text_frame.mc_time_text.transform.colorTransform = text_color;
		}
		//---------------------------------------------------------------------------------------------------
		public function SetOffscreenMode()
		{
			mc_a_button.visible = false;
			mc_text_frame.visible = true;
		}
		
		//---------------------------------------------------------------------------------------------------
		public function SetRespawnMode()
		{
			mc_a_button.visible = true;
			mc_text_frame.visible = false;
		}
		
		//---------------------------------------------------------------------------------------------------
		public function SetRotation( rotation_degrees:Number )
		{
			this.mc_text_frame.rotation = -rotation_degrees;
			this.mc_a_button.rotation = -rotation_degrees;
			this.rotation = rotation_degrees;
		}
		
		//---------------------------------------------------------------------------------------------------
		public function SetText( newText:String )
		{
			mc_text_frame.mc_time_text.text = newText;
		}
	}
}
