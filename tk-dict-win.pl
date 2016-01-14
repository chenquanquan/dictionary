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

    &scan_file($NOTE, &decode('utf-8', $input), $display);
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

    &scan_file($DICT, &decode('utf-8', $input), $display);
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
            ##Add a new word to note.
            #open (OUTPUT, "./$CMD $NOTE $word add $chinese |")
            #    or die "Can't open ./$CMD $NOTE $word add $chinese: $!";
            #close OUTPUT;
            &add_word($NOTE, $word, $chinese);
        }
    }
}

######################################################################
# words.pl
######################################################################
# Add the english word:
#     words.pl $(word) add $(chinese)
#
# The english.txt format:
#     word - chinese

sub scan_file {
    my ($note, $word, $buffer) = @_;


    my @repeat_words;
    my @hid_words;
    my %words_table;
    &read_word($note, \%words_table, \@repeat_words);

    my $wtotal=scalar keys%words_table;
    push @$buffer, "Total: $wtotal\n";

    # If some word repeat
    if (@repeat_words) {
        push @$buffer, "Repeat:@repeat_words\n";
    }

    # If some word need search
    @hid_words = &search_word($word, \%words_table);
    &print_word($buffer, \%words_table, @hid_words);
}

# read_word() - Read words from english file
# $file: the english words file.
# the words while save in WORDS_TABLE, the repeat words save in REPEAT_WORDS.
sub read_word
{
    my ($file, $words, $repeat) = @_;

    # Read the words to list
    open my $filp, "<:encoding(utf8)", $file
        or die "Cannot read $file: $!";

    my $tline;
    while ($tline=<$filp>) {
        $tline =~ s/[\r\n]//g;
        if ($tline  =~ m/(.*) - (.*)/) {
            if (exists $$words{$1}) {
                push @$repeat, $1." ";
            } else {
                $$words{$1} = "$2";
            }
        }
    }
    close $filp;
}

# add_word() - Add word to english file
# $file: the english words file.
# the words while save in WORDS_TABLE, the repeat words save in REPEAT_WORDS.
sub add_word
{
    my ($file, $keyword, $chinese) = @_;

    # Read the words to list
    open my $filp, ">>:encoding(utf8)", $file
        or die "Cannot read $file: $!";

	printf $filp "$keyword". ' - ' . "$chinese" . "\n";

    close $filp;
}

# search_word() - scan the words table and find the same word
# $keyword: the keyword to scan.
# return word hit list.
sub search_word 
{
    my ($keyword, $words) = @_;

    my @hit_list;
    my $key;
    my $value;
    my $chinese;

    $chinese = $keyword;
    while (($key,$value) = each(%$words)) {
        if ($key =~ m/(.*)$keyword(.*)/ || $value =~ m/(.*)$chinese(.*)/) {
            push @hit_list,$key;
        }
    }

    return @hit_list;
}

# print_word() - print all of the word and chinese
# @word_list: all of the word.
sub print_word
{
    my ($buffer, $words, @word_list) =@_;
    my $temp_word;

    if (@word_list) {
        foreach (sort @word_list) {
            $temp_word = $_;

            my $string = "$temp_word - $$words{$temp_word}\n";
            push @$buffer, $string;
        }
        push @$buffer, "Hit number:".(scalar @word_list)."\n";
    } else {
        push @$buffer, "No this word\n";
    }
}
