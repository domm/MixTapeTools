#!/usr/bin/perl
use strict;
use warnings;
use 5.010;
use List::Util qw(shuffle);
use Imager;
use utf8;

my $SIZE = 2672;

my @files;
opendir( my $dir, "." );
while ( my $file = readdir($dir) ) {
    next unless $file =~ /p\d+\.jpg/;
    push( @files, $file );
}

my $font_filename = 'DejaVuSans.ttf';
my $font = Imager::Font->new( file => $font_filename )
    or die "Cannot load $font_filename: ", Imager->errstr;

my $text      = "der mensch gehört auf eine sofagarnitur";
my $text_size = 100;

my $transparent_black = Imager::Color->new( 0, 0, 0, 63 );

my @select = shuffle(@files);
my $size   = @select;
my $max    = int( $size / 2 );
my $i      = 1;
for ( 1 .. $max ) {
    my $left  = shift(@select);
    my $right = get_pair($left);
    say "$left, $right";
    my $l = get_image($left);
    my $r = get_image($right);
    my $combined = Imager->new( xsize => $SIZE * 2, ysize => $SIZE );
    $combined->paste( left => 0,     right => 0, src => $l );
    $combined->paste( left => $SIZE, top   => 0, src => $r );
    $combined->box(
        xmin => $SIZE + ( $SIZE * .1 ),
        ymin => 10,
        xmax => ( $SIZE * 2 ) - ( $SIZE * .1 ),
        ymax => $SIZE * .05,
        fill => { solid => $transparent_black, combine => 'normal' }
    );
    $font->align(
        string => $text,
        size   => $text_size,
        color  => 'white',
        x      => $SIZE + ( $SIZE * .11 ),
        y      => 25,
        halign => 'left',
        valign => 'top',
        image  => $combined
    );

    $combined->write(
        jpegquality => 100,
        file        => sprintf( "combined_%02i.jpg", $i )
    );
    $i++;
}

sub get_pair {
    my $left  = shift;
    my $right = shift(@select);

    $left =~ /p(\d+)/;
    my $left_num = $1;
    $right =~ /p(\d+)/;
    my $right_num = $1;
    my $diff      = $left_num - $right_num;
    $diff = $diff * -1 if $diff < 0;

    if ( $diff > 50 ) {
        return $left, $right;
    }
    push( @select, $right );
    return get_pair($left);
}

sub get_image {
    my $file = shift;
    my $i    = Imager->new;
    $i->read( file => $file );
    my $x = $i->getwidth;
    return $i if $x == $SIZE;

    my $scaled = $i->scale( xpixels => $SIZE );
    return $scaled;
}

