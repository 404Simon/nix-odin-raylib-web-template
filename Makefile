ODIN_ROOT := $(shell odin root)
RAYLIB_WASM := build/raylib/libraylib.a

.PHONY: all desktop web serve run clean

all: desktop

desktop:
	odin build desktop -vet -strict-style -out:game \
		-o:speed -lto:thin -no-bounds-check -disable-assert

$(RAYLIB_WASM):
	@echo "Building raylib for WebAssembly..."
	@mkdir -p build/raylib
	@RAYLIB_SRC=$$(nix build nixpkgs#raylib.src --print-out-paths 2>/dev/null) && \
		rm -rf /tmp/raylib-wasm-build && \
		cp -r $$RAYLIB_SRC /tmp/raylib-wasm-build && \
		chmod -R u+w /tmp/raylib-wasm-build && \
		cd /tmp/raylib-wasm-build/src && \
		make PLATFORM=PLATFORM_WEB -j$$(nproc) && \
		cp libraylib.web.a $(CURDIR)/build/raylib/libraylib.a && \
		rm -rf /tmp/raylib-wasm-build

web: $(RAYLIB_WASM)
	odin build web -target:js_wasm32 -build-mode:obj \
		-vet -strict-style \
		-out:game.wasm.o
	cp $(ODIN_ROOT)/core/sys/wasm/js/odin.js .
	emcc -o index.html game.wasm.o \
		$(CURDIR)/build/raylib/libraylib.a \
		-sEXPORTED_RUNTIME_METHODS='[HEAPF32]' \
		-sUSE_GLFW=3 \
		-sWASM_BIGINT \
		-sASYNCIFY \
		-sWARN_ON_UNDEFINED_SYMBOLS=0 \
		--shell-file web/index_template.html
	rm -f game.wasm.o

serve:
	@echo "Serving at http://localhost:8080"
	emrun --no_browser --port 8080 index.html

run: desktop
	./game

clean:
	rm -rf game index.html index.js index.wasm odin.js game.wasm.o build/
