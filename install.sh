#!/bin/bash
# Ralph Installation Script
# 
# Installs Ralph into an existing project by copying the .ralph/ directory
# from the Ralph repository.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/mjeffe/ralph/main/install.sh | bash
#   wget -qO- https://raw.githubusercontent.com/mjeffe/ralph/main/install.sh | bash

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
RALPH_REPO="git@github.com:mjeffe/ralph.git"
RALPH_BRANCH="main"
TEMP_DIR=""

# Helper functions
error() {
    echo -e "${RED}✗ Error: $1${NC}" >&2
    cleanup
    exit 1
}

warn() {
    echo -e "${YELLOW}⚠ Warning: $1${NC}" >&2
}

info() {
    echo -e "${GREEN}✓ $1${NC}"
}

step() {
    echo -e "${BLUE}→ $1${NC}"
}

cleanup() {
    if [ -n "$TEMP_DIR" ] && [ -d "$TEMP_DIR" ]; then
        step "Cleaning up temporary files..."
        rm -rf "$TEMP_DIR"
    fi
}

# Trap to ensure cleanup on exit
trap cleanup EXIT

# Check prerequisites
check_prerequisites() {
    step "Checking prerequisites..."
    
    # Check if git is available
    if ! command -v git &> /dev/null; then
        error "git is not installed. Please install git first."
    fi
    
    # Check if we're in a git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        error "Not in a git repository. Please run 'git init' first or cd to your project root."
    fi
    
    # Check if .ralph/ already exists
    if [ -d ".ralph" ]; then
        error ".ralph/ directory already exists. Ralph may already be installed.\nIf you want to reinstall, remove .ralph/ first: rm -rf .ralph/"
    fi
    
    info "Prerequisites check passed"
}

# Clone Ralph repository to temp directory
clone_ralph() {
    step "Fetching Ralph from GitHub..."
    
    # Create temp directory
    TEMP_DIR=$(mktemp -d)
    
    # Clone Ralph repository
    if ! git clone --depth 1 --branch "$RALPH_BRANCH" "$RALPH_REPO" "$TEMP_DIR" 2>&1 | grep -v "Cloning into"; then
        error "Failed to clone Ralph repository. Check your internet connection."
    fi
    
    info "Ralph repository fetched"
}

# Copy .ralph/ directory to current project
install_ralph() {
    step "Installing Ralph..."
    
    # Copy .ralph/ directory
    if [ ! -d "$TEMP_DIR/.ralph" ]; then
        error "Invalid Ralph repository structure: .ralph/ directory not found"
    fi
    
    cp -r "$TEMP_DIR/.ralph" .
    
    # Make ralph script executable
    chmod +x .ralph/ralph
    chmod +x .ralph/loop.sh
    
    # Update installation date in .ralph-version
    if [ -f ".ralph/.ralph-version" ]; then
        sed -i "s/INSTALLED_DATE=PLACEHOLDER/INSTALLED_DATE=$(date -u +%Y-%m-%d)/" .ralph/.ralph-version
    fi
    
    info "Ralph installed to .ralph/"
}

# Display success message and next steps
show_success() {
    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}  Ralph installed successfully!${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "Next steps:"
    echo ""
    echo "  1. Initialize Ralph in your project:"
    echo -e "     ${BLUE}.ralph/ralph init${NC}"
    echo ""
    echo "  2. (Optional) Create a convenience symlink:"
    echo -e "     ${BLUE}ln -s .ralph/ralph ralph${NC}"
    echo -e "     Then you can run: ${BLUE}./ralph${NC}"
    echo ""
    echo "  3. Read the documentation:"
    echo -e "     ${BLUE}.ralph/docs/README.md${NC}"
    echo ""
    echo "  4. Create your first specification:"
    echo -e "     ${BLUE}specs/my-feature.md${NC}"
    echo ""
    echo "  5. Start the build loop:"
    echo -e "     ${BLUE}.ralph/ralph${NC}"
    echo ""
    echo -e "Documentation: ${BLUE}.ralph/docs/${NC}"
    echo -e "Version: $(grep RALPH_VERSION .ralph/.ralph-version | cut -d= -f2)"
    echo ""
}

# Main installation flow
main() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  Ralph Installation${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    check_prerequisites
    clone_ralph
    install_ralph
    show_success
}

# Run installation
main
