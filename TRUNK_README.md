# Trunk for Swift iOS Development

This project now includes a Trunk-like development workflow for Swift iOS development, similar to how Trunk works for Rust WASM projects.

## What is Trunk?

Trunk is a build tool for Rust WASM applications that provides:
- **Build**: Compile your application
- **Watch**: Automatically rebuild when files change
- **Serve**: Launch a development server

This setup provides similar functionality for Swift iOS development.

## Setup

The following files have been added to your project:

- `Trunk.toml` - Configuration file (similar to Trunk's config)
- `trunk-swift.sh` - Main build script with Trunk-like commands
- `trunk` - Wrapper script for easy access

## Usage

You can now use Trunk-like commands for your Swift project:

### Build the project
```bash
./trunk build
```

### Watch for changes and rebuild automatically
```bash
./trunk watch
```

### Serve the project (launch simulator)
```bash
./trunk serve
```

### Run the app in simulator
```bash
./trunk run
```

### Clean build artifacts
```bash
./trunk clean
```

### Check setup
```bash
./trunk check
```

### Show help
```bash
./trunk help
```

## Features

### Build
- Cleans the build directory
- Builds the project using `xcodebuild`
- Provides colored output and status messages

### Watch
- Monitors Swift files, XIB files, and Storyboard files for changes
- Automatically rebuilds when changes are detected
- Uses `fswatch` for file watching (installs automatically if needed)

### Serve
- Builds the project
- Launches iOS Simulator
- Shows available simulators
- Opens the Simulator app

### Run
- Builds and serves the project
- Prepares for running in simulator

### Clean
- Cleans Xcode build artifacts
- Removes derived data for the project

### Check
- Verifies that all dependencies are installed
- Checks that the Xcode project and scheme exist
- Validates the setup before attempting to build

## Configuration

You can modify the `Trunk.toml` file to customize:
- Build target and scheme
- Watch paths and ignore patterns
- Serve configuration

## Dependencies

The script automatically checks for and installs required dependencies:
- `xcodebuild` (from Xcode Command Line Tools)
- `xcrun` (from Xcode Command Line Tools)
- `fswatch` (installed via Homebrew if needed)

## Comparison with Trunk for Rust

| Trunk (Rust) | Trunk-Swift (iOS) |
|--------------|-------------------|
| `trunk build` | `./trunk build` |
| `trunk watch` | `./trunk watch` |
| `trunk serve` | `./trunk serve` |
| `trunk clean` | `./trunk clean` |
| `trunk check` | `./trunk check` |

## Tips

1. **Development Workflow**: Use `./trunk watch` during development for automatic rebuilds
2. **Testing**: Use `./trunk serve` to quickly launch the simulator
3. **Clean Builds**: Use `./trunk clean` when you encounter build issues
4. **Integration**: You can integrate this into your CI/CD pipeline using the build command

## Troubleshooting

### Build fails
- Run `./trunk clean` to clean build artifacts
- Check that Xcode Command Line Tools are installed
- Verify the project scheme and target in `Trunk.toml`

### Watch not working
- Ensure `fswatch` is installed: `brew install fswatch`
- Check that the watch paths in `Trunk.toml` are correct

### Simulator issues
- Make sure Xcode is installed and up to date
- Try running `xcrun simctl list devices` to see available simulators 