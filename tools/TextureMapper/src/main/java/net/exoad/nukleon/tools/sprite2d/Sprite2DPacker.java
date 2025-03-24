package net.exoad.nukleon.tools.sprite2d;

import net.exoad.nukleon.tools.texturemapper.Utils;
import org.jetbrains.annotations.NotNull;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import java.util.logging.Logger;
public final class Sprite2DPacker
{
	public static final Logger $logger=Logger.getLogger("net.exoad.nukleon.tools.sprite2d");

	private Sprite2DPacker()
	{
	}

	public static void pack(
			@NotNull final String folderLoc,@NotNull final String outputLocation,final String... ignoreDirectories)
	{
		// load the actual images
		final File rootFolder=new File(folderLoc);
		assert rootFolder.exists() : "Root folder "+folderLoc+" must exist!";
		assert rootFolder.isDirectory() : "Root folder "+folderLoc+" is not a folder";
		final List< Utils.Atlas > atlases=new ArrayList<>();
		$logger.info("Creating texture pack from "+folderLoc);
		for(final File subFolder : Objects.requireNonNull(rootFolder.listFiles(File::isDirectory)))
		{
			$logger.info("Atlas create: "+subFolder.getName());
			final List< BufferedImage > textures=new ArrayList<>();
			final List< Utils.FreeRect > rects=new ArrayList<>();
			final File[] images=subFolder.listFiles();
			for(final File r : Objects.requireNonNull(images))
			{
				$logger.info("Feeding: "+r.getName());
				try
				{
					textures.add(Objects.requireNonNull(ImageIO.read(r)));
					$logger.info("Reading texture sprite: "+r.getName().split("\\.")[0]);
				} catch(IOException e)
				{
					throw new RuntimeException(e);
				}
			}
			$logger.info("LENGTH %d".formatted(textures.size()));
			textures.sort((final BufferedImage a,final BufferedImage b)->Integer.compareUnsigned(
					a.getWidth()*a.getHeight(),b.getWidth()*b.getHeight()));
			// referenced from: https://kylehalladay.com/blog/tutorial/2016/11/04/Texture-Atlassing-With-Mips.html
			int shortSide=Integer.MAX_VALUE;
			int longSide=Integer.MAX_VALUE;
			$logger.finest("A "+textures.get(0).getWidth()*textures.get(0).getHeight());
			$logger.finest("B "+textures.get(textures.size()-1).getWidth()*textures.get(textures.size()-1).getHeight());
		}

	}
}
