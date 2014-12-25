#!/usr/bin/env perl
use 5.010;
use strict;
use warnings;

package Audacious2Toc;
use Moose;
use 5.010;
with qw(
    MooseX::Getopt
);
use MooseX::Types::Path::Class;

has 'labels' => (is=>'ro',isa=>'Path::Class::File',required=>1,coerce=>1);
has 'toc' => (is=>'ro',isa=>'Path::Class::File',required=>1,coerce=>1);
has 'wav' => (is=>'ro',isa=>'Str',default=>'mix.wav');

sub run {
    my $self = shift;

    my @raw;
    my $labels = $self->labels->openr;
    while (my $line = <$labels>) {
        chomp($line);
        $line =~s/=s+$//;
        $line =~s/,/./g;
        push(@raw,$line);
    }

    my $wav = $self->wav;
    my @toc='CD_DA';
    for (my $i=0;$i<@raw;$i++) {
        my $start = 0 + $raw[$i];
        last unless $raw[$i +1];
        my $stop = 0 + ($raw[$i + 1] || 4740);
        my $length = $self->time2msf($stop - $start);
        $start = $self->time2msf($start);

        my $count = $i +1;
        push(@toc,<< "EOBLOCK");
// Track $count
TRACK AUDIO
NO COPY
NO PRE_EMPHASIS
TWO_CHANNEL_AUDIO
FILE "$wav" $start $length
EOBLOCK
    }

    my $toc = $self->toc->openw;
    print $toc join("\n",@toc);
}

sub time2msf {
    my ($self, $time) = @_;
    $time=~/^(?<sec>\d+)\.(?<millisec>\d\d)/;

    my $sec = $+{sec};
    my $millisec = $+{millisec};
    my $min = int($sec / 60);
    $sec = $sec - ($min * 60);
    my $frame = int($millisec *.75);
    my $msf = sprintf("%02i:%02i:%02i",$min,$sec,$frame);
    return $msf;
}

package main;
Audacious2Toc->new_with_options->run;


