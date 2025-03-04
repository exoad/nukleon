package net.exoad.nukleon.tools.texturemapper;

import com.badlogic.gdx.tools.texturepacker.TexturePacker;

import java.io.File;
import java.util.Arrays;
import java.util.Objects;
import java.util.logging.Level;
import java.util.logging.Logger;

import static com.badlogic.gdx.tools.texturepacker.TexturePacker.Settings;
public class Main
{
	public static final String FOLDER_RELATION="../../";
	public static final String CONTENT_FOLDER=FOLDER_RELATION+"content";
	public static final String OUTPUT_FOLDER=FOLDER_RELATION+"assets/images/textures";

	static final Logger logger=Logger.getLogger("net.exoad.Nukleon:TextureMapper");

	static
	{
		logger.setLevel(Level.ALL);
	}

	public static void main(String... args)
	{
		File assets=new File(OUTPUT_FOLDER);
		for(File f : Objects.requireNonNull(assets.listFiles(File::isFile)))
			logger.info("RMF Old Atlas: "+(f.delete()
			                               ? "OK "
			                               : "BAD ")+f.getName());
		Settings settings=new Settings();
		settings.paddingX=0;
		settings.paddingY=0;
		settings.jpegQuality=1.0F;
		settings.useIndexes=false;
		settings.ignoreBlankImages=false;
		settings.legacyOutput=true;
		logger.info(Arrays.toString(new File(CONTENT_FOLDER).listFiles(File::isDirectory)));
		for(File file : Objects.requireNonNull(new File(CONTENT_FOLDER).listFiles(File::isDirectory)))
		{
			logger.info("Found bundle: "+file.getName());
			TexturePacker.process(settings,file.getPath(),OUTPUT_FOLDER,file.getName());
		}
	}
}
