package net.exoad.nukleon.tools.sprite2d

object GreedyRectPacker
{
    var kWhiteSpaceWeight = 1
    var kSideLengthWeight = 20

    data class TextureLayout(var width:Int,var height:Int,val rects:MutableList<Rect>)

    private fun findBestRect(layout:TextureLayout,size:Rect):Rect
    {
        if(layout.rects.isEmpty()) return Rect(0,0,width = size.width,height = size.height)
        var bestRect = Rect(0,0,width = size.width,height = size.height)
        var bestScore = Int.MAX_VALUE
        layout.rects.flatMap {rect->
            (0 until rect.width).map {x->
                Rect(rect.x+x,rect.y+rect.height,0,0)
            }+(0 until rect.height).map {y->
                Rect(rect.x+rect.width,rect.y+y,0,0)
            }
        }.forEach {pos->
            val rect = Rect(pos.x,pos.y,size.width,size.height)
            if(layout.rects.none {it.intersects(rect)})
            {
                val sandbox = TextureLayout(0,0,
                    rects = (layout.rects+rect).toMutableList()
                ).apply {
                    var width = rects.maxOf {it.x+it.width}
                    var height = rects.maxOf {it.y+it.height}
                    Rect(0,0,width = width,height = height).let {
                        width = it.width
                        height = it.height
                    }
                }
                val score = (sandbox.width*sandbox.height-sandbox.rects.sumOf {it.width*it.height})*kWhiteSpaceWeight+
                        maxOf(sandbox.width,sandbox.height)*kSideLengthWeight
                if(score<bestScore)
                {
                    bestScore = score
                    bestRect = rect.copy()
                }
            }
        }
        return bestRect
    }

    fun pack(sizes:List<Rect>):TextureLayout
    {
        if(sizes.isEmpty()) throw IllegalArgumentException("No rectangles provided to pack!")
        val order = sizes.indices.sortedByDescending {sizes[it].area()}
        val layout = TextureLayout(0,0,mutableListOf<Rect>())
        order.forEach {index->
            val size = sizes[index]
            val rect = findBestRect(layout,size).also {
                it.width = size.width
                it.height = size.height
            }
            layout.rects.add(rect)
            val width = layout.rects.maxOf {it.x+it.width}
            val height = layout.rects.maxOf {it.y+it.height}
            Rect(0,0,width = width,height = height).let {
                layout.width = it.width
                layout.height = it.height
            }
        }
        val reorderedRects = order.map {layout.rects[it]}.toMutableList()
        return TextureLayout(layout.width,layout.height,reorderedRects)
    }
}