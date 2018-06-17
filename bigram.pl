#训练语料的unigram和bigram,原始材料为seg.txt
open(In,"seg.txt");
while(<In>){
	chomp;
	@word=$_=~/(\S+)/g;
	for($i=0;$i<@word;$i++){
		$count++;
		$hash_w{$word[$i]}++;
		if($i>0){
			$str=$word[$i-1]."_".$word[$i];
			$hash_ww{$str}++;
			#${$hash_ww{$word[$i-1]}}{$word[$i]}++;
		}
	}
}
close(In);
open(Out,">bi.txt");
foreach $bi(sort keys %hash_ww){
	if($bi=~/(\S+)\_\S+/){
		$val=log($hash_ww{$bi}/$hash_w{$1});
		print Out "$bi $val\n";
	}
}
close(Out);

open(Out,">uni.txt");
foreach $w(sort keys %hash_w){
	$val=log($hash_w{$w}/$count);
	print Out "$w $val\n";
}
close(Out);