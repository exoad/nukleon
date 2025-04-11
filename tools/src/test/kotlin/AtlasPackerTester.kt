import com.fleeksoft.io.byteInputStream
import net.exoad.nukleon.tools.Sprite2D
import net.exoad.nukleon.tools.sprite2d.AtlasAssembler
import net.exoad.nukleon.tools.sprite2d.TextureAtlas
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.assertDoesNotThrow
import java.io.File
import javax.imageio.ImageIO
import kotlin.test.assertContains
import kotlin.test.assertEquals
import kotlin.test.assertTrue

class AtlasPackerTester
{
    @Test
    fun basicAtlas()
    {
        val atlas = AtlasAssembler.readAtlas("../../planning/sprite2d/SpriteAtlasExample.xml")
        assertEquals(atlas.name,
            "some_goofy_nonexistent_sprites"
        )
        assertEquals(atlas.width,420)
        assertEquals(atlas.height,69)
    }

    @Test
    fun notValid()
    {
        assertTrue {!AtlasAssembler.isValidAtlas("SUSUS SUSFDUFDFDFDSOFJSDFODIOf".byteInputStream())}
    }

    @Test
    fun generateAtlases()
    {
        lateinit var r:TextureAtlas
        assertDoesNotThrow {
            r = Sprite2D.packAtlas("../../content/ui_content",
                atlasKey = "ui_content",
                textureOutputLocation = "./",
                animated = false
            )
        }
        assertContains(
            r.spriteList.map {it.name},"Button_Facet_1_Normal"
        )
        AtlasAssembler.writeAtlas(r,"../../test-generated/Amogus.xml",false,embedTexture = true)
        ImageIO.write(r.texture!!.image,"png",File("../../test-generated/Amogus.png"))
    }
}