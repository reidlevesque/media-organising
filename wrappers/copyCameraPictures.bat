@echo off

bash --login -i -c "sudo mount -t drvfs F: /mnt/f; $HOME/media-organising/src/copyCameraPictures.pl; sudo umount /mnt/f"
