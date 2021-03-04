#!/usr/bin/perl

$file1 = $ARGV[0];
$file2 = $ARGV[1];
$file3 = $ARGV[2];
$file4 = $ARGV[3];

#open 入力ファイル
open (IN, "<$file1");

#open 出力ファイル
open (OUT1, ">$file2");
open (OUT2, ">$file3");
open (OUT3, ">$file4");

#初期化サブルーチン
sub init1{
$mesh_id = "EMPTY";
@tree_no = ();
@category = ();
@parent_tree_no = ();
}

sub init2{
#7データ毎の配列
$mesh_id = "EMPTY";
$term = "EMPTY";
@tree_no = ();
@category = ();
@annotation = ();
@scope_note = ();
@cas = ();
@synonym = ();
}

#毎行格納
@IN = <IN>;
chomp @IN;
#何行のファイルか
$limit = @IN;

#カウンタ
$count = 0;

#まずはRで親を辿るためのデータを出力しておく
for($i=0; $i<@IN; $i++){
$now = $i + 1;
# print $now . " / " . $limit . "\n";
	# tree_no, category, parent_tree_no
	if(@IN[$i] =~ /MN = ([A-Z])(.+)(\.\d+)/){
		push(@category,$1);push(@parent_tree_no,$1 . $2);push(@tree_no,$1 . $2 . $3);
	}elsif(@IN[$i] =~ /MN = ([A-Z])(.+)/){
		push(@category,$1);push(@parent_tree_no,"");push(@tree_no,$1 . $2);
	}
	# mesh_id
	if(@IN[$i] =~ /UI = (.+)/){$mesh_id = $1}
	if($mesh_id =~ /D\d+/){
		for($f=0; $f<@tree_no; $f++){
		#何故か入る半角スペースを除去
		$count=~ s/\s//g;
			print OUT3 "$mesh_id\t@tree_no[$f]\t@category[$f]\t@parent_tree_no[$f]\n";
			$count = $count + 1;
		}
	#初期化
	&init1();
	}
}


#カウンター
$count = 0;

#他のファイルのためのサーチ
for($i=0; $i<@IN; $i++){
$now = $i + 1;
# print $now . " / " . $limit . "\n";
	# tree_no, category
	if(@IN[$i] =~ /MN = ([A-Z])(.+)(\.\d+)/){
		push(@category,$1);push(@tree_no,$1 . $2 . $3)
	}elsif(@IN[$i] =~ /MN = ([A-Z])(.+)/){
		push(@category,$1);push(@tree_no,$1 . $2)
	}
	# term
	if(@IN[$i] =~ /MH = (.+)/){$term = $1}
	# synonym1
	if(@IN[$i] =~ /PRINT ENTRY = (.+)/){push(@synonym,$1)}
	# synonym2
	if(@IN[$i] =~ /ENTRY = (.+)/){push(@synonym,$1)}
	# mesh_id
	if(@IN[$i] =~ /UI = (.+)/){$mesh_id = $1}
	if($mesh_id =~ /D\d+/){
		for($f=0; $f<@tree_no; $f++){
		print OUT1 "$mesh_id\t$term\t@category[$f]\n";
			$length = @synonym;
			if($length == 1){
			print OUT2 "$mesh_id\t@synonym[0]\n";
			}
			if($length > 1){
				for($xxx=0;$xxx<@synonym;$xxx++){
				print OUT2 "$mesh_id\t@synonym[$xxx]\n";
				}
			}
		$count = $count + 1;
		}
		undef $A;undef $B;undef $C;undef $D;
		#初期化
		&init2();
	}
}

######################## 終了作業　########################
close(IN);
close(OUT1);
close(OUT2);
close(OUT3);