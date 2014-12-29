#!/usr/bin/env perl
use 5.010;
use strict;
use warnings;
use Imager;
use Path::Class::Iterator;
use File::Copy;
use Image::ExifTool qw(:Public);

my $dir = Path::Class::Dir->new( shift(@ARGV) || '.' );
my $fishdir = $dir->parent->subdir('is_fish');
$fishdir->mkpath;

my $iterator = Path::Class::Iterator->new(
    root            => $dir,
);
until ($iterator->done) {
    my $f = $iterator->next;
    next if $f->is_dir;
    next unless $f->basename =~ /\.jpg$/i;

    my $info = ImageInfo($f->stringify);
    if ($info->{LensType} ne 'NO-LENS') {
        say "nope, lense ".$f->basename;
        next;
    }

    my $image = Imager->new;
    $image->read(file => $f->stringify);

    my $x= $image->getwidth;
    my $y= $image->getheight();

    if ($x == $y) {
        copy($f->stringify, $fishdir->file($f->basename)->stringify);
        say "square ".$f->basename;
        next;
    }

    my $size = $y;
    my $cropped = $image->crop(width=>$size, height=>$size);
    $cropped->write(file => $fishdir->file($f->basename)->stringify);
    say "cropped ".$f->basename;
}

