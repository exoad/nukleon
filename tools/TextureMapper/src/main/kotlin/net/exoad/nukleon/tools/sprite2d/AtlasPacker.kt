package net.exoad.nukleon.tools.sprite2d

import net.exoad.nukleon.tools.sprite2d.AtlasPacker.Companion.isValidAtlas
import org.w3c.dom.Document
import org.w3c.dom.NodeList
import org.xml.sax.SAXException
import java.io.File
import java.io.InputStream
import java.net.URL
import javax.imageio.ImageIO
import javax.xml.XMLConstants
import javax.xml.parsers.DocumentBuilderFactory
import javax.xml.transform.Source
import javax.xml.transform.TransformerFactory
import javax.xml.transform.dom.DOMSource
import javax.xml.transform.stream.StreamResult
import javax.xml.transform.stream.StreamSource
import javax.xml.validation.SchemaFactory
import javax.xml.xpath.XPath
import javax.xml.xpath.XPathConstants
import javax.xml.xpath.XPathFactory

data class TextureAtlas(
    val name:String,val texture:Texture,val regions:List<SpriteRegion>,
    val textureLocation:String?,val width:Int,val height:Int,
)

data class SkeletonTextureAtlas(
    var name:String? = null,
    var texture:Texture? = null,
    var regions:MutableList<SpriteRegion> = mutableListOf<SpriteRegion>(),
    var textureLocation:String? = null,
    var width:Int? = null,
    var height:Int? = null
)
{
    fun assemble():TextureAtlas = TextureAtlas(name = name!!,
        texture = texture!!,
        regions = regions,
        textureLocation = textureLocation!!,
        width = width!!,
        height = height!!
    )
}

data class SpriteRegion(val name:String,val animated:Boolean,val sprites:List<Sprite>)

data class SkeletonSpriteRegion(
    var name:String? = null,
    var animated:Boolean? = null,
    var sprites:MutableList<Sprite> = mutableListOf<Sprite>()
)
{
    fun assemble():SpriteRegion = SpriteRegion(name = name!!,animated = animated!!,sprites = sprites)
}

data class Sprite(val name:String,val index:Int = -1,val src:Rect)

class AtlasPacker
{
    companion object
    {
        const val XML_SCHEMA_LOCATION:String =
            "https://raw.githubusercontent.com/exoad/nukleon/refs/heads/main/api/sprite2d/v1/atlas_grammar.xsd"
        val transformFactory:TransformerFactory = TransformerFactory.newInstance()
        val docFactory:DocumentBuilderFactory = DocumentBuilderFactory.newInstance()
        fun writeAtlas(atlas:TextureAtlas,atlasOutput:String,writeTexture:Boolean = false)
        {
            val doc:Document =
                docFactory.newDocumentBuilder()
                    .newDocument()
            doc.createElement("Atlas").apply Atlas@{
                this@Atlas.setAttributeNS(
                    "xmlns","xsi","http://www.w3.org/2001/XMLSchema-instance"
                )
                this@Atlas.setAttributeNS(
                    "xsi","noNamespaceSchemaLocation",XML_SCHEMA_LOCATION
                )
                this@Atlas.appendChild(
                    doc.createElement("Identifier").apply Identifier@{
                        this@Identifier.nodeValue = atlas.name
                    })
                this@Atlas.appendChild(
                    doc.createElement("TextureLocation").apply TextureLocation@{
                        this@TextureLocation.nodeValue = atlas.textureLocation
                    })
                this@Atlas.appendChild(doc.createElement("Size").apply Size@{
                    this@Size.setAttribute("width",atlas.width.toString())
                    this@Size.setAttribute("height",atlas.height.toString())
                })
                this@Atlas.appendChild(
                    doc.createElement("SpriteRegions").apply SpriteRegions@{
                        for(region:SpriteRegion in atlas.regions)
                        {
                            this@SpriteRegions.appendChild(doc.createElement("Region").apply Region@{
                                this@Region.setAttribute("name",region.name)
                                this@Region.setAttribute("animated",region.animated.toString())
                                for(sprite:Sprite in region.sprites)
                                {
                                    this@Region.appendChild(doc.createElement("Sprite").apply Sprite@{
                                        this@Sprite.setAttribute("name",sprite.name)
                                        this@Sprite.setAttribute("index",sprite.index.toString())
                                        this@Sprite.setAttribute("anchorX",sprite.src.x.toString())
                                        this@Sprite.setAttribute("anchorY",sprite.src.y.toString())
                                        this@Sprite.setAttribute("width",sprite.src.width.toString())
                                        this@Sprite.setAttribute("height",sprite.src.height.toString())
                                    })
                                }
                            })
                        }
                    })
                doc.appendChild(this@Atlas)
            }
            transformFactory.newTransformer().transform(DOMSource(doc),StreamResult(atlasOutput))
            if(writeTexture)
            {
                if(!ImageIO.write(
                        atlas.texture.image,
                        "png",
                        File(atlas.textureLocation ?: atlasOutput.split(".").last())
                    )
                )
                {
                    throw RuntimeException(
                        "Failed to write texture file to ${
                            atlas.textureLocation ?: atlasOutput.split(".").last()
                        }"
                    )
                }
            }
        }

        /**
         * Internally calls [isValidAtlas] by setting [location] using [inputStream]
         *
         * @param location where the atlas file is located.
         */
        fun isValidAtlasFile(location:String):Boolean
        {
            val file = File(location)
            return if(file.exists()&&file.isFile&&file.canRead()) isValidAtlas(file.inputStream()) else false
        }

        fun isValidAtlas(source:InputStream):Boolean
        {
            val schemaURL = URL(XML_SCHEMA_LOCATION)
            try
            {
                val data:Source = StreamSource(source)
                val schemaFactory:SchemaFactory = SchemaFactory.newInstance(XMLConstants.W3C_XML_SCHEMA_NS_URI)
                val schema = schemaFactory.newSchema(schemaURL)
                schema.newValidator().validate(data)
            } catch(_:SAXException)
            {
                return false
            }
            return true
        }

        fun readAtlas(source:InputStream,validate:Boolean = true):TextureAtlas
        {
            if(validate&&!isValidAtlas(source))
                throw RuntimeException("$source is an invalid atlas source. Checked against $XML_SCHEMA_LOCATION")
            val skeleton = SkeletonTextureAtlas()
            val doc:Document = docFactory.newDocumentBuilder().parse(source)
            val xpath:XPath = XPathFactory.newInstance().newXPath()
            skeleton.name = (xpath.compile("/Atlas/Identifier")
                .evaluate(doc,XPathConstants.NODESET) as NodeList).item(0).textContent.trim()
            val sizeNode = (xpath.compile("/Atlas/Size")
                .evaluate(doc,XPathConstants.NODESET) as NodeList).item(0)
            skeleton.width = sizeNode.attributes.getNamedItem("width").nodeValue.toInt()
            skeleton.height = sizeNode.attributes.getNamedItem("height").nodeValue.toInt()
            skeleton.textureLocation = (xpath.compile("/Atlas/TextureLocation")
                .evaluate(doc,XPathConstants.NODESET) as NodeList).item(0).textContent.trim()
            val regions = (xpath.compile("/Atlas/SpriteRegions/*").evaluate(doc,XPathConstants.NODESET) as NodeList)
            for(i:Int in 0..regions.length-1)
            {
                val region = regions.item(i)
                val spriteRegion = SkeletonSpriteRegion()
                spriteRegion.name = region.attributes.getNamedItem("name").nodeValue
                spriteRegion.animated = region.attributes.getNamedItem("animated").nodeValue.toBoolean()
                for(j:Int in 0..region.childNodes.length-1)
                {
                    val sprite = region.childNodes.item(j)
                    spriteRegion.sprites.add(Sprite(
                        name = sprite.attributes.getNamedItem("name").nodeValue,
                        index = sprite.attributes.getNamedItem("index").nodeValue.toInt(),
                        src = Rect(x = sprite.attributes.getNamedItem("anchorX").nodeValue.toInt(),
                            y = sprite.attributes.getNamedItem("anchorY").nodeValue.toInt(),
                            width = sprite.attributes.getNamedItem("width").nodeValue.toInt(),
                            height = sprite.attributes.getNamedItem("height").nodeValue.toInt()
                        ),
                    )
                    )
                }
                skeleton.regions.add(spriteRegion.assemble())
            }
            return skeleton.assemble()
        }

        fun readAtlas(location:String,validate:Boolean = true):TextureAtlas
        {
            val f = File(location)
            if(validate&&(!f.exists()||!f.isFile||!f.canRead()))
                throw RuntimeException("Can't read $location as a file")
            return readAtlas(f.inputStream(),validate)
        }
    }
}