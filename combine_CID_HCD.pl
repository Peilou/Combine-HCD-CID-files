#!/urs/bin/perl
use strict;
use warnings;
=pot
This program is used for Combine CID and HCD peaklist;
please put all the CID and HCD (.mgf) files and this program in the same working directory. 
The "New_....mgf" is the outfile relevent to the older one.
=cut

my @all_file=glob "*.mgf"; #returns a list of filename expansions (.mgf)
my $i=0;
for($i=0;$i<$#all_file;$i=$i+2){
	print "now processing the file $all_file[$i] and $all_file[$i+1]), please waiting...\n\n";
	&iTRAQ_processing ($all_file[$i],$all_file[$i+1]); 
}

sub iTRAQ_processing{
my ($cid,$hcd)=@_;

my $r114=114.112;  #Declare and initialize variables 
my $r115=115.108;
my $r116=116.116;
my $r117=117.115;
my $groupname;
my @data;
my $number;
my %group;

open("HCD","$hcd")or die "cannot open HCD file\n";
open("NEW_HCD",">","New_"."$hcd")or die "cannot creat new HCD file\n";

while(<HCD>){
	if(/^\D/){
		print NEW_HCD "$_" if(!/MASS=Monoisotopic/); #without "MASS=Monoisotopic" line; 
		$groupname=$1 if(/TITLE=(Spectrum\d+)\s/) #get the Spectrum name;
	}
	else{
		chomp;
		@data=split/\s+/;
		if($data[0]>=114 && $data[0]<=118){
			if(($data[0]>=($r114-0.01)&&$data[0]<=($r114+0.01))||($data[0]>=($r115-0.01)&&$data[0]<=($r115+0.01))
			||($data[0]>=($r116-0.01)&&$data[0]<=($r116+0.01))||($data[0]>=($r117-0.01)&&$data[0]<=($r117+0.01))){
				$data[1]=$data[1]/30;           #if mass matches 114-117 conditions, intensity divided by 30;
				print NEW_HCD "@data\n";
				$number=join(' ',@data);         
				$group{$groupname}.=$number."\n"; #put all the reporter ions in the corresponding hash
			}								
		}
		else {print NEW_HCD "$_\n";}
	}
}
close HCD;
close NEW_HCD;

open ("CID","$cid")or die "cannot open CID file\n";
open ("NEW_CID",">","New_"."$cid")or die "cannot creat new cid file\n";

$groupname='';
my $printed=0;
@data=0;
# get the corresponding iTRAQ reporter from hash, and the new CID files;
while(<CID>){
	if(/^\D/){
		if(/END IONS/){print NEW_CID "$group{$groupname}" if($data[0]<114 and exists ($group{$groupname}));}
		print NEW_CID "$_" if(!/MASS=Monoisotopic/);
		$groupname=$1 if(/TITLE=(Spectrum\d+)\s/);
		$printed=0;
	}
	else{
		chomp;
		@data=split/\s+/;
		if($data[0]<114) {print NEW_CID "$_\n";}
		elsif(($data[0]>=114) && ($data[0]<=118) && ($printed==0) && (exists ($group{$groupname}))){
				print NEW_CID "$group{$groupname}";
				$printed=1;
			}		
		elsif(($data[0]>118) && ($printed==1)){print NEW_CID "$_\n";} 
		elsif(($data[0]>118) && ($printed==0) && (exists($group{$groupname}))){
			print NEW_CID "$group{$groupname}"."$_\n";
			$printed=1;
		}
		elsif(($data[0]>118) && ($printed==0)){print NEW_CID "$_\n";}
	}
}

close CID;
close NEW_CID;
}