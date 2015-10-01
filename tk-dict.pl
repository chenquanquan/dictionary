#!/usr/bin/env perl 
use strict;
use warnings;
use utf8;

use Encode;
use File::Spec::Functions;

use Tk;

my $CMD="words.pl";
my $NOTE="english.txc";
my $DICT="new_dictionary.txc";
my $TABLE_DIR="table";

my $input;
##
# Draw frame
#
my $MW = MainWindow->new;
my $TOP = $MW->Frame;
my $top_frame = $MW->Frame;
my $bottom_frame = $MW->Frame;

my $word_label = $top_frame->Label(-text => 'word')->pack(-expand => 0,
							  -fill => 'x',
							  -side => 'top');

my $word_entry = $top_frame->Scrolled('Entry')->pack(-expand => 0,
						     -fill => 'x',
						     -side => 'bottom');
$word_entry->configure(-textvariable => \$input);


my $frame_label = $bottom_frame->Label(-text => 'Dictionary')->pack(-expand => 0,
								    -fill => 'x',
								    -side => 'top');

my $frame_text = $bottom_frame->Scrolled('Text')->pack(-expand => 1,
						       -fill => 'both',
						       -side => 'bottom');


$top_frame->pack(-expand => 0, -fill => 'both', -side => 'top');
$bottom_frame->pack(-expand => 1, -fill => 'both', -side => 'bottom');

##
# bind function
#
$word_entry->bind('<Return>' => [\&input_word, $frame_text, \$input]);

$MW->MainLoop;

##
# Sub function
#
sub input_word {
    # $entry - Reference to entry widget.
    # $text - Reference to text widget.
    # $word - input word.
    my ($entry, $text, $word) = @_;

    my @display;
    $text->delete(qw/1.0 end/);
    find_dict($$word, \@display);
    while (my $key = shift @display) {
        $text->insert('end', $key);
    }
}

sub find_dict {
    my ($input, $display) = @_;

#    print $$display "input:";
    chomp($input);

    ## Input control
    # discard empty word
    if ($input !~ m/^[\w\.\-\"\p{Han}]+/) {
        next;
    }

    print "$input" . "\n";
    print "=========NOTE=========\n";
    push @$display, "=========NOTE=========\n";
    open (OUTPUT, "./$CMD $NOTE $input |") or die "Can't open ./$CMD $NOTE $input: $!";
    while (my $line = <OUTPUT>) {
        print "$line"; # add empty for complete double byte charecture.
	push @$display, decode('utf-8', "$line");
    }
    close OUTPUT;
    print "\n";
    if ($input !~ m/ add /) {
        print "=======DICTIONARY=====\n";
	push @$display, "=======DICTIONARY=====\n";
        open (OUTPUT, "./$CMD $DICT $input |") or die "Can't open ./$CMD $DICT $input: $!";
        while (my $line = <OUTPUT>) {
            print "$line"; # add empty for complete double byte charecture.
	    push @$display, decode('utf-8', "$line");
        }
        close OUTPUT;
        print "\n";
    }
    print "======================\n";
}
