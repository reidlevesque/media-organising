#!/bin/bash

# Media Organizer Docker Entrypoint Script

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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

# Check mount points
check_mounts() {
    print_message "Checking mount points..."

    if [ ! -d "/mnt/pictures" ] || [ -z "$(ls -A /mnt/pictures 2>/dev/null)" ]; then
        print_warning "Pictures directory not mounted or empty"
    else
        print_message "✓ Pictures directory mounted"
    fi

    if [ ! -d "/mnt/videos" ] || [ -z "$(ls -A /mnt/videos 2>/dev/null)" ]; then
        print_warning "Videos directory not mounted or empty"
    else
        print_message "✓ Videos directory mounted"
    fi

    if [ -d "/mnt/downloads" ] && [ ! -z "$(ls -A /mnt/downloads 2>/dev/null)" ]; then
        print_message "✓ Downloads directory mounted"
    fi

    if [ -d "/mnt/sdcard" ] && [ ! -z "$(ls -A /mnt/sdcard 2>/dev/null)" ]; then
        print_message "✓ SD Card mounted"
    fi

    if [ -d "/mnt/phone" ] && [ ! -z "$(ls -A /mnt/phone 2>/dev/null)" ]; then
        print_message "✓ Phone mounted"
    fi
}

# Function to show available commands
show_help() {
    echo ""
    print_message "Available commands:"
    echo "  copy-iphone    - Copy pictures from iPhone"
    echo "  copy-camera    - Copy pictures from camera"
    echo "  copy-videos    - Copy and organize videos"
    echo "  group-videos   - Group existing videos"
    echo "  check          - Check mount points"
    echo "  help           - Show this help message"
    echo "  bash           - Start bash shell"
    echo ""
    echo "Or run perl scripts directly:"
    echo "  perl /app/src/copyIPhonePictures.pl"
    echo "  perl /app/src/copyCameraPictures.pl"
    echo "  perl /app/src/copyVideos.pl"
    echo "  perl /app/src/groupVideos.pl"
    echo ""
}

# Main logic
if [ $# -eq 0 ]; then
    # No arguments, default to copy-iphone
    print_message "Welcome to Media Organizer!"
    check_mounts
    print_message "Running iPhone picture copy (default action)..."
    exec perl /app/src/copyIPhonePictures.pl
else
    # Process command
    case "$1" in
        copy-iphone)
            check_mounts
            print_message "Running iPhone picture copy..."
            exec perl /app/src/copyIPhonePictures.pl
            ;;
        copy-camera)
            check_mounts
            print_message "Running camera picture copy..."
            exec perl /app/src/copyCameraPictures.pl
            ;;
        copy-videos)
            check_mounts
            print_message "Running video copy..."
            exec perl /app/src/copyVideos.pl
            ;;
        group-videos)
            check_mounts
            print_message "Running video grouping..."
            exec perl /app/src/groupVideos.pl
            ;;
        check)
            check_mounts
            ;;
        help)
            show_help
            ;;
        bash|shell)
            exec /bin/bash
            ;;
        *)
            # Pass through any other command
            exec "$@"
            ;;
    esac
fi