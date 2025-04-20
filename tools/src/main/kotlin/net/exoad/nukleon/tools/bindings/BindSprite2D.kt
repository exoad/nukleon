package net.exoad.nukleon.tools.bindings

import net.exoad.nukleon.tools.Sprite2D
import java.io.File
import java.util.logging.Level
import java.util.logging.Logger

object BindSprite2D:Bindings
{
	internal val logger:Logger=
		Logger.getLogger("net.exoad.nukleon.tools.bindings.Sprite2D").apply {
			this.level=Level.ALL
		}
	
	override fun bind(args:Array<String>)
	{
		assert(args.isEmpty())
		for(assetDir:File in File(
			"../content/"
		).listFiles {file-> file.isDirectory}!!.toSet())
		{
			logger.fine("Found ${assetDir.absolutePath}, peeking inside...")
			val files=assetDir.listFiles {file->
				file.isFile&&file.canRead()&&file.extension.contentEquals(
					"png",true
				)
			}
			if(files!=null&&files.isNotEmpty())
			{
				logger.warning(
					"Found ${files.size} potential asset${if(files.size>1) "s" else ""} to pack, proceeding..."
				)
				Sprite2D.packAtlas(
					assetDir.absolutePath,assetDir.name,animated=false
				)
			}
			else logger.warning(
				"Found no potential assets to pack for ${assetDir.absolutePath}"
			)
		}
	}
}