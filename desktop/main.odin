package main

import game ".."

main :: proc() {
	game.init()
	for game.should_run() {
		game.update()
	}
	game.shutdown()
}
