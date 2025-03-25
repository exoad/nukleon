package net.exoad.nukleon.tools

import net.exoad.nukleon.tools.sprite2d.Rect
import net.exoad.nukleon.tools.sprite2d.SkeletonTextureAtlas
import net.exoad.nukleon.tools.sprite2d.Sprite
import net.exoad.nukleon.tools.sprite2d.Transmuter
import java.awt.image.BufferedImage
import java.io.File
import javax.imageio.ImageIO

class Sprite2D
{
    companion object
    {
        fun packAtlas(
            inputFolder:String,
            atlasName:String?,
            atlasOutputLocation:String,
            textureOutputLocation:String?,
            whitespaceWeight:Int = 1,
            sideLengthWeight:Int = 20,
            regionMap:Map<String,Pair<Boolean,Set<String>>>?
        )
        {
            val input = File(inputFolder)
            assert(input.isDirectory)
            assert(input.listFiles {it.extension.equals(".png",ignoreCase = true)&&it.canRead()}!=null)
            val outAtlasName = atlasName ?: input.name
            val outTextureLoc = textureOutputLocation ?: atlasOutputLocation
            val names:MutableList<String> = mutableListOf<String>()
            val rects:MutableList<Rect> = mutableListOf<Rect>()
            val bitmaps:MutableList<BufferedImage> = mutableListOf<BufferedImage>()
            input.listFiles {it.extension.equals(".png",ignoreCase = true)&&it.canRead()}!!.forEach {
                bitmaps.add(ImageIO.read(it))
                names.add(it.nameWithoutExtension)
                rects.add(Rect(0,0,bitmaps.last().width,bitmaps.last().height))
            }
            val res = Transmuter.firstFitDecreasing(rects,false,whitespaceWeight,sideLengthWeight)
            val skeletonAtlas = SkeletonTextureAtlas()
            if(regionMap==null||regionMap.isEmpty())
            {
                val sprites:MutableList<Sprite> = mutableListOf<Sprite>()
                for(name in names) {
                    sprites.add(Sprite(name, index))
                }
            }
        }
    }
}