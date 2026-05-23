{
  description = "Odin + Raylib game template (desktop + web)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs =
    { nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      odin-patched = pkgs.odin.overrideAttrs (old: {
        postInstall = (old.postInstall or "") + ''
          # Restore WASM support stripped by system-raylib.patch
          sed -i 's@foreign import lib "system:raylib"@when ODIN_ARCH == .wasm32 || ODIN_ARCH == .wasm64p32 { foreign import lib "env.o" } else { foreign import lib "system:raylib" }@' \
            $out/share/vendor/raylib/raylib.odin \
            $out/share/vendor/raylib/rlgl/rlgl.odin
          sed -i 's@foreign import lib "system:raygui"@when ODIN_ARCH == .wasm32 || ODIN_ARCH == .wasm64p32 { foreign import lib "env.o" } else { foreign import lib "system:raygui" }@' \
            $out/share/vendor/raylib/raygui.odin
        '';
      });
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          odin-patched
          raylib
          libGL
          libglvnd
          mesa
          libx11
          libxrandr
          libxinerama
          libxcursor
          libxi
          emscripten
        ];

        LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
          pkgs.libGL
          pkgs.libglvnd
          pkgs.libx11
          pkgs.libxrandr
          pkgs.libxinerama
          pkgs.libxcursor
          pkgs.libxi
          pkgs.raylib
          pkgs.mesa
        ];
      };
    };
}
