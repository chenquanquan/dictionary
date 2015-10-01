#!/usr/bin/perl
# word counter
#
use warnings;
use strict;
# Search chinese
use Encode;

my $FILE_NAME = $ARGV[0];
my %WORD;
my $file;

$file = $FILE_NAME;
open my $filp, "<", $file
    or die "Cannot read $file: $!";

    my $tline;
    my $word;
    while ($tline=<$filp>) { 
        #while ( /(\b[^\W_\d][\w'-]+\b)/g ) {$seen{$1}++;};
        while ($tline =~ m/([a-z-]+)/ig) {
            $word = $1;
            #$word =~ s/-//g;
            $WORD{lc($word)}++;
        }
    }
close $filp;


my @key = sort {$WORD{$b} <=> $WORD{$a}} keys %WORD;
foreach (@key) {
    print "$_ - $WORD{$_}\n";
}
