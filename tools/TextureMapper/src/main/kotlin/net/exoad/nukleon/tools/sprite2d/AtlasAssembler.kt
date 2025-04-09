package net.exoad.nukleon.tools.sprite2d

import net.exoad.nukleon.tools.sprite2d.AtlasAssembler.Companion.isValidAtlas
import org.w3c.dom.Document
import org.w3c.dom.NodeList
import org.xml.sax.SAXException
import java.io.ByteArrayOutputStream
import java.io.File
import java.io.IOException
import java.io.InputStream
import java.net.URL
import java.util.*
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


/**
 * Represents a singular description of a texture atlas
 *
 * - [name] signifies what this atlas is called and can be different from the file name, never use the file name!
 * - [animated] a custom modifier that just tells other code that you should animate this atlas
 * - [textureLocation] where the actual texture bitmap is located
 * - [texture] this is a **nullable** value and represents the raw bitmap data in memory that this atlas represents
 * - [spriteList] all the sprites in this atlas and their descriptions, see [Sprite]
 * - [width] & [height] represent the dimensions of this atlas's bitmap content (this is the intended dimensions)
 */
data class TextureAtlas(
    val name:String,val texture:Texture?,val spriteList:List<Sprite>,
    val animated:Boolean,
    val textureLocation:String?,val width:Int,val height:Int,
)

/**
 * Internal skeleton class that can be filled to become a [TextureAtlas]
 *
 * **Should never be instantiated by external code.**
 */
data class SkeletonTextureAtlas(
    var name:String? = null,
    var texture:Texture? = null,
    var animated:Boolean? = null,
    var spriteList:MutableList<Sprite> = mutableListOf<Sprite>(),
    var textureLocation:String? = null,
    var width:Int? = null,
    var height:Int? = null
)
{
    fun assemble():TextureAtlas = TextureAtlas(name = name!!,
        texture = texture,
        spriteList = spriteList,
        textureLocation = textureLocation!!,
        width = width!!,
        height = height!!,
        animated = animated!!
    )
}

/**
 * Represents a singular item in a [TextureAtlas] and contains 3 simple properties:
 * - [name] what this sprite is called or its identifier
 * - [index] most of the time -1, but is crucial to be indexed properly when [TextureAtlas.animated] is set to `true`
 * - [src] the bounding box of this sprite within [TextureAtlas.texture] bitmap and thus can be used to determine generally
 *  the width and height, but should not be used for anything else.
 */
data class Sprite(val name:String,val index:Int = -1,val src:Rect)

/**
 * Parses and writes the XML format of the sprite atlas. It also handles validation using the online schema when available.
 *
 * *If the atlas packer is an older version, it may be crucial to supply with the latest URL to the latest schema in functions
 * like [AtlasAssembler.isValidAtlas] and [AtlasAssembler.writeAtlas]*
 *
 * By default, the versioning of this atlas packer tool is bound to the most current schema version it was written for. It is ill-advised
 * to use a newer version or older version as this software is meant for internal usage.
 */
class AtlasAssembler
{
    companion object
    {
        val transformFactory:TransformerFactory = TransformerFactory.newInstance()
        val docFactory:DocumentBuilderFactory = DocumentBuilderFactory.newInstance()

        /**
         * Write an atlas file
         * - [atlasOutput] used as both the output location of the bitmap texture file and the actual schema file
         * - [writeTexture] writes the texture file to a physical location using either [atlas]'s [TextureAtlas.textureLocation] or [atlasOutput] directly if the former is null
         * - [embedTexture] writes the texture data as a base64 encoded string of data within the texture atlas
         * - [schemaLocation] - optional binding for the xsd, the default value is the recommended version to use for this packer version
         *
         * Both writing and embedding are allowed at the same time; however, when reading the atlas back, embedded textures
         * are prioritized and whatever the atlas specifies as "TextureLocation" is ignored.
         */
        fun writeAtlas(
            atlas:TextureAtlas,
            atlasOutput:String,
            writeTexture:Boolean = false,
            embedTexture:Boolean = false,
            schemaLocation:String = "https://raw.githubusercontent.com/exoad/nukleon/refs/heads/main/api/sprite2d/v2/atlas_grammar.xsd"
        )
        {
            val doc:Document =
                docFactory.apply {isNamespaceAware = true}.newDocumentBuilder()
                    .newDocument()
            // create the first node which is the atlas node
            doc.createElement("Atlas").apply Atlas@{
                this@Atlas.setAttribute("xmlns:xsi","http://www.w3.org/2001/XMLSchema-instance")
                this@Atlas.setAttribute(
                    "xsi:noNamespaceSchemaLocation",schemaLocation
                )
                this@Atlas.appendChild(
                    doc.createElement("Identifier").apply {
                        appendChild(doc.createTextNode(atlas.name))
                    }
                )
                if(atlas.textureLocation!=null)
                {
                    assert(atlas.textureLocation.split(".").last().equals("png",ignoreCase = true)
                    ) {"Supplied texture location ${atlas.textureLocation} does not exist! Must be a valid file ending in '.png'"}
                    this@Atlas.appendChild(
                        doc.createElement("TextureLocation").apply {
                            appendChild(doc.createTextNode(atlas.textureLocation))
                        }
                    )
                }
                this@Atlas.appendChild(doc.createElement("Size").apply Size@{
                    this@Size.setAttribute("width",atlas.width.toString())
                    this@Size.setAttribute("height",atlas.height.toString())
                })
                this@Atlas.appendChild(
                    doc.createElement("SpriteList").apply SpriteList@{
                        atlas.animated.let {
                            this@SpriteList.setAttribute("animated",atlas.animated.toString())
                        }
                        var i = 0
                        for(sprite:Sprite in atlas.spriteList)
                        {
                            this@SpriteList.appendChild(doc.createElement("Sprite").apply Sprite@{
                                sprite.let {
                                    setAttribute("name",sprite.name)
                                    setAttribute("index",(if(sprite.index==-1) sprite.index else i++).toString())
                                    setAttribute("anchorX",sprite.src.x.toString())
                                    setAttribute("anchorY",sprite.src.y.toString())

                                    setAttribute("width",sprite.src.width.toString())
                                    setAttribute("height",sprite.src.height.toString())
                                }
                            })
                        }
                    })
                // =========================================================================================================================
                // V2: Incorporation of optional base64 encoded data
                //
                // - Inclusion of this element means that the previously constructed "TextureLocation" element will be removed and ignored
                // - The texture will be loaded directly into memory
                // - Writing to external and also embedding within can be done at the same time
                // - Reading to external and also embedding is not possible, embedding is preferred if both exists.
                // =========================================================================================================================
                if(embedTexture&&atlas.texture!=null)
                {
                    val os = ByteArrayOutputStream()
                    try
                    {
                        if(ImageIO.write(atlas.texture.image,"PNG",os))
                            this@Atlas.appendChild(doc.createElement("EncodedBitmap").apply EmbeddedBitmap@{
                                this@EmbeddedBitmap.textContent =
                                    Base64.getEncoder().encodeToString(os.toByteArray())
                            })

                    } catch(ioe:IOException)
                    {
                        throw ioe
                    }
                }
                doc.appendChild(this@Atlas)
            }

            transformFactory.newTransformer().transform(DOMSource(doc),StreamResult(File(atlasOutput)))
            if(writeTexture)
            {
                if(atlas.texture!=null&&!ImageIO.write(
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

        fun isValidAtlas(
            source:InputStream,
            schemaLocation:String = "https://raw.githubusercontent.com/exoad/nukleon/refs/heads/main/api/sprite2d/v1/atlas_grammar.xsd"
        ):Boolean
        {
            val schemaURL = URL(schemaLocation)
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

        fun readAtlas(source:InputStream):TextureAtlas
        {
            if(source.available()==0)
                throw RuntimeException("$source is empty")
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
            val sprites = (xpath.compile("/Atlas/SpriteList/*").evaluate(doc,XPathConstants.NODESET) as NodeList)
            val animatedVal = (xpath.compile("/Atlas/SpriteList")
                .evaluate(doc,XPathConstants.NODESET) as NodeList).item(0).attributes.getNamedItem("animated")
            skeleton.animated = if(animatedVal!=null) animatedVal.nodeValue.toBoolean() else false
            for(i:Int in 0..sprites.length-1)
            {
                val sprite = sprites.item(i)
                skeleton.spriteList.add(Sprite(
                    name = sprite.attributes.getNamedItem("name").nodeValue,
                    index = sprite.attributes.getNamedItem("index").nodeValue.toInt(),
                    src = Rect(x = sprite.attributes.getNamedItem("anchorX").nodeValue.toInt(),
                        y = sprite.attributes.getNamedItem("anchorY").nodeValue.toInt(),
                        width = sprite.attributes.getNamedItem("width").nodeValue.toInt(),
                        height = sprite.attributes.getNamedItem("height").nodeValue.toInt()
                    )
                )
                )
            }
            return skeleton.assemble()
        }

        fun readAtlas(location:String,validate:Boolean = true):TextureAtlas
        {
            val f = File(location)
            if(validate&&(!f.exists()||!f.isFile||!f.canRead()))
                throw RuntimeException("Can't read $location as a file")
            return readAtlas(f.inputStream())
        }
    }
}