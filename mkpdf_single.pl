#!/usr/bin/env perl
use 5.010;
use strict;
use warnings;
use PDF::Create;

my $image_dir = $ARGV[0] || '.';
opendir( my $dh, $image_dir ) || die "Cannot read dir $image_dir: $!";

while ( my $file = readdir($dh) ) {
    next unless $file =~ /combined_(\d+).*jpg$/;
    my $num = $1;
    my $pdf = PDF::Create->new( 'filename' => 'cover_' . $num . '.pdf' );
    my $pdf_format   = $pdf->get_page_size('A4L');
    my $pdf_page     = $pdf->new_page( 'MediaBox' => $pdf_format );
    my $path         = $image_dir . '/' . $file;
    my $img          = $pdf->image($path);
    my $current_page = $pdf_page->new_page;
    $current_page->image(
        image  => $img,
        xpos   => 81,
        ypos   => 127,
        xscale => 0.1273,
        yscale => 0.1273
    );
    $pdf->close;
}

