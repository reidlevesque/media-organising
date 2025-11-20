#! /usr/bin/perl -w

use strict;
use File::Basename;
use File::chdir;
use Cwd 'realpath';

my %months = (
    '00' => 'Smarch',
    '01' => 'January',
    '02' => 'February',
    '03' => 'March',
    '04' => 'April',
    '05' => 'May',
    '06' => 'June',
    '07' => 'July',
    '08' => 'August',
    '09' => 'September',
    '10' => 'October',
    '11' => 'November',
    '12' => 'December',
);

sub quit
{
    my $ret = shift;
    exit $ret;
}

sub unzipPics
{
    my $linksDir = shift;
    my $zipFile = shift;
    my $outputDir = shift;

    if (-e "$linksDir/$zipFile") {
        system("unzip \"$linksDir/$zipFile\" -d \"$linksDir/$outputDir\"");
        system("rm \"$linksDir/$zipFile\"");
    }
}

sub copyPics
{
    my $linksDir = shift;
    my $link = shift;

    my @pics = `ls $linksDir/$link`;

    my $res = 0;

    foreach my $pic (@pics)
    {
        chomp $pic;

        my $i = 0;
        my $target = "";
        do {
            $target = "$linksDir/pictures/" . $i . "-" . basename($pic);
            $i += 1;
            if (-e "$target") { print "Found\n" }
        } while (-e "$target");

        $res = system("cp -v \"$pic\" \"$target\"");
        if ($res > 0)
        {
            print "ERROR copying \"$pic\" to laptop.\n";
            quit(1);
        }

        # Ensure the copied file has proper permissions for verification
        system("chmod 644 \"$target\" 2>/dev/null");

        # Get source MD5 with error checking
        my $sourceMd5 = `md5sum \"$pic\" 2>&1 | cut -d ' ' -f 1`;
        chomp $sourceMd5;
        if ($sourceMd5 =~ /Permission denied|No such file/)
        {
            print "ERROR: Cannot read source file for verification: $pic\n";
            print "Error details: $sourceMd5\n";
            quit(4);
        }

        # Get target MD5 with error checking
        my $targetMd5 = `md5sum \"$target\" 2>&1 | cut -d ' ' -f 1`;
        chomp $targetMd5;
        if ($targetMd5 =~ /Permission denied|No such file/)
        {
            print "ERROR: Cannot read copied file for verification: $target\n";
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
            print "ERROR: Copied picture does not match picture on memory card, please try again\n";
            print "$pic: $sourceMd5\n";
            print "$target: $targetMd5\n";
            quit(2);
        }

        $res = system("rm -f \"$pic\"");
        if ($res > 0)
        {
            print "ERROR removing $pic from memory card.\n";
            quit(3);
        }
    }
}

sub groupPics
{
    my $outputSubDir = shift;
    my $searchSuffix = shift;
    my $suffix = shift;

    my @pics = `ls --quoting-style=c ./*.$searchSuffix`;

    foreach my $pic (@pics)
    {
        chomp $pic;
        my $year = '0000';
        my $month = '00';
        my $day = '00';
        my $hour = '00';
        my $min = '00';
        my $sec = '00';

        my @exif = `exif $pic 2>/dev/null`;
        foreach my $line (@exif)
        {
            chomp $line;
            if ($line =~ /^Date and Time \(Ori.*\|(\d\d\d\d):(\d\d):(\d\d)\s(\d\d):(\d\d):(\d\d).*$/)
            {
                $year = $1;
                $month = $2;
                $day = $3;
                $hour = $4;
                $min = $5;
                $sec = $6;
            }
        }

	    if ($year == '0000')
	    {
            my @stat = `stat -c %y $pic`;
            foreach my $line (@stat)
            {
                chomp $line;

                if ($line =~ /^(\d\d\d\d)-(\d\d)-(\d\d)\s(\d\d):(\d\d):(\d\d).*$/)
                {
                    $year = $1;
                    $month = $2;
                    $day = $3;
                    $hour = $4;
                    $min = $5;
                    $sec = $6;
                }
            }
        }

        my $picDir = "$outputSubDir/$year/$year\_$month-$months{$month}";
        system("mkdir -p $picDir");

        my $picPrefix = "$year.$month.$day-$hour.$min.$sec";

        my $i = 0;
        my $newPic = "";
        do {
            $newPic = "$picPrefix-$i.$suffix";
            $i += 1;
        } while (-f "$picDir/$newPic");

	    system("mv -v $pic $picDir/$newPic");
    }
}

### MAIN ###

my $srcDir = dirname(realpath($0));
my $linksDir = dirname($srcDir) . '/links';

copyPics($linksDir, 'sdcard/DCIM/*/*.[jJ][pP][gG]');
chdir("$linksDir/pictures");
groupPics('.', '[jJ][pP][gG]', 'jpg');

print "SUCCESS\n";
quit(0);
