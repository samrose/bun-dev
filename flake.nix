{
  description = "Development environment for bun";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShell = pkgs.mkShell {
          packages = with pkgs; [
            cmake
            ninja
            pkg-config
            bun
            nodejs_20
            llvmPackages_19.clang
            llvmPackages_19.libcxx
            llvmPackages_19.llvm
            rustc
            cargo
            icu
            darwin.apple_sdk.frameworks.CoreFoundation
            darwin.apple_sdk.frameworks.Security
            sqlite
            apple-sdk_13
            darwin.cctools
          ];

          shellHook = ''
            export CPLUS_INCLUDE_PATH="${pkgs.llvmPackages_19.libcxx}/include/c++/v1:${pkgs.icu.dev}/include:$CPLUS_INCLUDE_PATH"
            export C_INCLUDE_PATH="${pkgs.icu.dev}/include:$C_INCLUDE_PATH"
            export LIBRARY_PATH="${pkgs.llvmPackages_19.libcxx}/lib:${pkgs.icu.out}/lib:$LIBRARY_PATH"
            export PATH="${pkgs.llvmPackages_19.llvm}/bin:${pkgs.darwin.cctools}/bin:$PATH"
            export CMAKE_OSX_DEPLOYMENT_TARGET=13.0
            export CMAKE_OSX_ARCHITECTURES="arm64"
            export CMAKE_OSX_SYSROOT="${pkgs.apple-sdk_13.passthru.sdkroot}"
            export CC="${pkgs.llvmPackages_19.clang}/bin/clang"
            export CXX="${pkgs.llvmPackages_19.clang}/bin/clang++"
            export CMAKE_C_COMPILER="${pkgs.llvmPackages_19.clang}/bin/clang"
            export CMAKE_CXX_COMPILER="${pkgs.llvmPackages_19.clang}/bin/clang++"
            export CMAKE_CXX_FLAGS="-stdlib=libc++ -std=c++17"
            export CMAKE_EXE_LINKER_FLAGS="-Wl,-search_paths_first -Wl,-headerpad_max_install_names -dead_strip -dead_strip_dylibs -Wl,-no_compact_unwind -Wl,-no_new_main"
            export LDFLAGS="-Wl,-search_paths_first -Wl,-headerpad_max_install_names -dead_strip -dead_strip_dylibs -Wl,-no_compact_unwind -Wl,-no_new_main"
            export MACOSX_DEPLOYMENT_TARGET=13.0
            export CMAKE_LINKER="${pkgs.darwin.cctools}/bin/ld"
            export CMAKE_AR="${pkgs.llvmPackages_19.llvm}/bin/llvm-ar"
            export CMAKE_RANLIB="${pkgs.llvmPackages_19.llvm}/bin/llvm-ranlib"
            export CMAKE_NM="${pkgs.llvmPackages_19.llvm}/bin/llvm-nm"
            export CMAKE_POLICY_DEFAULT_CMP0056=NEW
            export CMAKE_POLICY_DEFAULT_CMP0025=NEW
            export CMAKE_POLICY_DEFAULT_CMP0077=NEW
            export CMAKE_GENERATOR=Ninja
            export CMAKE_MAKE_PROGRAM="${pkgs.ninja}/bin/ninja"
            export CMAKE_BUILD_TYPE=Debug
            export CMAKE_EXPORT_COMPILE_COMMANDS=ON
            export CMAKE_COLOR_DIAGNOSTICS=ON
            export CMAKE_SYSTEM_NAME=Darwin
            export CMAKE_SYSTEM_PROCESSOR=arm64
            export CMAKE_SYSTEM_VERSION=13.0
            export CMAKE_APPLE_SILICON_PROCESSOR=arm64
            export CMAKE_CROSSCOMPILING=OFF
            export CMAKE_FIND_ROOT_PATH_MODE_PROGRAM=NEVER
            export CMAKE_FIND_ROOT_PATH_MODE_LIBRARY=ONLY
            export CMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY
            export CMAKE_FIND_ROOT_PATH_MODE_PACKAGE=ONLY
            export CMAKE_POSITION_INDEPENDENT_CODE=ON
            export CMAKE_SKIP_RPATH=OFF
            export CMAKE_SKIP_INSTALL_RPATH=OFF
            export CMAKE_BUILD_WITH_INSTALL_RPATH=ON
            export CMAKE_INSTALL_RPATH_USE_LINK_PATH=ON
            export CMAKE_MACOSX_RPATH=ON
            export LDFLAGS_OVERRIDE="-Wl,-search_paths_first -Wl,-headerpad_max_install_names -dead_strip -dead_strip_dylibs -Wl,-no_compact_unwind -Wl,-no_new_main"
            export LDFLAGS_EXTRA="-Wl,-no_new_main"
            export BUN_FORCE_LINKER_FLAGS=1
          '';
        };
      }
    );
}
