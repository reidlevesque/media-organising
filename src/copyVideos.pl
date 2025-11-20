#! /usr/bin/perl -w

use strict;
use File::Basename;
use Cwd 'realpath';

sub quit
{
    my $ret = shift;
    exit $ret;
}

sub unzipVids
{
    my $linksDir = shift;
    my $zipFile = shift;
    my $outputDir = shift;

    if (-e "$linksDir/$zipFile") {
        system("unzip \"$linksDir/$zipFile\" -d \"$linksDir/$outputDir\"");
        system("rm \"$linksDir/$zipFile\"");
    }
}

sub copyCameraVids
{
    my $linksDir = shift;
    my $link = shift;

    my @vids = `ls $linksDir/$link`;

    my $res = 0;

    foreach my $vid (@vids)
    {
        chomp $vid;

        my $target = "$linksDir/videos/" . basename($vid);
        $res = system("cp -v \"$vid\" \"$target\"");
        if ($res > 0)
        {
            print "ERROR copying $vid to laptop.\n";
            quit(1);
        }

        # Ensure the copied file has proper permissions for verification
        system("chmod 644 \"$target\" 2>/dev/null");

        # Get source MD5 with error checking
        my $sourceMd5 = `md5sum \"$vid\" 2>&1 | cut -d ' ' -f 1`;
        chomp $sourceMd5;
        if ($sourceMd5 =~ /Permission denied|No such file/)
        {
            print "ERROR: Cannot read source video for verification: $vid\n";
            print "Error details: $sourceMd5\n";
            quit(4);
        }

        # Get target MD5 with error checking
        my $targetMd5 = `md5sum \"$target\" 2>&1 | cut -d ' ' -f 1`;
        chomp $targetMd5;
        if ($targetMd5 =~ /Permission denied|No such file/)
        {
            print "ERROR: Cannot read copied video for verification: $target\n";
            print "Error details: $targetMd5\n";
            print "Attempting to fix permissions and retry...\n";

            # Try to fix permissions more aggressively
            system("chmod 666 \"$target\" 2>/dev/null");

            # Retry the md5sum
            $targetMd5 = `md5sum \"$target\" 2>&1 | cut -d ' ' -f 1`;
            chomp $targetMd5;

            if ($targetMd5 =~ /Permission denied|No such file/)
            {
                print "ERROR: Still cannot read file after permission fix\n";
                quit(5);
            }
        }

        if ($sourceMd5 ne $targetMd5)
        {
            print "ERROR: Copied vidture does not match vidture on memory card, please try again\n";
            print "$vid: $sourceMd5\n";
            print "$target: $targetMd5\n";
            quit(2);
        }

        $res = system("rm -f \"$vid\"");
        if ($res > 0)
        {
            print "ERROR removing $vid from memory card.\n";
            quit(3);
        }
    }
}

### MAIN ###

my $srcDir = dirname(realpath($0));
my $linksDir = dirname($srcDir) . '/links';

unzipVids($linksDir, 'downloads/iCloud Photos.zip', 'phone');

copyCameraVids($linksDir, 'sdcard/DCIM/*/*.[mM][oO][vV]');
copyCameraVids($linksDir, 'sdcard/DCIM/*/*.[mM][pP]4');
copyCameraVids($linksDir, 'phone/*/*.[mM][oO][vV]');
copyCameraVids($linksDir, 'phone/*/*.[mM][pP]4');

my $res = system("$srcDir/groupVideos.pl $linksDir/videos");
if ($res > 0)
{
    print "ERROR grouping camera videos.\n";
    quit(4);
}

print "SUCCESS\n";
quit(0);
