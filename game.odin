package game

import rl "vendor:raylib"

player_pos := rl.Vector2{640, 320}
player_size := rl.Vector2{64, 64}

init :: proc() {
	rl.InitWindow(1280, 720, "Game")
	when ODIN_OS != .JS {
		rl.SetTargetFPS(60)
	}
}

update :: proc() {
	rl.BeginDrawing()
	rl.ClearBackground(rl.BLUE)

	if rl.IsKeyDown(.LEFT) {player_pos.x -= 400 * rl.GetFrameTime()}
	if rl.IsKeyDown(.RIGHT) {player_pos.x += 400 * rl.GetFrameTime()}
	if rl.IsKeyDown(.UP) {player_pos.y -= 400 * rl.GetFrameTime()}
	if rl.IsKeyDown(.DOWN) {player_pos.y += 400 * rl.GetFrameTime()}

	rl.DrawRectangleV(player_pos, player_size, rl.GREEN)
	rl.EndDrawing()
}

should_run :: proc() -> bool {
	when ODIN_OS == .JS {
		return true
	}
	return !rl.WindowShouldClose()
}

shutdown :: proc() {
	rl.CloseWindow()
}
