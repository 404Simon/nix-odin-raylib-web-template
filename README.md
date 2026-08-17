# Odin + Raylib Web Template

Minimal template for building an [Odin](https://odin-lang.org/) + [Raylib](https://www.raylib.com/) game that runs on desktop and in the browser via WebAssembly.

Based on [odin-raylib-web](https://github.com/karl-zylinski/odin-raylib-web) by Karl Zylinski.

## Prerequisites

- [Nix](https://nixos.org/download.html) with flakes enabled
- [direnv](https://direnv.net/) (optional, for automatic shell activation)

## Quick Start

```bash
nix develop        # Enter dev shell (or `direnv allow`)
make run           # Build and run desktop version
```

## Build Targets

| Command | Description |
|---------|-------------|
| `make` / `make desktop` | Build native desktop binary |
| `make run` | Build and run desktop binary |
| `make web` | Build WebAssembly for the browser |
| `make serve` | Serve web build at http://localhost:8080 |
| `make clean` | Remove all build artifacts |

## Web Build Details

The web target compiles the game to WebAssembly in two steps:

1. **Odin** compiles `web/` to a `.wasm.o` object file
2. **Emscripten** (`emcc`) links it with raylib's wasm libraries and produces `index.html`, `index.js`, `index.wasm`

The game loop runs via `requestAnimationFrame` — no blocking loops in the browser.

## Project Structure

```
.
├── game.odin                    # Shared game logic
├── desktop/
│   └── main.odin                # Desktop entry point
├── web/
│   ├── main.odin                # Web entry point (exports C functions)
│   ├── emscripten_allocator.odin  # Allocator using emscripten's malloc
│   └── index_template.html      # HTML shell for emcc
├── flake.nix                    # Nix dev shell (Odin, Raylib, Emscripten)
├── Makefile                     # Build targets
└── README.md
```

## Architecture

The project uses a shared `game` package with separate entry points:

- **Desktop** (`desktop/main.odin`): Standard Odin `main` proc with a blocking game loop
- **Web** (`web/main.odin`): Exports `"c"` functions (`main_start`, `main_update`, `main_end`) called from JavaScript via `requestAnimationFrame`

The web build uses a custom allocator backed by emscripten's `malloc`/`free` to avoid conflicts between Odin's WASM allocator and emscripten's memory management.

## Making It Your Own

1. Edit `game.odin` — your game logic goes in `init`, `update`, `should_run`, and `shutdown`
2. Rename the window title in `game.odin:init`
3. Change the binary name in `Makefile` (replace `game` with your game name)
4. Update `flake.nix` description
