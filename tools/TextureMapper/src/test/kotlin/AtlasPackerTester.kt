import com.fleeksoft.io.byteInputStream
import net.exoad.nukleon.tools.Sprite2D
import net.exoad.nukleon.tools.sprite2d.AtlasPacker
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.assertDoesNotThrow
import kotlin.test.assertEquals
import kotlin.test.assertTrue

class AtlasPackerTester
{
    @Test
    fun basicAtlas()
    {
        val atlas = AtlasPacker.readAtlas("../../planning/sprite2d/SpriteAtlasExample.xml")
        assertEquals(atlas.name,
            "some_goofy_nonexistent_sprites"
        )
        assertEquals(atlas.width,420)
        assertEquals(atlas.height,69)
    }

    @Test
    fun notValid()
    {
        assertTrue {!AtlasPacker.isValidAtlas("SUSUS SUSFDUFDFDFDSOFJSDFODIOf".byteInputStream())}
    }

    @Test
    fun generateAtlases()
    {
        assertDoesNotThrow {
            Sprite2D.packAtlas("../../content/ui_content",
                atlasName = "ui_content",
                textureOutputLocation = "./",
                animated = false
            )
        }
    }
}