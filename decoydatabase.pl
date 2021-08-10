#!urs/bin/perl
use strict;
use warnings;

print"please input the database file and output file names:\n";
die "ERROR: must specify input database!\n\n\tUsage: revcat.pl input.fasta output.fasta\n\n" if ($ARGV[0] eq "");
die "ERROR: must specify output database!\n\n\tUsage: revcat.pl input.fasta output.fasta\n\n" if ($ARGV[1] eq "");

open ("IN",$ARGV[0]) or die "cannot open the file $ARGV[0]\n";
open ("OUT",">$ARGV[1]") or die "cannot create the file $ARGV[1]\n";
my $access;
my $name;
my $seq;
undef $/;
local $/ = ">";  # read by FASTA record
my @array;

while(<IN>){
    chomp;
    ## the if is to keep all the things that after "LENGTH=...\n", which aer the sequence that we want
 	if ($_=~/(^AT.*\.\d)(.*Symbols.*\n)([\s\S]*)/) { 
        $access=$1;
        $name=$2;
        $seq=reverse($3);
        $seq =~s/\n//g;
 		print OUT ">".$access."_rev".$name.$seq."\n";
        }
        
    }
close IN;
close OUT;
print "finished\n";