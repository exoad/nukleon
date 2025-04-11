package net.exoad.nukleon.tools.sprite2d

import net.exoad.nukleon.tools.Sprite2D

/**
 * The main build point for the CLI usage of this tool.
 *
 * It takes [args] which are a long list of connected strings of which must follow the following format for each
 * input folder:
 * ```
 * <path_to_input_folder>:<atlas_name>:<animated>:<output_folder_location>
 * ```
 *
 * - `path_to_input_folder` represents the input folder location
 * - `atlas_name` represents the name to give this atlas internally and the file as well
 * - `animated` a boolean value representing whether the sprites inside are animated
 * - `output_folder_location` where to place this resulting generated atlas and its texture (this tool assumes that the
 *    texture and the atlas itself are right next to each other)
 */
object CommandApp
{
    @JvmStatic
    fun main(args:Array<String>)
    {
	    for(string in args)
	    {
		    val parts = string.split(":")
		    Sprite2D.Companion.packAtlas(parts[0],atlasKey = parts[1],animated = parts[2].toBooleanStrictOrNull()==true)
	    }
    }
}