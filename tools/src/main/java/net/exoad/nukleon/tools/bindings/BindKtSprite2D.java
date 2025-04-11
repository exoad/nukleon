package net.exoad.nukleon.tools.bindings;

import org.jetbrains.annotations.NotNull;

import java.io.File;
import java.util.Objects;
import java.util.logging.ConsoleHandler;
import java.util.logging.Level;
import java.util.logging.Logger;

public class BindKtSprite2D
{
	static final Logger logger=Logger.getLogger("net.exoad.nukleon.tools.bindings.Sprite2D");

	static
	{
		logger.setLevel(Level.ALL);
		logger.addHandler(new ConsoleHandler());

	}

	public static void main(@NotNull String[] args)
	{
		if(args.length>0)
		{
			System.err.println("This program does not support using arguments!");
			logger.severe("This program does not support using arguments!");
			System.exit(-1);
		}
		for(File folder : Objects.requireNonNull(new File("../../content/").listFiles(File::isFile)))
		{
			logger.info(folder.getAbsolutePath());
		}
	}
}
