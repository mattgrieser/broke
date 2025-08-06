#!/bin/bash

# Trunk-like tool for Swift iOS development
# Provides build, watch, and serve functionality similar to Trunk for Rust WASM

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_NAME="Broke"
SCHEME="Broke"
CONFIGURATION="Debug"
DESTINATION="generic/platform=iOS"
WATCH_PATHS=("Broke/**/*.swift" "Broke/**/*.xib" "Broke/**/*.storyboard")
IGNORE_PATHS=("Broke.xcodeproj/**" "*.xcuserstate" "DerivedData/**")

# Function to print colored output
print_status() {
    echo -e "${GREEN}[TRUNK]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Function to check if required tools are available
check_dependencies() {
    if ! command -v xcodebuild &> /dev/null; then
        print_error "xcodebuild not found. Please install Xcode Command Line Tools."
        exit 1
    fi
    
    if ! command -v xcrun &> /dev/null; then
        print_error "xcrun not found. Please install Xcode Command Line Tools."
        exit 1
    fi
    
    # Check if Xcode is properly installed (not just Command Line Tools)
    if ! xcodebuild -version &> /dev/null; then
        print_error "Xcode is required but not properly installed or configured."
        print_info "Please install Xcode from the App Store and run:"
        print_info "  sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer"
        exit 1
    fi
}

# Function to build the project
build_project() {
    print_status "Building $PROJECT_NAME..."
    
    # Clean build directory
    print_info "Cleaning build directory..."
    xcodebuild clean -project "$PROJECT_NAME.xcodeproj" -scheme "$SCHEME" -configuration "$CONFIGURATION" || true
    
    # Build the project
    print_info "Building project..."
    xcodebuild build -project "$PROJECT_NAME.xcodeproj" -scheme "$SCHEME" -configuration "$CONFIGURATION" -destination "$DESTINATION"
    
    if [ $? -eq 0 ]; then
        print_status "Build completed successfully!"
    else
        print_error "Build failed!"
        exit 1
    fi
}

# Function to watch for file changes and rebuild
watch_project() {
    print_status "Starting watch mode for $PROJECT_NAME..."
    print_info "Watching for changes in: ${WATCH_PATHS[*]}"
    print_info "Press Ctrl+C to stop watching"
    
    # Check if fswatch is available
    if ! command -v fswatch &> /dev/null; then
        print_warning "fswatch not found. Installing via Homebrew..."
        brew install fswatch
    fi
    
    # Build initially
    build_project
    
    # Watch for changes
    fswatch -o "${WATCH_PATHS[@]}" | while read f; do
        print_status "File change detected, rebuilding..."
        build_project
    done
}

# Function to serve the project (launch simulator)
serve_project() {
    print_status "Starting serve mode for $PROJECT_NAME..."
    
    # Build the project first
    build_project
    
    # Get available simulators
    print_info "Available simulators:"
    xcrun simctl list devices available | grep "iPhone\|iPad" | head -10
    
    # Launch simulator and install app
    print_info "Launching simulator..."
    xcrun simctl boot "iPhone 15" 2>/dev/null || xcrun simctl boot "iPhone 14" 2>/dev/null || xcrun simctl boot "iPhone 13" 2>/dev/null
    
    # Open Simulator app
    open -a Simulator
    
    print_status "Simulator launched! You can now run the app from Xcode or use 'trunk-swift run'"
}

# Function to run the app in simulator
run_app() {
    print_status "Running $PROJECT_NAME in simulator..."
    
    # Build the project
    build_project
    
    # Launch simulator
    serve_project
    
    # Install and launch app (this would require more complex setup with proper bundle ID)
    print_info "App built successfully! Open Xcode and run the project to launch in simulator."
}

# Function to clean build artifacts
clean_project() {
    print_status "Cleaning $PROJECT_NAME..."
    
    # Clean Xcode build
    xcodebuild clean -project "$PROJECT_NAME.xcodeproj" -scheme "$SCHEME" -configuration "$CONFIGURATION"
    
    # Remove derived data
    rm -rf ~/Library/Developer/Xcode/DerivedData/*"$PROJECT_NAME"*
    
    print_status "Clean completed!"
}

# Function to check setup
check_setup() {
    print_status "Checking setup for $PROJECT_NAME..."
    
    # Check dependencies
    check_dependencies
    
    # Check if project files exist
    if [ ! -f "$PROJECT_NAME.xcodeproj/project.pbxproj" ]; then
        print_error "Xcode project not found: $PROJECT_NAME.xcodeproj"
        exit 1
    fi
    
    # Check if scheme exists
    if ! xcodebuild -list -project "$PROJECT_NAME.xcodeproj" | grep -q "$SCHEME"; then
        print_error "Scheme '$SCHEME' not found in project"
        print_info "Available schemes:"
        xcodebuild -list -project "$PROJECT_NAME.xcodeproj" | grep -A 10 "Schemes:"
        exit 1
    fi
    
    print_status "Setup check passed! All dependencies and project configuration are correct."
}

# Function to show help
show_help() {
    echo "Trunk-like tool for Swift iOS development"
    echo ""
    echo "Usage: $0 <COMMAND>"
    echo ""
    echo "Commands:"
    echo "  build   Build the Swift iOS app"
    echo "  watch   Build & watch the Swift iOS app for changes"
    echo "  serve   Build, watch & serve the Swift iOS app (launch simulator)"
    echo "  run     Build and run the app in simulator"
    echo "  clean   Clean build artifacts"
    echo "  check   Check if setup is correct"
    echo "  help    Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 build"
    echo "  $0 watch"
    echo "  $0 serve"
}

# Main script logic
main() {
    check_dependencies
    
    case "${1:-help}" in
        build)
            build_project
            ;;
        watch)
            watch_project
            ;;
        serve)
            serve_project
            ;;
        run)
            run_app
            ;;
        clean)
            clean_project
            ;;
        check)
            check_setup
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            print_error "Unknown command: $1"
            show_help
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@" 