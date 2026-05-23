package main_web

import game ".."
import "base:runtime"
import "core:mem"

@(private = "file")
web_context: runtime.Context

@(export)
main_start :: proc "c" () {
	context = runtime.default_context()
	context.allocator = emscripten_allocator()
	runtime.init_global_temporary_allocator(1 * mem.Megabyte)
	web_context = context
	game.init()
}

@(export)
main_update :: proc "c" () -> bool {
	context = web_context
	game.update()
	return game.should_run()
}

@(export)
main_end :: proc "c" () {
	context = web_context
	game.shutdown()
}
