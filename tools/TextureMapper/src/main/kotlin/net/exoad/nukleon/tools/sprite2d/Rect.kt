package net.exoad.nukleon.tools.sprite2d

import kotlin.math.max
import kotlin.math.min

data class Rect(var x:Int,var y:Int,var width:Int,var height:Int):Comparable<Rect>
{
    override fun compareTo(other:Rect):Int = area().compareTo(other.area())

    fun longSide():Int = max(width,height)

    fun shortSide():Int = min(width,height)

    fun intersects(other:Rect):Boolean =
        x<other.x+other.width&&x+width>other.x&&y<other.y+other.height&&y+height>other.y

    fun intersectsAll(rects:List<Rect>):Boolean = rects.all {a-> intersects(a)}

    fun intersectsNone(rects:List<Rect>):Boolean = rects.none {a-> intersects(a)}

    /**
     * The bottom right point's x-value
     */
    fun x2():Int = x+width

    /**
     * The bottom right point's y-value
     */
    fun y2():Int = y+height

    fun area():Int = width*height
}

