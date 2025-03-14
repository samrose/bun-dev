# Bun Development Environment Flake

This Nix flake sets up a development environment for building Bun, providing all necessary dependencies on both macOS and Linux platforms.

## Prerequisites

- [Nix Package Manager](https://nixos.org/download.html) with flakes enabled
- On macOS: [Homebrew](https://brew.sh/) (for some additional dependencies like icu4c)

### Enabling Flakes

Add the following to your Nix configuration (`~/.config/nix/nix.conf` or `/etc/nix/nix.conf`):

```conf
experimental-features = nix-command flakes
```

## Usage

### Quick Start

To enter the development shell:

```bash
nix develop
```

### Without Flakes

If you're not using flakes, you can still use this environment through the included `shell.nix`:

```bash
nix-shell
```

## Included Development Tools

The development environment includes:

- LLVM 18 (clang, llvm, lld)
- CMake
- Python 3
- npm
- Go
- Automake
- Libtool
- Ninja
- pkg-config
- Rust (rustc and cargo)
- Git
- esbuild
- ccache

### Platform-Specific Tools

#### macOS
- Security Framework
- CoreServices Framework
- CoreFoundation Framework
- Foundation Framework
- cctools (for dsymutil)
- libiconv

## Environment Configuration

The development shell automatically:

- Sets `CC` and `CXX` to use LLVM 18
- Adds local `node_modules/.bin` to PATH
- Configures pkg-config paths on macOS
- Sets appropriate macOS deployment target (10.14)

## Notes

- Some dependencies on macOS may need to be installed through Homebrew
- The flake ensures compatibility with both x86_64 and ARM architectures
- PKG_CONFIG_PATH is configured to find both Homebrew and system libraries on macOS

## Troubleshooting

### Common Issues

1. If you see "error: experimental feature 'nix-command' is disabled":
   ```bash
   mkdir -p ~/.config/nix
   echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
   ```

2. On macOS, if you encounter missing library errors:
   ```bash
   brew install icu4c
   ```

### Updating Dependencies

To update to the latest dependencies:

```bash
nix flake update
```

## Contributing

Feel free to submit issues and enhancement requests!