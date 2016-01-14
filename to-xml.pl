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
# For XML
use XML::Simple qw(:strict);
use XML::Writer;


my $WORDS_FILE_NAME = $ARGV[0];

my $XMLFILE="english.xml";
# The words list
my %WORDS_TABLE;
# If have repeat words
my @REPEAT_WORDS;
# If hit the word
my @HID_WORDS;


##
# START
read_word($WORDS_FILE_NAME);
#print %WORDS_TABLE;

my $writer = XML::Writer->new( OUTPUT => 'self', DATA_MODE => 'true');


$writer->xmlDecl();
$writer->startTag('html');
$writer->startTag('body');

foreach my $item ( keys (%WORDS_TABLE) ) {
    $writer->startTag('a', 'href' => $item);
    $writer->characters($WORDS_TABLE{$item});
    $writer->endTag('a');
}

$writer->endTag('body');
$writer->endTag('html');


# Write XML to file
open my $filp, ">>:encoding(utf8)", $XMLFILE
    or die "Cannot read $XMLFILE: $!";

#print $writer->to_string();
printf $filp $writer->to_string();

close $filp;
$writer->end();

##
# END
#

# read_word() - Read words from english file
# $file: the english words file.
# the words while save in WORDS_TABLE, the repeat words save in REPEAT_WORDS.
sub read_word
{
    my ($file) = @_;

    # Read the words to list
    #open my $filp, "<:encoding($CONSOLE_CODE)", $file
    open my $filp, "<:encoding(utf8)", $file
        or die "Cannot read $file: $!";

    my $tline;
    while ($tline=<$filp>) { 
        $tline =~ s/[\r\n]//g;
        if ($tline  =~ m/(.*) - (.*)/) {
            if (exists $WORDS_TABLE{$1}) {
                push @REPEAT_WORDS, $1." ";
            } else {
                $WORDS_TABLE{$1} = "$2";
            }
        }
    }
    close $filp;
}


