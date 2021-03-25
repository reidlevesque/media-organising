# media-organising

Collection of scripts to group pictures and videos. These scripts will rename the picture based on the time they were taken. It will rename videos based on the file timestamp.
Files will be stored in a folder structure as follows: `YYYY/YYYY_MM_MMM/YYYY.MM.DD-HH.mm.ss.ms.jpg`

## Prequisites

* `exif` (`sudo apt install exif`)
* `ffprobe` (`sudo apt install ffmpeg`)
* `heif-convert` (`sudo apt-get install libheif-examples`)
* `perl`
* `File::chdir` (`sudo apt install libfile-chdir-perl`)

You will also need to create the following set of symlinks in the `links` folder

* `pictures` -> where you want to store your pictures
* `videos` -> where you want to store the videos
* `sdcard` -> (optional) if you have an sdcard mounted, this script can copy from there
* `phone` -> (optional) if you have a phone mounted, this script can copy from there

## Usage

If you have created `sdcard` or `phone`, the `copyPictures.pl` and `copyVideos.pl` will copy from there and store in pictures or videos respectively. If you don't have those set up, you can still copy the files manually to pictures or videos and run the scripts to have them group the files.

## Wrappers

If you are running on windows, you will want to make a symlink called `media-organising` in your Linux home directory to this folder (e.g. `ln -s /mnt/c/Users/reid/dev/github/reidlevesque/media-organising media-organising`)

## Important Notes About Videos

If the video files are < 3.5s in duration they will be put in the `Live Photos` folder inside `videos`. Otherwise they will be put in the `Camera` folder inside `videos`.
