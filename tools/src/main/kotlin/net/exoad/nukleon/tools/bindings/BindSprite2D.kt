package net.exoad.nukleon.tools.bindings

import java.util.logging.ConsoleHandler
import java.util.logging.Level
import java.util.logging.Logger

internal val logger:Logger=
	Logger.getLogger("net.exoad.nukleon.tools.bindings.Sprite2D").apply {
		this.addHandler(ConsoleHandler().apply c@{this@c.level=Level.ALL})
		this.level=Level.ALL
	}

internal fun main(args:Array<String>)
{
	assert(args.isEmpty())
}