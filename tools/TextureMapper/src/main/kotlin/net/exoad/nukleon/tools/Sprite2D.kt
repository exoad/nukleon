package net.exoad.nukleon.tools

import net.exoad.nukleon.tools.sprite2d.*
import java.awt.RenderingHints
import java.awt.image.BufferedImage
import java.io.File
import java.util.logging.Level
import java.util.logging.Logger
import javax.imageio.ImageIO

class Sprite2D
{
    companion object
    {
        val logger = Logger.getLogger("Sprite2D").apply {
            this.level = Level.ALL
        }

        fun packAtlas(
            inputFolder:String,
            atlasName:String?,
            textureOutputLocation:String?,
            whitespaceWeight:Int = 1,
            sideLengthWeight:Int = 20,
            useIndex:Boolean = false,
            animated:Boolean,
            filter:TextureInterpolation = TextureInterpolation.NEAREST_NEIGHBOR
        ):TextureAtlas
        {
            val input = File(inputFolder)
            assert(input.isDirectory)
            input.listFiles {it.extension.equals("png",ignoreCase = true)}?.size?.let {assert(it>0)}
            val outAtlasName = atlasName ?: input.name
            val names:MutableList<String> = mutableListOf<String>()
            val rects:MutableList<Rect> = mutableListOf<Rect>()
            val bitmaps:MutableList<BufferedImage> = mutableListOf<BufferedImage>()
            input.listFiles {it.extension.equals("png",ignoreCase = true)&&it.canRead()}!!.forEach {
                bitmaps.add(ImageIO.read(it))
                names.add(it.nameWithoutExtension)
                rects.add(Rect(0,0,bitmaps.last().width,bitmaps.last().height))
                ("Reading ${it.nameWithoutExtension}")
                logger.fine("READ: ${it.nameWithoutExtension}")
            }
            logger.info("FILES_LEn: ${names.size}")
            val res = Transmuter.firstFitDecreasing(rects,false,whitespaceWeight,sideLengthWeight)
            val skeletonAtlas = SkeletonTextureAtlas()
            val sprites:MutableList<Sprite> = mutableListOf<Sprite>()
            var i:Int = 0
            val texture = BufferedImage(res.width,res.height,BufferedImage.TYPE_INT_ARGB)
            val g2 = texture.createGraphics()
            g2.setRenderingHint(RenderingHints.KEY_RENDERING,RenderingHints.VALUE_RENDER_QUALITY)
            g2.setRenderingHint(RenderingHints.KEY_INTERPOLATION,when(filter)
            {
                TextureInterpolation.BICUBIC->RenderingHints.VALUE_INTERPOLATION_BICUBIC
                TextureInterpolation.BILINEAR->RenderingHints.VALUE_INTERPOLATION_BILINEAR
                TextureInterpolation.NEAREST_NEIGHBOR->RenderingHints.VALUE_INTERPOLATION_NEAREST_NEIGHBOR
            }
            )
            for(name in names)
                sprites.add(Sprite(name,if(useIndex) i else -1,rects[i++]))
            for(i in 0..bitmaps.size-1)
                g2.drawImage(bitmaps[i],rects[i].x,rects[i].y,null)

            return TextureAtlas(name = outAtlasName,
                spriteList = sprites,
                animated = animated,
                textureLocation = textureOutputLocation,
                width = res.width,
                height = res.height,
                texture = Texture(image = texture)
            )
        }
    }
}