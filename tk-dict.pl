#!/usr/bin/env perl 
use strict;
use warnings;
use utf8;

use Encode;
use File::Spec::Functions;

use Tk;
use Tk::Dialog;
use Tk::MsgBox;

my $CMD="words.pl";
my $NOTE="english.txc";
my $DICT="new_dictionary.txc";
my $TABLE_DIR="table";

my $input;
##
# Draw frame
#
my $MW = MainWindow->new(-title => "English dictionary");
my $TOP = $MW->Frame;
my $top_frame = $MW->Frame
    ->pack(-expand => 0, -fill => 'both', -side => 'top');
my $bottom_frame = $MW->Frame
    ->pack(-expand => 1, -fill => 'both', -side => 'bottom');

#Place the input entry
my $input_frame = $top_frame->Frame;
my $word_label = $input_frame->Label(-text => 'word')
    ->pack(-expand => 0,
	   -fill => 'x',
	   -side => 'top');
my $word_entry = $input_frame->Entry(-textvariable => \$input)
    ->pack(-expand => 0,
	   -fill => 'x',
	   -side => 'bottom');
$input_frame ->pack(-expand => 1,
		    -fill => 'x',
		    -side => 'left');

#Place the button frame
my $button_frame = $top_frame->Frame
    ->pack(-expand => 0, -side => 'left');
my $word_button = $button_frame->Scrolled('Button')
    ->pack(-expand => 0);
$word_button->configure(-text => "Add", -command => [\&add_button, \$MW]);

#Place the note text
my $note_frame = $bottom_frame->Frame
    ->pack(-expand => 1, -fill => 'both', -side => 'left');

my $frame_note_label = $note_frame->Label(-text => 'note')
    ->pack(-expand => 0,
	   -fill => 'x',
	   -side => 'top');

my $frame_note_text = $note_frame->Scrolled('Text')
    ->pack(-expand => 1,
	   -fill => 'both',
	   -side => 'bottom');

#Place the dictionary text
my $dict_frame = $bottom_frame->Frame
    ->pack(-expand => 1, -fill => 'both', -side => 'right');
my $frame_dict_label = $dict_frame->Label(-text => 'Dictionary')
    ->pack(-expand => 0,
	   -fill => 'x',
	   -side => 'top');
my $frame_dict_text = $dict_frame->Scrolled('Text')
    ->pack(-expand => 1,
	   -fill => 'both',
	   -side => 'bottom');

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
    my $word = &encode('utf-8', $$input);
    #my $word = $$input;
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
    # find the word in note
    # $input - find this word
    # $display - display buffer for text
    my ($input, $display) = @_;

    chomp($input);
    # discard empty word
    if ($input !~ m/^[\w\.\-\"\p{Han}\^\$]+/) {
        return;
    }

    open (OUTPUT, "./$CMD $NOTE $input |") or die "Can't open ./$CMD $NOTE $input: $!";
    while (my $line = <OUTPUT>) {
	#        print "$line"; # add empty for complete double byte charecture.
        push @$display, decode('utf-8', "$line");
    }
    close OUTPUT;
}

sub find_dict {
    # find the word in dictionary
    # $input - find this word
    # $display - display buffer for text
    my ($input, $display) = @_;

    chomp($input);
    # discard empty word
    if ($input !~ m/^[\w\.\-\"\p{Han}\^\$]+/) {
        return
    }

    if ($input =~ m/ add /) {
        return
    }

    open (OUTPUT, "./$CMD $DICT $input |") or die "Can't open ./$CMD $DICT $input: $!";
    while (my $line = <OUTPUT>) {
        push @$display, decode('utf-8', "$line");
    }
    close OUTPUT;
}

sub add_button {
    my ($mw) = @_;

    my $box = $$mw->Dialog(-title => "Add new word",
			   -default_button => 'add',
			   -buttons => ['add', 'cancel']);
    my $input_frame = $box->Frame;

    my $left_frame = $input_frame->Frame
	->pack(-expand => 1,
	       -fill => 'x',
	       -side => 'left');
    
    my $right_frame = $input_frame->Frame
	->pack(-expand => 1,
	       -fill => 'x',
	       -side => 'right');
    
    my $word_label = $left_frame->Label(-text => 'new words')
	->pack(-expand => 0,
	       -fill => 'x',
	       -side => 'top');

    my $chinese_label = $right_frame->Label(-text => 'chinese')
	->pack(-expand => 0,
	       -fill => 'x',
	       -side => 'top');

    my $word;
    my $word_text = $left_frame->Entry(-textvariable => \$word)
	->pack(-expand => 1,
	       -fill => 'x',
	       -side => 'bottom');

    my $chinese;
    my $chinese_text = $right_frame->Entry(-textvariable => \$chinese)
	->pack(-expand => 1,
	       -fill => 'x',
	       -side => 'bottom');
    
    $input_frame->pack(-expand => 1, -fill => 'both', -side => 'top');

    if ('add' =~ $box->Show) {
	if (!defined $word || !defined $chinese) {
	    my $warn_box = $$mw->Dialog(-text => 'Not word or chinese!',
					-bitmap => 'warning',
					-title => 'Waring');
	    $warn_box->Show;
	} else {
	    chomp($word);
	    chomp($chinese);
	    # discard empty word
	    if ($word !~ m/^[\w\.\-\"]+/) {
		my $warn_box = $$mw->Dialog(-text => 'Word error!',
					    -bitmap => 'warning',
					    -title => 'Waring');
		$warn_box->Show;
		return;
	    }
	    #Add a new word to note.
	    open (OUTPUT, "./$CMD $NOTE $word add $chinese |")
		or die "Can't open ./$CMD $NOTE $word add $chinese: $!";
	    close OUTPUT;
	}
    }
}
