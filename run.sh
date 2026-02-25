#!/bin/bash

# Media Organizer Runner with Dropbox Pause
# This script pauses Dropbox syncing before running media organization tasks
# and resumes it when done

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored messages
print_message() {
    echo -e "${GREEN}[Media Organizer]${NC} $1"
}

print_error() {
    echo -e "${RED}[Error]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[Warning]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[Info]${NC} $1"
}

# Function to prompt for Dropbox pause
pause_dropbox() {
    print_warning "Please pause Dropbox to avoid sync conflicts:"
    echo ""
    echo "  1. Click the Dropbox icon in your menu bar"
    echo "  2. Click the 'Your files are up to date' dropdown at the bottom of the menu"
    echo "  3. Select '1 hour'"
    echo ""
    echo -n "Press Enter when you've paused Dropbox (or Enter to skip): "
    read -r
}

# Function to remind about resuming Dropbox
resume_dropbox() {
    echo ""
    print_warning "Please resume Dropbox syncing:"
    echo "  1. Click the Dropbox icon in your menu bar"
    echo "  2. Click the 'Your files are up to date' dropdown at the bottom of the menu"
    echo "  3. Select 'Resume'"
    echo ""
}

# Main execution
main() {
    # Check if docker-compose is available
    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null 2>&1; then
        print_error "docker-compose not found. Please install Docker Desktop or docker-compose."
        exit 1
    fi

    # Determine docker-compose command (v1 vs v2)
    if docker compose version &> /dev/null 2>&1; then
        DOCKER_COMPOSE="docker compose"
    else
        DOCKER_COMPOSE="docker-compose"
    fi

    # Prompt for Dropbox pause
    pause_dropbox

    # Run docker-compose with all passed arguments
    print_message "Running media organizer..."
    echo ""

    colima start
    $DOCKER_COMPOSE build
    $DOCKER_COMPOSE run --rm media-organizer "$@"
    EXIT_CODE=$?

    echo ""

    # The cleanup function will handle the resume reminder
    if [ $EXIT_CODE -eq 0 ]; then
        print_message "✓ Media organization completed successfully"
        resume_dropbox
    else
        print_error "Media organization failed with exit code $EXIT_CODE"
    fi

    return $EXIT_CODE
}

# Run main function with all arguments
main "$@"
