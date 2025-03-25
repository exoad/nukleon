package net.exoad.nukleon.tools.sprite2d

import kotlin.math.max

private data class TextureLayout(var width:Int,var height:Int,val rects:MutableList<Rect>)

data class AtlasLayout(val width:Int,val height:Int,val rects:List<Rect>)

class Transmuter
{
    companion object
    {

        /**
         * If [alreadySorted] is `true`, this function will not perform any kind of O(nlogn) sorting, but can result
         * in bogus results if [rects] is actually not sorted.
         *
         * Ported from the Javascript library [pack](https://github.com/semibran/pack/blob/master/lib/pack.js)
         *
         * Uses a First-Fit Decreasing Bin Packing Algorithm for packing the rectangles together (https://en.wikipedia.org/wiki/First-fit-decreasing_bin_packing)
         */
        fun firstFitDecreasing(
            rects:List<Rect>,
            alreadySorted:Boolean = false,
            whiteSpaceWeight:Int = 1,
            sideLengthWeight:Int = 20
        ):AtlasLayout
        {
            fun findPositions(rects:List<Rect>):MutableList<Pair<Int,Int>>
            {
                var pos = mutableListOf<Pair<Int,Int>>()
                for(i in 0..rects.size-1)
                {
                    val r = rects[i]
                    for(x:Int in 0..r.width-1)
                        pos.add(Pair(r.x+x,r.y+r.height))
                    for(y:Int in 0..r.height-1)
                        pos.add(Pair(r.x+r.width,r.y+y))
                }
                return pos
            }

            fun findBounds(rects:List<Rect>):Pair<Int,Int>
            {
                var w = 0
                var h = 0
                for(i:Int in 0..rects.size-1)
                {
                    if(rects[i].x2()>w)
                        w = rects[i].x2()
                    if(rects[i].y2()>h)
                        h = rects[i].y2()
                }
                return Pair(w,h)
            }

            val r:MutableList<Rect> =
                if(!alreadySorted) rects.toMutableList() else rects.sortedDescending().toMutableList()
            var layout = TextureLayout(0,0,mutableListOf<Rect>())
            var order = mutableListOf<Int>()
            for(i:Int in 0..r.size-1)
                order.add(i)
            order.sortWith {a,b-> r[a].area().compareTo(r[a].area())}
            for(i:Int in 0..r.size-1)
            {
                var s = r[order[i]]
                findBestRect@{
                    var best = Rect(0,0,s.width,s.height)
                    if(rects.isEmpty())
                        s = best
                    else
                    {
                        // findBestRect
                        var rr = Rect(0,0,s.width,s.height)
                        var skeleton = TextureLayout(0,0,layout.rects)
                        var bestScore = Int.MAX_VALUE
                        var positions = findPositions(layout.rects)
                        for(j:Int in 0..positions.size-1)
                        {
                            var pos = positions[j]
                            rr.x = pos.first
                            rr.y = pos.second
                            if(rr.intersectsNone(layout.rects))
                            {
                                skeleton.rects[layout.rects.size] = rr
                                var sz = findBounds(skeleton.rects)
                                skeleton.width = sz.first
                                skeleton.height = sz.second
                                // rate
                                var whitespace = skeleton.width*skeleton.height
                                for(i:Int in 0..skeleton.rects.size-1)
                                    whitespace -= skeleton.rects[i].area()
                                var score =
                                    whitespace*whiteSpaceWeight*max(skeleton.width,skeleton.height)*sideLengthWeight
                                if(score<bestScore)
                                {
                                    bestScore = score
                                    best.x = rr.x
                                    best.y = rr.y
                                }
                            }
                        }
                        s = best
                    }
                }
                layout.rects.add(s)
                var bounds = findBounds(layout.rects)
                layout.width = bounds.first
                layout.height = bounds.second
            }
            for(i:Int in 0..layout.rects.size-1)
            {
                var tmp = layout.rects[order[i]]
                layout.rects[order[i]] = layout.rects[i]
                layout.rects[i] = tmp
            }
            return AtlasLayout(layout.width,layout.height,layout.rects)
        }
    }
}