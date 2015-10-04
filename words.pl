#!/usr/bin/perl
# Read english.txt and scan words.
# the english data file named "english.txc" in same path.
#
# Scan the english word:
#     words.pl $(word)
#
# Add the english word:
#     words.pl $(word) add $(chinese)
#
# The english.txt format:
#     word - chinese
use warnings;
use strict;
# Search chinese
use Encode;
# Get standard option
use Getopt::Std;

# Use open chinese word
#use encoding "utf8", STDOUT => 'gbk';
my $CONSOLE_CODE;
my $platform = $^O;
##if ($^O =~ m/linux/) {
#	use encoding "utf8", STDOUT => 'utf8';
#	$CONSOLE_CODE='utf8';
#	print $^O."\n";
##} else {
##	use encoding "utf8", STDOUT => 'gbk';
##	$CONSOLE_CODE='gbk';
##	print $^O."\n";
##}
    
if ($platform =~ m/MSWin32/) {
    #use encoding "utf8", STDOUT => 'gbk';
    binmode(STDOUT, ':encoding(gbk)');
    $CONSOLE_CODE='gbk';
    #print $^O."\n";
} else {
    #use encoding "utf8", STDOUT => 'utf8';
    binmode(STDERR, ':encoding(utf8)');
    $CONSOLE_CODE='utf8';
    #print $^O."\n";
}

# preprecessing the agrs
my %args;
my $aword;
my $cchinese;
my $ntable;
my $ftable = 0;
#add -a -c args
&getopts(":a:c:t:", \%args);
if (defined $args{a}) {
    $aword = $args{a};
    print "a:";
    print $aword;
    print "\n";
}
if (defined $args{c}) {
    $cchinese = $args{c};
    print "c:";
    print $cchinese;
    print "\n";
}
if (defined $args{t}) {
    $ntable = $args{t};
    $ftable = 1;
}
if (!defined $args{a} or !defined $args{c} or !defined $args{t}) {
    #print @ARGV;
}


#
# Global value
#

# Get file name
my $WORDS_FILE_NAME = $ARGV[0];
#my $WORDS_FILE_NAME = "english.txc";
my $SEARCH_WORD;
if (exists $ARGV[1]) {
    $SEARCH_WORD = $ARGV[1];
	#print "Search word:".(decode('gbk', $ARGV[1]))."\n";
    if ($platform =~ m/MSWin32/) {
        print "Search word:".(&decode($CONSOLE_CODE, $ARGV[1]))."\n";
    } else {
        #print "Search word:".(&decode($CONSOLE_CODE, $ARGV[1]))."\n";
        print "Search word:".($ARGV[1])."\n";
    }
}

# Get command
my $CMD;
my $ADD_CHINESE;
if (exists $ARGV[2]) {
    # Add new word
    if ($ARGV[2] =~ "add") {
        print "Add new word:";
        if (exists $ARGV[3]) {
            if ($platform =~ m/MSWin32/) {
                $ADD_CHINESE = &decode($CONSOLE_CODE, $ARGV[3]);
            } else {
                $ADD_CHINESE = &decode($CONSOLE_CODE, $ARGV[3]);
                #$ADD_CHINESE = $ARGV[3];
            }
            print &encode($CONSOLE_CODE, $ADD_CHINESE)."\n";
            &add_word($WORDS_FILE_NAME, $SEARCH_WORD, $ADD_CHINESE);
        } else {
            print "No chinese\n";
        }
    }
}


# The words list
my %WORDS_TABLE;
# If have repeat words
my @REPEAT_WORDS;
# If hit the word
my @HID_WORDS;

#
# END: Globle value
#

#
# START
#
&read_word($WORDS_FILE_NAME);
if ($ftable == 1) {
    &print_table($WORDS_FILE_NAME, $ntable);
}
#print %WORDS_TABLE;
my $wtotal=scalar keys%WORDS_TABLE;
print "Total:$wtotal\n";

# If some word repeat
if (@REPEAT_WORDS) {
    print "Repeat:@REPEAT_WORDS\n";
}

# If some word need search
if (exists $ARGV[1]) {
    @HID_WORDS = &search_word($SEARCH_WORD);
    &print_word(@HID_WORDS);
}
#
# END
#


#
# Subfunction
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

# print_table() - print the word table of number
# $file: the english words file.
# $num: the table number.
# read word and print the word of table.
sub print_table
{
    my ($file, $num) = @_;

    # Read the words to list
    #open my $filp, "<:encoding($CONSOLE_CODE)", $file
    open my $filp, "<:encoding(utf8)", $file
        or die "Cannot read $file: $!";

    my $tline;
    my $i = 1;
    my $j = 0;
    while ($tline=<$filp>) { 
        $tline =~ s/[\r\n]//g;
        if ($tline  =~ m/(.*) - (.*)/) {
            if ($i == $num) {
                print $j+1;
                print ": ";
                print &encode($CONSOLE_CODE,$1);
                print " - ";
                print $2;
                print "\n";
            }
            $j++;
            $j %= 50;
            if ($j == 0) {
                $i++;
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
    my ($keyword) = @_;

    my @hit_list;
    my $key;
    my $value;
    my $chinese;

    $chinese = $keyword;
    if (not $platform =~ m/MSWin32/) {
        $chinese = &decode($CONSOLE_CODE, $keyword);
    }
    while (($key,$value) = each(%WORDS_TABLE)) {
#        if ($platform =~ m/MSWin32/) {
#            $value = &encode($CONSOLE_CODE, $value);
#        }
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
    my @word_list = sort @_;
	my $temp_word;
    my $tmp_chinese;

    if (@word_list) {
        foreach (@word_list) {
            #print "$_ - $WORDS_TABLE{$_}\n";
            #encode("gb2312",$char)
            $temp_word = $_;
            #print (&encode($CONSOLE_CODE,$temp_word))." - ".(&encode($CONSOLE_CODE,$WORDS_TABLE{$temp_word})).'\n';
            #print &encode($CONSOLE_CODE,$WORDS_TABLE{$temp_word});
            #print &encode('gbk',$WORDS_TABLE{$temp_word});
            #print &encode('gb2312',$WORDS_TABLE{$temp_word});
            #print &encode("gb2312",&decode('utf8',$WORDS_TABLE{$temp_word}));
            
            print &encode($CONSOLE_CODE,$temp_word);
            print " - ";
            print &encode($CONSOLE_CODE, $WORDS_TABLE{$temp_word});
            #$tmp_chinese = &decode('utf8',$WORDS_TABLE{$temp_word});
            #$tmp_chinese = $WORDS_TABLE{$temp_word};
            #print &encode($CONSOLE_CODE,$tmp_chinese);
            print "\n";
        }
        print "Hit number:".(scalar @word_list)."\n";
    } else {
        print "No this word\n";
    }
}
