package net.exoad.nukleon.tools.sprite2d

import kotlin.math.max
import kotlin.math.min
import java.awt.image.BufferedImage

data class Texture(val name:String , val image:BufferedImage)
{
	fun area():Int=image.width*image.height
	fun longerSide():Int=max(image.width , image.height)
	fun shorterSide():Int=min(image.width , image.height)
}