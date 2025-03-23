{
  description = "Bun development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

        # Use LLVM 19 consistently
        llvmPkgs = pkgs.llvmPackages_19;

        # Common dependencies for both platforms
        commonDeps = with pkgs; [
          # Use consistent LLVM 19 toolchain
          llvmPkgs.clang
          llvmPkgs.llvm
          llvmPkgs.lld
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
          icu
          sqlite
        ];

        # Platform specific dependencies
        platformDeps = with pkgs;
          if stdenv.isDarwin then [
            darwin.cctools # for dsymutil
            libiconv
            apple-sdk_13  # Add the SDK directly
          ] else [
            # Linux specific dependencies
          ];

      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = commonDeps ++ platformDeps;

          shellHook = ''
            # Set up compiler and toolchain
            export CC="${llvmPkgs.clang}/bin/clang"
            export CXX="${llvmPkgs.clang}/bin/clang++"
            export PATH="$PWD/node_modules/.bin:$PATH"
            
            ${if pkgs.stdenv.isDarwin then ''
              # Set deployment target and SDK
              export MACOSX_DEPLOYMENT_TARGET="13.0"
              export CMAKE_OSX_DEPLOYMENT_TARGET="13.0"
              
              # Use SDK 13 from nixpkgs
              export CMAKE_OSX_SYSROOT="${pkgs.apple-sdk_13.passthru.sdkroot}"
              
              # Set up framework paths
              export FRAMEWORK_PATH="${pkgs.apple-sdk_13.passthru.sdkroot}/System/Library/Frameworks"
              
              # Add framework path to compiler flags
              export NIX_CFLAGS_COMPILE="-F${pkgs.apple-sdk_13.passthru.sdkroot}/System/Library/Frameworks $NIX_CFLAGS_COMPILE"
              
              # Set up library paths
              export LIBRARY_PATH="${pkgs.apple-sdk_13.passthru.sdkroot}/usr/lib:${pkgs.apple-sdk_13.passthru.sdkroot}/System/Library/Frameworks"
              
              # Configure pkg-config to find system frameworks
              export PKG_CONFIG_PATH="${pkgs.apple-sdk_13.passthru.sdkroot}/System/Library/Frameworks/CoreFoundation.framework/Resources/pkgconfig:${pkgs.apple-sdk_13.passthru.sdkroot}/System/Library/Frameworks/CoreServices.framework/Resources/pkgconfig:$PKG_CONFIG_PATH"

              # Set up CMake configuration
              export CMAKE_C_COMPILER="${llvmPkgs.clang}/bin/clang"
              export CMAKE_CXX_COMPILER="${llvmPkgs.clang}/bin/clang++"
              export CMAKE_LINKER="${llvmPkgs.lld}/bin/ld.lld"
              export CMAKE_AR="${llvmPkgs.llvm}/bin/llvm-ar"
              export CMAKE_RANLIB="${llvmPkgs.llvm}/bin/llvm-ranlib"
              export CMAKE_DSYMUTIL="${pkgs.darwin.cctools}/bin/dsymutil"

              # Set linker flags to avoid -ld_new issues
              export CMAKE_C_FLAGS="-Wl,-no_new_main"
              export CMAKE_CXX_FLAGS="-Wl,-no_new_main"
              export CMAKE_EXE_LINKER_FLAGS="-Wl,-no_new_main"
              export CMAKE_SHARED_LINKER_FLAGS="-Wl,-no_new_main"
              export CMAKE_MODULE_LINKER_FLAGS="-Wl,-no_new_main"

              # Set CMake generator to Ninja
              export CMAKE_GENERATOR="Ninja"

              # Ensure symbols.txt has correct line endings if it exists
              if [ -f src/symbols.txt ]; then
                echo >> src/symbols.txt
              fi

              # Clean build directory if it exists
              if [ -d build ]; then
                rm -rf build
              fi

              # Create build directory
              mkdir -p build/debug
            '' else ""}
          '';

          # Preserve MACOS_DEPLOYMENT_TARGET on macOS
          inherit (pkgs.stdenv) isDarwin;
          MACOS_DEPLOYMENT_TARGET = if pkgs.stdenv.isDarwin then "13.0" else null;
        };
      }
    );
}
