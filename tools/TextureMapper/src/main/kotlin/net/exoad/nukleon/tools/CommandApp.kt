package net.exoad.nukleon.tools

/**
 * The main build point for the CLI usage of this tool.
 *
 * It takes [args] which are a long list of connected strings of which must follow the following format for each
 * input folder:
 * ```
 * <path_to_input_folder>:<atlas_name>:<animated>
 * ```
 *
 * - `path_to_input_folder` represents the input folder location
 * - `atlas_name` represents the name to give this atlas internally and the file as well
 * - `animated` a boolean value representing whether the sprites inside are animated
 */
fun main(args:Array<String>)
{
    for(string in args)
    {
        val parts = string.split(":")
        Sprite2D.packAtlas(parts[0],atlasKey = parts[1],animated = parts[2].toBooleanStrictOrNull()==true)
    }
}