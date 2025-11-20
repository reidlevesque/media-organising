# Use Ubuntu as base image for better package availability
FROM ubuntu:24.04

# Set non-interactive mode for apt
ENV DEBIAN_FRONTEND=noninteractive

# Update package list and install required dependencies
RUN apt-get update && apt-get install -y \
    # Core utilities
    perl \
    # EXIF tools for image metadata
    exif \
    libimage-exiftool-perl \
    # FFmpeg for video processing
    ffmpeg \
    # Required for adding PPA
    software-properties-common \
    # Perl modules
    libfile-chdir-perl \
    # Additional useful utilities
    file \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Add the strukturag PPA for updated libheif and install HEIF tools
# This fixes iOS 18 HEIC metadata issues
RUN add-apt-repository ppa:strukturag/libheif -y && \
    apt-get update && \
    apt-get install -y \
    libheif-examples \
    libheif1 \
    heif-gdk-pixbuf \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy the scripts
COPY src/*.pl /app/src/

# Copy the entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/entrypoint.sh

# Make scripts executable
RUN chmod +x /app/src/*.pl && \
    chmod +x /usr/local/bin/entrypoint.sh

# Create mount point directories
RUN mkdir -p /app/links && \
    mkdir -p /mnt/pictures && \
    mkdir -p /mnt/videos && \
    mkdir -p /mnt/downloads && \
    mkdir -p /mnt/sdcard && \
    mkdir -p /tmp/phone && \
    chmod 777 /tmp/phone

# Create symbolic links to mount points
RUN ln -s /mnt/pictures /app/links/pictures && \
    ln -s /mnt/videos /app/links/videos && \
    ln -s /mnt/downloads /app/links/downloads && \
    ln -s /mnt/sdcard /app/links/sdcard && \
    ln -s /tmp/phone /app/links/phone

# Set the entrypoint to our custom script
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
