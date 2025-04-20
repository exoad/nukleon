package net.exoad.nukleon.tools.bindings

interface Bindings
{
	fun bind(args:Array<String>)
}

fun main(args:Array<String>)
{
	BindSprite2D.bind(args)
}