#!/usr/bin/perl

$file1 = $ARGV[0];
$file2 = $ARGV[1];
$file3 = $ARGV[2];
$file4 = $ARGV[3];

#open 入力ファイル
open (DES, "<$file1");
open (QAL, "<$file2");

#open 出力ファイル
open (OUT1, ">$file3");
open (OUT2, ">$file4");

#配列に格納
@DES = <DES>;
@QAL = <QAL>;

### qual1.csv作成 ###
for($i=0; $i<@QAL; $i++){
	#Qualifier Abbriviation
	if(@QAL[$i] =~ /QA = (.+)/){
	print OUT1 $1 . "\t";
	}
	#Subheading
	if(@QAL[$i] =~ /SH = (.+)/){
	print OUT1 $1 . "\t";
	}
	#Qualifier ID
	if(@QAL[$i] =~ /UI = (Q\d{6})/){
	print OUT1 "$1\n";
	}
}

### qual2.csv作成 ###
for($i=0; $i<@DES; $i++){
	#Qualifier Abbriviation
	if(@DES[$i] =~ /AQ = (.+)/){
	@AG = split(/ /,$1);
	}
	#Qualifier ID
	if(@DES[$i] =~ /UI = (D\d{6})/){
		for($j=0;$j<@AG;$j++){
		print OUT2 @AG[$j] . "\t" .  $1 . "\n";
		}
	}
}

#close
close(DES);
close(QAL);
close(OUT1);
close(OUT2);