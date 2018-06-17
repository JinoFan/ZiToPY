#原始材料wordlist.Dic为和train两个文档
#提取词典
open(In,"wordlist.Dic");
open(Out,">Dic.txt");#词典
while(<In>){
	chomp;
	if($_=~/^(\S+) (.+)$/){
		$Hzs=$1;
		$Pys=$2;
		print Out "$Hzs\n";
		print Out1 "$Pys $Hzs\n";
		$h2p{$Hzs}=$Pys;
		${$hash{$Pys}}{$Hzs}=0;
	}
}
close(In);
close(Out);

#语料分词
print "Loading Dictionary...\n";
open(FileIn,"Dic.txt");
$MaxLen=0;
while($Line=<FileIn>){
	chop($Line);
	$MapDict{$Line}=length($Line);
	if ( length($Line) > $MaxLen  ){
		$MaxLen=length($Line);
	}
}
close(FileIn);

open(In,"train");
open(SEG,">seg.txt");
while (<In>){
	$Sent=$_;
	chop($Sent);
	$Result=Segment($Sent);
	print SEG "$Result\n";
}
close(In);
close(SEG);

sub Segment{
	my ($Input)=@_;
	my $Segemted=();
	my $Remained=$Input;
	while ( length($Remained) > 0 ){
		$Match=0;
		for($i=$MaxLen;$i>1;$i-- ){
			$MatchString=substr($Remained,0,$i);
			if ( defined $MapDict{$MatchString} ){
				$Segemted.=$MatchString;
				$Segemted.=' ';
				$Remained=substr($Remained,$i,length($Remained)-$i);
				$Match=1;
				last;
			}
		}
		if ( $Match == 0 ){
			if ( ord($Remained) &0x80 ){
				$Len=2;
			}else{
				$Len=1;
			}
			$Segemted.=substr($Remained,0,$Len);
			$Segemted.=' ';
			$Remained=substr($Remained,$Len,length($Remained)-$Len);
		}
	}
	return $Segemted;
}

#输出分词后的语料
open(In,"seg.txt");
while(<In>){	
	chomp;
	@arr=$_=~/(\S+)/g;
	foreach(@arr){
		$str=$h2p{$_};
		if(defined $hash{$str}){
			${$hash{$str}}{$_}++;
		}	
	}
}
close(In);

