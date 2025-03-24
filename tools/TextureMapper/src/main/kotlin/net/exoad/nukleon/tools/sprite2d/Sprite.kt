package net.exoad.nukleon.tools.sprite2d

data class Rect(val x:Int , val y:Int , val width:Int , val height:Int)
{
	fun area():Int=width*height
}

data class Sprite(val name:String , val src:Rect , val index:Int=-1)
