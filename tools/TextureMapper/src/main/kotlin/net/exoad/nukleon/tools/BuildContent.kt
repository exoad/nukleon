package net.exoad.nukleon.tools

object BuildContent
{
    /**
     * Each individual item in [args] is a folder to look for
     */
    @JvmStatic
    fun main(args:Array<String>)
    {
        for(arg in args)
        {
            Sprite2D.packAtlas(arg)
        }
    }
}