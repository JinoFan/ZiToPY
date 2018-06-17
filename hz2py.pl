#原始材料bi.txt和uni.txt
#动态规划算SEG
#全切分路径求优算法
open(In,"wordlist.Dic");
while(<In>){
	chomp;
	if($_=~/^(\S+) (.+)$/){
		my($Wds)=$1;
		my($Pys)=$2;
		print Out "$Wds\n";
		print Out1 "$Pys $Wds\n";
		$h2p{$Wds}=$Pys;
	}
}
close(In);

InitNGram("uni.txt","bi.txt");

while (1){
	print "pls input(q to quit)\n";
	$Inp=<stdin>;
	chomp($Inp);
	if ( $Inp eq "q" ){
		last;
	}
	$SEGResult=SEG($Inp);
	print "$SEGResult\n";
}
sub SEG{
	my($Inp)=@_;
	my @Lattice=();
	my $Result;
	Buildlattice($Inp,\@Lattice);	
	Search(\@Lattice);
	$Result=Backward(\@Lattice);
	return $Result;
}
sub InitNGram{
	my($Unigram,$Bigram)=@_;
	open(A,"$Unigram");
	while(<A>){
		chomp;
		if($_=~/(\S+)\s+(\S+)/g){
			$HashUni{$1}=$2;
		}
	}
	close(A);
	open(B,"$Bigram");
	while(<B>){
		chomp;
		if($_=~/(\S+)\_(\S+)\s+(\S+)/){
			${$hashBi{$1}}{$2}=$3;			
		}
	}
	close(B);
}
sub GetUni{
	my($word)=@_;
	if(defined $HashUni{$word}){
		return $HashUni{$word};
	}
	return -1000;
}
sub GetBi{
	my($word1,$word2)=@_;
	if(defined ${$hashBi{$word1}}{$word2}){
		return ${$hashBi{$word1}}{$word2};
	}
	return -1000;
}
#建立四元组网络
sub Buildlattice{
	my($Inp,$RefLattice)=@_;
	my @HZs=();
	my $tempHZ;
	my $BLLength=length($Inp);
	#print "$BLLength\n";
	for($BLj=0;$BLj<$BLLength;$BLj++){
		$tempHZ=substr($Inp,$BLj,2);
		if(ord($tempHZ)& 0x80){
			push(@HZs,$tempHZ);
			}	
			$BLj++;
	}
	unshift(@HZs,"BEG");
	push(@HZs,"END");
	$NumWD=@HZs;
	
	for($i=0;$i<@HZs;$i++){
		my @OneColumn=();
		@Candidate=();
		GetAllCandidate($HZs[$i],$NumWD,$i,\@HZs,\@Candidate);#求出候选的切分出的词
		foreach (@Candidate){
			my @OneUnit=();
			$OneUnit[0]=$HZs[$i];	
			$OneUnit[1]=$_;	
			$OneUnit[2]=0;	
			$OneUnit[3]=0;
			push(@OneColumn,\@OneUnit);
		}
		push(@{$RefLattice},\@OneColumn);#网格包含列，列包含词单元，词单元包含相关信息
	}
}
#筛选字所对应的合法的词
sub	GetAllCandidate{
	my($HZ,$NumWD,$icdt,$RefHZ,$refcandidate)=@_;
	my $maxLength=0;
	my @WDS4I=();
	my @newWDs=();
	push(@newWDs,$HZ);
	$maxLength=2*$icdt+2;
	$tempWD=$HZ;
	
	if($tempWD eq "END"){}
	else{
		for($jcdt=1;$jcdt<($maxLength/2)-1;$jcdt++){
			$tempWD="${$RefHZ}[$icdt-$jcdt]".$tempWD;#依次向前取
			push (@newWDs,$tempWD);
		}
	}
	push(@{$refcandidate},@newWDs);
}

#Viterbi搜索
sub Search{
	my($RefLattice)=@_;
	#print "Search\n";
	for($i=1;$i<@{$RefLattice};$i++){
		$RefCurrent=${$RefLattice}[$i];
		foreach $RefCurWD(@{$RefCurrent}){
			$Max=-1e1000;
			$Num=0;
			$Slength=length(${$RefCurWD}[1]);#词
			if (${$RefCurWD}[1] eq "END"){
				$RefPrevious=${$RefLattice}[$i-1];
			}
			else{
				$RefPrevious=${$RefLattice}[$i-$Slength/2];
			}
			foreach $RefPrevWD(@$RefPrevious){
				$Val=GetProb(${$RefPrevWD}[1],${$RefCurWD}[1])+${$RefPrevWD}[2];
				if ( $Val > $Max){#
					$Max=$Val;
					$MaxProb=$Num;
				}
				$Num++;
			}
			${$RefCurWD}[2]=$Max;#累计最大概率值
			${$RefCurWD}[3]=${$RefPrevious}[$MaxProb];#回退指针
		}
	}	
}
#回溯
sub Backward{
	my @PYResultArray;
	my ($RefLattice)=@_;
	my $RefEnd=${$RefLattice}[@$RefLattice-1];
	$BackPointer=${${$RefEnd}[0]}[3];
	my @ResultArray;
	while( ${$BackPointer}[3] != 0 ){
	$Pair=${$BackPointer}[1];
		unshift(@ResultArray,$Pair);
		$BackPointer=${$BackPointer}[3];
	}
	if(@ResultArray==1){
		my($str)=join("",@ResultArray);
		@tmparr=$str=~/../g;
		foreach $hz(@tmparr){
			# print "$hz";
			push(@PYResultArray,$h2p{$hz});
		}
	}
	else{
		foreach $Word(@ResultArray){
			push(@PYResultArray,$h2p{$Word});
		}
	}
	
	#my $Result=join(" ",@ResultArray);#分词结果
	my $Result=join(" ",@PYResultArray);
	return $Result;
}
#计算概率
sub GetProb{
	my($WD1,$WD2)=@_;
	if ($WD1 eq "BEG" ){
		$Val=GetUni($WD2);
	}elsif ($WD2 eq "END" ){
		$Val=0.0;
	}else{
		$Val=GetBi($WD1,$WD2);
	}
	return $Val;	
}