package net.exoad.nukleon.tools.texturemapper;

import org.jetbrains.annotations.NotNull;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
public final class Sprite2DPacker
{
	private Sprite2DPacker()
	{
	}

	public static void pack(@NotNull final String folderLoc,@NotNull final String outputLocation)
	{
		// load the actual images
		final File rootFolder=new File(folderLoc);
		assert rootFolder.exists() : "Root folder "+folderLoc+" must exist!";
		assert rootFolder.isDirectory() : "Root folder "+folderLoc+" is not a folder";
		final List< Utils.Atlas > atlases=new ArrayList<>();
		for(final File subFolder : Objects.requireNonNull(rootFolder.listFiles(File::isDirectory)))
		{
			final List< BufferedImage > textures=new ArrayList<>();
			final List< Utils.FreeRect > rects=new ArrayList<>();
			final File[] images=subFolder.listFiles();
			for(final File r : Objects.requireNonNull(images))
			{
				try
				{
					textures.add(ImageIO.read(r));
				} catch(IOException e)
				{
					throw new RuntimeException(e);
				}
			}
			textures.sort((final BufferedImage a,final BufferedImage b)->Integer.compareUnsigned(
					a.getWidth()*a.getHeight(),b.getWidth()*b.getHeight()));
			// referenced from: https://kylehalladay.com/blog/tutorial/2016/11/04/Texture-Atlassing-With-Mips.html
			int shortSide=Integer.MAX_VALUE;
			int longSide=Integer.MAX_VALUE;
			System.out.println(textures.get(0).getWidth()*textures.get(0).getHeight());
			System.out.println(textures.get(textures.size()-1).getWidth()*textures.get(textures.size()-1).getHeight());
		}

	}
}
