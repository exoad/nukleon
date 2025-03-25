package net.exoad.nukleon.tools.texturemapper

import com.badlogic.gdx.ApplicationListener
import com.badlogic.gdx.backends.lwjgl.LwjglApplication
import com.badlogic.gdx.backends.lwjgl.LwjglApplicationConfiguration
import com.badlogic.gdx.files.FileHandle
import com.badlogic.gdx.graphics.g2d.TextureAtlas
import com.badlogic.gdx.tools.texturepacker.TexturePacker
import java.io.File
import java.io.FileFilter
import java.util.*
import java.util.logging.Level
import java.util.logging.Logger
import kotlin.io.path.Path
import kotlin.io.path.copyTo
import kotlin.io.path.listDirectoryEntries
import kotlin.io.path.name
import kotlin.system.exitProcess


object Main
{
    const val FOLDER_RELATION:String = "../../"
    const val CONTENT_FOLDER:String = FOLDER_RELATION+"content"
    const val OUTPUT_FOLDER:String = FOLDER_RELATION+"assets/textures"
    const val BACKGROUND_OUTPUT_FOLDER:String = FOLDER_RELATION+"assets/backgrounds"
    val logger:Logger = Logger.getLogger("net.exoad.Nukleon:Sprite2DMapper")

    init
    {
        logger.setLevel(Level.ALL)
    }

    @JvmStatic
    fun oldPacker()
    {
        LwjglApplicationConfiguration.disableAudio = true
        val config = LwjglApplicationConfiguration().apply {
            width = 800
            height = 600
            title = "Amogus"
            allowSoftwareMode = true
        }
        LwjglApplication(object:ApplicationListener
        {
            override fun create()
            {
            }

            override fun resize(width:Int,height:Int)
            {
            }

            override fun render()
            {
            }

            override fun pause()
            {
            }

            override fun resume()
            {
            }

            override fun dispose()
            {
            }
        },config)
        val assets = File(OUTPUT_FOLDER)
        for(f in Objects.requireNonNull<Array<File>?>(assets.listFiles(FileFilter {obj:File?-> obj!!.isFile()}))) logger.info(
            "RMF Old Atlas: "+(if(f.delete()) "OK "
            else "BAD ")+f.getName()
        )
        val settings = TexturePacker.Settings()
        settings.paddingX = 0
        settings.paddingY = 0
        settings.jpegQuality = 1.0f
        settings.useIndexes = false
        settings.ignoreBlankImages = false
        settings.legacyOutput = true
        logger.info(File(CONTENT_FOLDER).listFiles(FileFilter {obj:File?-> obj!!.isDirectory()}).contentToString())
        for(file in Objects.requireNonNull<Array<File>?>(File(CONTENT_FOLDER).listFiles(FileFilter {file:File?-> file!!.isDirectory()&&file.getName()!="backgrounds"})))
        {
            logger.info("Found bundle: "+file.getName()+"("+file.path+") -> "+OUTPUT_FOLDER)
            TexturePacker.process(
                settings,file.path,OUTPUT_FOLDER,file.getName()
            )            // ik this is hella stupid just to get it into a better xml format
            val atlas = TextureAtlas(FileHandle("$OUTPUT_FOLDER/${file.nameWithoutExtension}.atlas"))
            if(atlas.regions.size>1)
            {
                logger.severe("Cannot proceed with atlas ${file.getName()} more than 1 region!")
                exitProcess(-1)
            }
            for(region in atlas.regions)
            {
                logger.finest("Got ${region.name}")
            }
        }
        logger.info("Operating Backgrounds folder!")
        for(bg in Path("$CONTENT_FOLDER/backgrounds/").listDirectoryEntries())
        {
            logger.info("Moving background: $bg -> $BACKGROUND_OUTPUT_FOLDER/${bg.name}")
            bg.copyTo(Path("$BACKGROUND_OUTPUT_FOLDER/${bg.name}"),overwrite = true)
        }
    }

    @JvmStatic
    fun main(args:Array<String>)
    {

    }
}
