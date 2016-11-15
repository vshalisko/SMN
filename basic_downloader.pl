#!/usr/local/bin/perl
use strict;
use LWP::UserAgent;
use URI::Heuristic;

## Subroutines

sub trim {
	my @out = @_;
	for (@out) {
		s/^\s+//;
		s/\s+$//;
	};
	return wantarray ? @out : $out[0];
}

sub web_browser {
	my $url_draft =$_[0];
	my $url = URI::Heuristic::uf_urlstr($url_draft);
	my $ua = LWP::UserAgent->new();
	$ua->agent("Schmozilla/v9.14 Platinum");
	my $req = HTTP::Request->new(GET => $url);
	my $response = $ua->request($req);
	if ($response->is_error()) {
		my $content = $response->status_line;		
	} else {
		my $content = $response->content();
		return $content;
	};
}

## Main programm

my $input = $ARGV[0];
open(DATAFILE, "<$input") || die "\nUnable to open input URL list $input\n";
	my @input_lines = <DATAFILE>;
close(DATAFILE);

foreach my $url (@input_lines) {
	$url = &trim($url); 
	print $url;
	print "\n";

	my $web_content = &web_browser($url);
	print $web_content;

#	if ($web_content =~ /No\srecords\sfound\./g) {
#		$found = 0;
#	} elsif ($web_content =~ /(\d*)\srecord\sfound\./g) {
#		$found = $1;
#	}; 

#	my $response = LWP::UserAgent->new->request(
#	  HTTP::Request->new( GET => "url" )
#	);

}
