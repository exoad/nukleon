package net.exoad.nukleon.tools.sprite2d

import java.awt.image.BufferedImage
import kotlin.math.max
import kotlin.math.min

enum class TextureInterpolation
{
    BICUBIC,
    BILINEAR,
    NEAREST_NEIGHBOR
}

data class Texture(val image:BufferedImage)
{
    fun area():Int = image.width*image.height
    fun longerSide():Int = max(image.width,image.height)
    fun shorterSide():Int = min(image.width,image.height)
}