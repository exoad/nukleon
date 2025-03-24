package net.exoad.nukleon.tools.texturemapper

import java.awt.image.BufferedImage

class Utils
{
	data class FreeRect(val x:Float , val y:Float , val width:Float , val height:Float)
	{
		fun area():Float=width*height
	}
	
	data class Atlas(val name:String , val width:Int , val height:Int , val textures:List<BufferedImage> , val rects:List<FreeRect>)
}

fun BufferedImage.area()=width*height