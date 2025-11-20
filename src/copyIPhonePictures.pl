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

    my @pics = glob("$linksDir/$link");

    my $res = 0;

    foreach my $pic (@pics)
    {

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

sub copyVids
{
    my $linksDir = shift;
    my $link = shift;

    my @vids = glob("$linksDir/$link");

    my $res = 0;

    foreach my $vid (@vids)
    {

        my $i = 0;
        my $target = "";
        do {
            $target = "$linksDir/videos/" . $i . "-" . basename($vid);
            $i += 1;
            if (-e "$target") { print "Found\n" }
        } while (-e "$target");

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
            print "ERROR: Copied vid does not match vid on memory card, please try again\n";
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

sub convertPics
{
    my $picsDir = shift;
    my $searchSuffix = shift;
    my $suffix = shift;

    my @pics = glob("$picsDir/*.$searchSuffix");

    foreach my $pic (@pics)
    {
        my $convertedPic = $pic;
        $convertedPic =~ s/$searchSuffix/$suffix/g;

        system("heif-convert \"$pic\" \"$convertedPic\"");
        system("rm \"$pic\"");
    }
}

sub parsePic
{
    my $pic = shift;

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

    my $subDir = "$year/$year\_$month-$months{$month}";
    my $filePrefix = "$year.$month.$day-$hour.$min.$sec";

    return ($subDir, $filePrefix)
}

sub groupLivePics
{
    my $picsInputDir = shift;
    my $vidsInputDir = shift;
    my $picsOutputDir = shift;
    my $vidsOutputDir = shift;
    my $searchSuffix = shift;
    my $picSuffix = shift;
    my $vidSuffix = shift;

    my @pics = glob("$picsInputDir/*.$searchSuffix");

    foreach my $pic (@pics)
    {

        my ($subDir, $filePrefix) = &parsePic($pic);

        my $picDir = "$picsOutputDir/$subDir";
        system("mkdir -p $picDir");
        my $i = 0;
        my $newPic = "";
        do {
            $newPic = "$filePrefix-$i.$picSuffix";
            $i += 1;
        } while (-f "$picDir/$newPic");
	    system("mv -v $pic $picDir/$newPic");

        my $vid = $pic;
        $vid =~ s/$picsInputDir/$vidsInputDir/g;
        $vid =~ s/\.$picSuffix/.$vidSuffix/g;
        my $vidDir = "$vidsOutputDir/$subDir";
        system("mkdir -p $vidDir");
        $i = 0;
        my $newVid = "";
        do {
            $newVid = "$filePrefix-$i.$vidSuffix";
            $i += 1;
        } while (-f "$vidDir/$newVid");

        if (-f $vid) {
            system("mv -v $vid $vidDir/$newVid");
        }
    }
}

sub groupPics
{
    my $inputDir = shift;
    my $outputDir = shift;
    my $searchSuffix = shift;
    my $suffix = shift;

    my @pics = glob("$inputDir/*.$searchSuffix");

    foreach my $pic (@pics)
    {

        my ($subDir, $filePrefix) = &parsePic($pic);

        my $picDir = "$outputDir/$subDir";
        system("mkdir -p $picDir");
        my $i = 0;
        my $newPic = "";
        do {
            $newPic = "$filePrefix-$i.$suffix";
            $i += 1;
        } while (-f "$picDir/$newPic");
	    system("mv -v $pic $picDir/$newPic");
    }
}

sub groupVids
{
    my $inputDir = shift;
    my $outputDir = shift;
    my $searchSuffix = shift;
    my $suffix = shift;

    my @vids = glob("$inputDir/*.$searchSuffix");

    foreach my $vid (@vids)
    {
        my $year = '0000';
        my $month = '00';
        my $day = '00';
        my $hour = '00';
        my $min = '00';
        my $sec = '00';

        my @stat = `stat -c %y $vid`;
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

        my $vidDir = "$outputDir/$year/$year\_$month-$months{$month}";
        system("mkdir -p $vidDir");

        my $vidPrefix = "$year.$month.$day-$hour.$min.$sec";

        my $i = 0;
        my $newVid = "";
        do {
            $newVid = "$vidPrefix-$i.$suffix";
            $i += 1;
        } while (-f "$vidDir/$newVid");

        system("mv -v $vid $vidDir/$newVid");
    }
}

### MAIN ###

my $srcDir = dirname(realpath($0));
my $linksDir = dirname($srcDir) . '/links';

unzipPics($linksDir, 'downloads/iCloud Photos.zip', 'phone');

copyPics($linksDir, 'phone/*/*.[hH][eE][iI][cC]');
copyPics($linksDir, 'phone/*/*.[pP][nN][gG]');
copyPics($linksDir, 'phone/*/*.[jJ][pP][gG]');
copyPics($linksDir, 'phone/*/*.[jJ][pP][eE][gG]');
copyVids($linksDir, 'phone/*/*.[mM][oO][vV]');

convertPics("$linksDir/pictures", '[hH][eE][iI][cC]', 'jpg');

groupLivePics("$linksDir/pictures", "$linksDir/videos", "$linksDir/pictures", "$linksDir/videos/Phone", '[jJ][pP][gG]', 'jpg', 'mov');
groupPics("$linksDir/pictures", "$linksDir/pictures/Screenshots", '[pP][nN][gG]', 'png');
groupPics("$linksDir/pictures", "$linksDir/pictures", '[jJ][pP][eE][gG]', 'jpg');
groupVids("$linksDir/videos", "$linksDir/videos/Phone", '[mM][oO][vV]', 'mov');

print "SUCCESS\n";
quit(0);
