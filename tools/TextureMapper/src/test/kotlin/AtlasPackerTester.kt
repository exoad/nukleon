import com.fleeksoft.io.byteInputStream
import net.exoad.nukleon.tools.sprite2d.AtlasPacker
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.assertThrows
import org.xml.sax.SAXException
import kotlin.test.assertEquals

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
        assertThrows<SAXException> {AtlasPacker.readAtlas("SUSUS SUSFDUFDFDFDSOFJSDFODIOf".byteInputStream())}
    }
}