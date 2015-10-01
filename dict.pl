#!/usr/bin/perl
# The dict interface of the english word.
# Call the same path "word.pl" to access word.
# input: exit - exit the program.
#        number - display the english table, the table is format of 50 per table.
#        english/chinese - scan the note book and dictionary.
#        english add chinese - add the item in note book.
use warnings;
use strict;
# Search chinese
use Encode;

my $CMD="words.pl";
my $NOTE="english.txc";
my $DICT="new_dictionary.txc";
my $TABLE_DIR="table";
#my $DICT="dictionary.txc";
#my $OXFORD="oxford.txc";
my $input = "";
my @exec_args;

#while ($input !~ m/^exit$/) {
while (1) {
    print "input:";
    $input = <STDIN>;
    chomp($input);

    # input exit to close all
    if ($input =~ m/^exit$/) {
        last;
    }

    ## Scan word
    # if want to scan english table
    if ($input =~ m/^\d+$/) {
        my $file_name = "$TABLE_DIR" . '/' . 'table' . "$input" . '.txt';
        my @table;
        
        push @table, 'Table - ' . "$input" . "\n";
        open (OUTPUT, "./$CMD -t $input $NOTE |") or die "Can't open ./$CMD -t $input $NOTE : $!";
        while (my $line = <OUTPUT>) {
            print " $line"; # add empty for complete double byte charecture.
            chomp($line);
            push @table, "$line" . "\n";
        }
        #write to table file
        &add_item($file_name, @table);
        next;
    }

    ## Display word by page
    if ($input =~ m/^\?\d+$/) {
        $input =~ s/\?//g;
        &output_word($input);
        next;
    }

    ## Input control
    # discard empty word
    if ($input !~ m/^[\w\.\-\"\p{Han}]+/) {
        next;
    }

    print "$input" . "\n";
    print "=========NOTE=========\n";
    open (OUTPUT, "./$CMD $NOTE $input |") or die "Can't open ./$CMD $NOTE $input: $!";
    while (my $line = <OUTPUT>) {
        print "$line"; # add empty for complete double byte charecture.
    }
    close OUTPUT;
    print "\n";
    if ($input !~ m/ add /) {
        print "=======DICTIONARY=====\n";
        open (OUTPUT, "./$CMD $DICT $input |") or die "Can't open ./$CMD $DICT $input: $!";
        while (my $line = <OUTPUT>) {
            print "$line"; # add empty for complete double byte charecture.
        }
        close OUTPUT;
        print "\n";
    }
    print "======================\n";
}
print "ok!\n";

# add_word() - Add word to english file
# $file: the english words file.
# the words while save in WORDS_TABLE, the repeat words save in REPEAT_WORDS.
sub add_item
{
    my ($file, @item) = @_;

    # Read the words to list
    open my $filp, ">", $file
        or die "Cannot read $file: $!";

	printf $filp "@item";

    close $filp;
}

# output_word() - output word on screen
# $page: the word page.
# The output is only word and without chinese.
sub output_word
{
    my ($page) = @_;

    my $count=4;
    # if want to scan english table
    open (OUTPUT, "./$CMD -t $page $NOTE |") or die "Can't open ./$CMD -t $page $NOTE : $!";
    while (my $line = <OUTPUT>) {
        $line =~ s/ - .*$//g;
        print " $line"; # add empty for complete double byte charecture.
    }
}
