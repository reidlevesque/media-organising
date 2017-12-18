#! /usr/bin/perl -w

use strict;

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

sub groupPics
{
    my $inputDir = shift;
    my $outputDir = shift;
    my $searchSuffix = shift;
    my $suffix = shift;

    my @pics = `ls --quoting-style=c $inputDir/*.$searchSuffix`;

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
           
        my $picDir = "$outputDir/$year/$year\_$month-$months{$month}";
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

my $inputDir = shift;

groupPics($inputDir, $inputDir, '[jJ][pP][gG]', 'jpg');
groupPics($inputDir, "$inputDir/Screenshots", '[pP][nN][gG]', 'png');
