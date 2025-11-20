# media-organising

Collection of scripts to group pictures and videos. These scripts will rename the picture based on the time they were taken. It will rename videos based on the file timestamp.
Files will be stored in a folder structure as follows: `YYYY/YYYY_MM_MMM/YYYY.MM.DD-HH.mm.ss.ms.jpg`

## Setup Options

You can either use Docker (recommended) or install dependencies manually.

### Option 1: Using Docker (Recommended)

The easiest way to use these scripts is with Docker, which handles all dependencies automatically.

#### Prerequisites for Docker

* Docker and Docker Compose installed on your system

#### Docker Setup

1. **Build the Docker image:**

   ```bash
   docker-compose build
   ```

2. **Configure your directories:**

   Edit the `.env` file and update it with your paths:

   ```bash
   # Required directories
   PICTURES_DIR=/path/to/your/pictures
   VIDEOS_DIR=/path/to/your/videos
   DOWNLOADS_DIR=/path/to/your/downloads

   # Optional directories
   SDCARD_DIR=/path/to/sdcard/mount
   ```

3. **Run the container:**

   ```bash
   # Interactive mode with help menu
   docker-compose run --rm media-organizer

   # Run specific commands
   docker-compose run --rm media-organizer copy-iphone
   docker-compose run --rm media-organizer copy-camera
   docker-compose run --rm media-organizer copy-videos
   docker-compose run --rm media-organizer group-videos

   # Check mount points
   docker-compose run --rm media-organizer check
   ```

   **Run with Dropbox Pause (Recommended):**

   If you have Dropbox installed and want to pause syncing during operations to avoid conflicts:

   ```bash
   # Use the wrapper script that helps manage Dropbox syncing
   ./run.sh copy-iphone
   ./run.sh copy-camera
   ./run.sh copy-videos
   ./run.sh group-videos

   # Or with no arguments for default action (copy-iphone)
   ./run.sh
   ```

   The wrapper script will:
   * Prompt you to pause Dropbox syncing before operations
   * Run the media organizer in Docker
   * Remind you to resume Dropbox syncing when done

4. **Alternative: Run with docker directly:**

   ```bash
   # Build the image
   docker build -t media-organizer .

   # Run with volume mounts
   docker run -it --rm \
     -v /path/to/pictures:/mnt/pictures \
     -v /path/to/videos:/mnt/videos \
     -v /path/to/downloads:/mnt/downloads \
     media-organizer
   ```

### Option 2: Manual Setup

## Prequisites

* `exif` (`sudo apt install exif`)
* `ffprobe` (`sudo apt install ffmpeg`)
* `heif-convert` (`sudo apt-get install libheif-examples`)
* `perl`
* `File::chdir` (`sudo apt install libfile-chdir-perl`)

You will also need to create the following set of symlinks in the `links` folder

* `pictures` -> where you want to store your pictures
* `videos` -> where you want to store the videos
* `downloads` -> (optional) if you want the scripts to extract `iCloud Photos.zip`, point this to where that file is stored. Generally you Downloads folder.
* `sdcard` -> (optional) if you have an sdcard mounted, this script can copy from there
* `phone` -> (optional) if you have a phone mounted, this script can copy from there

## Usage

If you have created `sdcard` or `phone`, the `copyPictures.pl` and `copyVideos.pl` will copy from there and store in pictures or videos respectively. If you don't have those set up, you can still copy the files manually to pictures or videos and run the scripts to have them group the files.

## Wrappers

If you are running on windows, you will want to make a symlink called `media-organising` in your Linux home directory to this folder (e.g. `ln -s /mnt/c/Users/reid/dev/github/reidlevesque/media-organising media-organising`)

## Important Notes About Videos

If the video files are < 3.5s in duration they will be put in the `Live Photos` folder inside `videos`. Otherwise they will be put in the `Camera` folder inside `videos`.
