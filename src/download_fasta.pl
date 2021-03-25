#!/usr/bin/perl

use LWP::Simple;

# Download protein records corresponding to a list of GI numbers.
$file = $ARGV[0];

$db = 'protein';
open (IN,"<$file");
@gifile = <IN>;
chomp @gifile;
$last = @gifile;

# NCBI API KEY
# https://www.ncbi.nlm.nih.gov/books/NBK25497/
# たくさん投げるときは、api key が必要。
# API KEYがあれば、10request/sec いけるとのこと。
# API KEYがないと、 3request/sec とのこと。
# ただし、アクセス方法などは確認したほうが良い。
# APIがいきているかの確認方法
# https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?db=pubmed&id=123456&api_key=YOURAPIKEY
# API_KEYが正しいときは、データがかえってくる。
# API_KEYが正しくないときは、データがかえってこない。

my $api_key="";
if ($ARGV[1] != "") {
	$api_key="&api_key=" . $ARGV[1];
}
# print "NCBI API KEY [$api_key]\n";

# 20個ずつまとめて投げる
$limit = 20;
for($i=0; $i<$last; $i=$i+$limit){
    # 20個ずつまとめてJOIN
    $start = $i;
    $end = $i + $limit - 1;
    if($end>($last-1)){
            $end=$last-1;
    }
	@sub_gifile = @gifile[$start..$end];
	$id_list = join(",", @sub_gifile);

	#assemble the epost URL
	$base = 'https://eutils.ncbi.nlm.nih.gov/entrez/eutils/';
	$url = $base . "esearch.fcgi?db=$db&term=$id_list&usehistory=y&tool=ebot$api_key";

	#post the epost URL
	$output = get($url);

	#parse WebEnv and QueryKey
	$web = $1 if ($output =~ /<WebEnv>(\S+)<\/WebEnv>/);
	$key = $1 if ($output =~ /<QueryKey>(\d+)<\/QueryKey>/);

	### include this code for EPost-ESummary
	# assemble the esummary URL
	$url = $base . "esummary.fcgi?db=$db&query_key=$key&WebEnv=$web$api_key";

	### include this code for EPost-EFetch
	#assemble the efetch URL
	$url = $base . "efetch.fcgi?db=$db&query_key=$key&WebEnv=$web$api_key";
	$url .= "&rettype=fasta&retmode=text";

	#post the efetch URL
	$data = get($url);
	print "$data";
}