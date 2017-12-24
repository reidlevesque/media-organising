#! /usr/bin/perl -w

use strict;
use File::chdir;

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

my $minVidDuration = 3.5; # in seconds

sub groupVids
{
    my $searchSuffix = shift;
    my $suffix = shift;

    my @vids = `ls --quoting-style=c ./*.$searchSuffix`;

    foreach my $vid (@vids)
    {
        chomp $vid;
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

        my $duration = `ffprobe -i $vid -show_entries format=duration -v quiet -of csv="p=0"`;
        my $outputSubDir = $duration >= $minVidDuration ? 'camera' : 'live_photos';

        my $vidDir = "$outputSubDir/$year/$year\_$month-$months{$month}";
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

my $inputDir = shift;
chdir($inputDir);

groupVids('[aA][vV][iI]', 'avi');
groupVids('[mM][oO][vV]', 'mov');
groupVids('[mM][pP]4', 'mp4');
