{
  description = "Bun development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

        # Common dependencies for both platforms
        commonDeps = with pkgs; [
          llvmPackages_18.clang
          llvmPackages_18.llvm
          llvmPackages_18.lld
          cmake
          python3
          nodePackages.npm
          go
          automake
          libtool
          ninja
          pkg-config
          rustc
          cargo
          git
          esbuild
          ccache
          bun
          nodejs_20
        ];

        # Platform specific dependencies
        platformDeps = with pkgs;
          if stdenv.isDarwin then [
            darwin.apple_sdk.frameworks.Security
            darwin.apple_sdk.frameworks.CoreServices
            darwin.apple_sdk.frameworks.CoreFoundation
            darwin.apple_sdk.frameworks.Foundation
            darwin.cctools # for dsymutil
            libiconv
          ] else [
            # Linux specific dependencies
          ];

      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = commonDeps ++ platformDeps;

          shellHook = ''
            export CC="${pkgs.llvmPackages_18.clang}/bin/clang"
            export CXX="${pkgs.llvmPackages_18.clang}/bin/clang++"
            export PATH="$PWD/node_modules/.bin:$PATH"
            
            # Set correct macOS deployment target and SDK settings
            ${if pkgs.stdenv.isDarwin then ''
              export MACOSX_DEPLOYMENT_TARGET="13.0"
              export CMAKE_OSX_DEPLOYMENT_TARGET="13.0"
              export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:/opt/homebrew/lib/pkgconfig:$PKG_CONFIG_PATH"
            '' else ""}
          '';

          # Preserve MACOS_DEPLOYMENT_TARGET on macOS
          inherit (pkgs.stdenv) isDarwin;
          MACOS_DEPLOYMENT_TARGET = if pkgs.stdenv.isDarwin then "13.0" else null;
        };
      }
    );
}
