package net.exoad.nukleon.tools.sprite2d

import org.w3c.dom.Document
import javax.xml.parsers.DocumentBuilderFactory

enum class TextureFilter
{
    NEAREST, LINEAR, MIPMAP,

    /// nearest nearest
    MIPMAP_NN,

    /// linear nearest
    MIPMAP_LN,

    /// nearest linear
    MIPMAP_NL,

    /// linear linear
    MIPMAP_LL;
}

enum class TextureFileEncoding
{
    RGBA8888, RGBA4444, RGB888, RGB565, ALPHA;
}

data class TextureAtlas(
    val name:String,val texture:Texture,val regions:List<SpriteRegion>,
    val magFilter:TextureFilter,val minFilter:TextureFilter,
    val textureLocation:String,val width:Int,val height:Int,
    val encoding:TextureFileEncoding
)

data class SpriteRegion(val name:String,val animated:Boolean,val sprites:List<Sprite>)

data class Sprite(val name:String,val index:Int = -1,val anchorX:Int,val anchorY:Int,val width:Int,val height:Int)

class AtlasPacker
{
    companion object
    {
        const val xmlSchemaLocation:String =
            "https://exoad.github.io/nukleon/api/sprite2d/v1/atlas_grammar.xsd"

        fun writeAtlas(atlas:TextureAtlas,output:String)
        {
            val doc:Document =
                DocumentBuilderFactory.newInstance().newDocumentBuilder()
                    .newDocument()
            doc.createElement("Atlas").apply Atlas@{
                this.setAttributeNS(
                    "xmlns","xsi","http://www.w3.org/2001/XMLSchema-instance"
                )
                this.setAttributeNS(
                    "xsi","noNamespaceSchemaLocation",xmlSchemaLocation
                )
                this.appendChild(
                    doc.createElement("Identifier").apply Identifier@{
                        this.nodeValue = atlas.name
                    })
                this.appendChild(
                    doc.createElement("TextureLocation").apply TextureLocation@{
                        this.nodeValue = atlas.textureLocation
                    })
                this.appendChild(doc.createElement("Size").apply Size@{
                    this.setAttribute("width",atlas.width.toString())
                    this.setAttribute("height",atlas.height.toString())
                })
                this.appendChild(
                    doc.createElement("SpriteRegions").apply SpriteRegions@{

                    })
                doc.appendChild(this)
            }
        }
    }
}