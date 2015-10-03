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

#Place the input entry
my $word_label = $top_frame->Label(-text => 'word')
    ->pack(-expand => 0,
	   -fill => 'x',
	   -side => 'top');

my $word_entry = $top_frame->Scrolled('Entry')
    ->pack(-expand => 0,
	   -fill => 'x',
	   -side => 'bottom');
$word_entry->configure(-textvariable => \$input);

#Place the note text
my $note_frame = $bottom_frame->Frame;
my $frame_note_label = $note_frame->Label(-text => 'note')
    ->pack(-expand => 0,
	   -fill => 'x',
	   -side => 'top');

my $frame_note_text = $note_frame->Scrolled('Text')
    ->pack(-expand => 1,
	   -fill => 'both',
	   -side => 'bottom');
$note_frame->pack(-expand => 1, -fill => 'both', -side => 'left');

#Place the dictionary text
my $dict_frame = $bottom_frame->Frame;
my $frame_dict_label = $dict_frame->Label(-text => 'Dictionary')
    ->pack(-expand => 0,
	   -fill => 'x',
	   -side => 'top');

my $frame_dict_text = $dict_frame->Scrolled('Text')
    ->pack(-expand => 1,
	   -fill => 'both',
	   -side => 'bottom');
$dict_frame->pack(-expand => 1, -fill => 'both', -side => 'right');


$top_frame->pack(-expand => 0, -fill => 'both', -side => 'top');
$bottom_frame->pack(-expand => 1, -fill => 'both', -side => 'bottom');

##
# bind function
#
$word_entry->bind('<Return>' => [\&input_word, 
				 $frame_note_text, 
				 $frame_dict_text, 
				 \$input]);

$MW->MainLoop;

##
# Sub function
#
sub input_word {
    # $entry - Reference to entry widget.
    # $note - Reference to note text widget.
    # $dict - Reference to dictionary text widget.
    # $word - input word.
    my ($entry, $note, $dict, $input) = @_;

    my @display;
    #my $word = &decode('utf-8', $$input);
    my $word = $$input;
    print $$input;
    $note->delete(qw/1.0 end/);
    find_note($word, \@display);
    while (my $key = shift @display) {
        $note->insert('end', $key);
    }

    $dict->delete(qw/1.0 end/);
    find_dict($word, \@display);
    while (my $key = shift @display) {
        $dict->insert('end', $key);
    }
}

sub find_note {
    my ($input, $display) = @_;

    chomp($input);
    # discard empty word
    if ($input !~ m/^[\w\.\-\"\p{Han}]+/) {
        next;
    }

    open (OUTPUT, "./$CMD $NOTE $input |") or die "Can't open ./$CMD $NOTE $input: $!";
    while (my $line = <OUTPUT>) {
#        print "$line"; # add empty for complete double byte charecture.
        push @$display, decode('utf-8', "$line");
    }
    close OUTPUT;
}

sub find_dict {
    my ($input, $display) = @_;

    chomp($input);
    # discard empty word
    if ($input !~ m/^[\w\.\-\"\p{Han}]+/) {
        next;
    }

    open (OUTPUT, "./$CMD $DICT $input |") or die "Can't open ./$CMD $DICT $input: $!";
    while (my $line = <OUTPUT>) {
        push @$display, decode('utf-8', "$line");
    }
    close OUTPUT;
}
