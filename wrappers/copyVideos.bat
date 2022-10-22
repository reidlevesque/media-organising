@echo off

set c=N
set /P c=Do you need to mount the SD Card (Y/[N])?
if /I "%c%" EQU "Y" goto :sdcard
::else
bash --login -i -c "$HOME/media-organising/src/copyVideos.pl"
exit /b

:sdcard
bash --login -i -c "sudo mount -t drvfs F: /mnt/f; $HOME/media-organising/src/copyVideos.pl; sudo umount /mnt/f"
