package net.exoad.nukleon.tools.texturemapper

import com.badlogic.gdx.tools.texturepacker.TexturePacker
import kotlin.io.path.Path
import kotlin.io.path.copyTo
import kotlin.io.path.listDirectoryEntries
import kotlin.io.path.moveTo
import kotlin.io.path.name
import kotlin.io.path.pathString
import java.io.File
import java.io.FileFilter
import java.util.*
import java.util.logging.Level
import java.util.logging.Logger

object Main
{
	const val FOLDER_RELATION:String="../../"
	const val CONTENT_FOLDER:String=FOLDER_RELATION+"content"
	const val OUTPUT_FOLDER:String=FOLDER_RELATION+"assets/images/textures"
	const val BACKGROUND_OUTPUT_FOLDER:String=FOLDER_RELATION+"assets/backgrounds"
	val logger:Logger=Logger.getLogger("net.exoad.Nukleon:TextureMapper")
	
	init
	{
		logger.setLevel(Level.ALL)
	}
	
	@JvmStatic
	fun main(args:Array<String>)
	{
		val assets=File(OUTPUT_FOLDER)
		for (f in Objects.requireNonNull<Array<File>?>(assets.listFiles(FileFilter { obj:File?-> obj!!.isFile() }))) logger.info(
			"RMF Old Atlas: "+(if (f.delete()) "OK "
			else "BAD ")+f.getName()
		)
		val settings=TexturePacker.Settings()
		settings.paddingX=0
		settings.paddingY=0
		settings.jpegQuality=1.0f
		settings.useIndexes=false
		settings.ignoreBlankImages=false
		settings.legacyOutput=true
		logger.info(File(CONTENT_FOLDER).listFiles(FileFilter { obj:File?-> obj!!.isDirectory() }).contentToString())
		for (file in Objects.requireNonNull<Array<File>?>(File(CONTENT_FOLDER).listFiles(FileFilter { file:File?-> file!!.isDirectory()&&file.getName()!="backgrounds" })))
		{
			logger.info("Found bundle: "+file.getName()+"("+file.path+") -> "+OUTPUT_FOLDER)
			TexturePacker.process(
				settings , file.path , OUTPUT_FOLDER , file.getName()
			)
		}
		logger.info("Operating Backgrounds folder!")
		for (bg in Path("$CONTENT_FOLDER/backgrounds/").listDirectoryEntries())
		{
			logger.info("Moving background: ${bg.name} -> $BACKGROUND_OUTPUT_FOLDER")
			bg.copyTo(Path("$BACKGROUND_OUTPUT_FOLDER/${bg.name}") , overwrite=true)
		}
	}
}
