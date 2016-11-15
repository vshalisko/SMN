#!/usr/local/bin/perl
##---------------------------------------------------------------------------##
##  Author:
##      Viacheslav Shalisko       vshalisko@gmail.com
##  Date:
##      14.11.2016
##  Description: 
##      Script for climatological normal data download from 
##      Mexican Meteorological Service (SMN) website
##      http://smn.cna.gob.mx/es/component/content/article?id=42
##      (Normales Climatologicas por Estado)
##  Usage:
##	1. Make list of index page URLs (normally one URL for state, like
##	   http://smn.cna.gob.mx/tools/RESOURCES/normales_climatologicas_catalogo/cat_col.html)
##         and store this URLs in text file url_input.txt, each URL
##         in separate line
##      2. Create output subdirectory "out"
##      3. Run script as perl SMN_downloader.pl url_input.txt
##      4. List of URLs will be stored in file urts_list.txt
##      5. SMN text files will be stored in "out" directory, with preffix 
##         related to the original data folder in SMN website 
##     
##---------------------------------------------------------------------------##
##    
##    This program is free software; you can redistribute it and/or modify
##    it under the terms of the GNU General Public License as published by
##    the Free Software Foundation; either version 2 of the License, or
##    (at your option) any later version.
##
##    This program is distributed in the hope that it will be useful,
##    but WITHOUT ANY WARRANTY; without even the implied warranty of
##    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##    GNU General Public License for more details.
##
##---------------------------------------------------------------------------##


use strict;
use LWP::UserAgent;
use URI;
use URI::Heuristic;
use WWW::Mechanize;

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

## initial URLs
my $input = $ARGV[0];
open(DATAFILE, "<$input") || die "\nUnable to open input URL list $input\n";
	my @input_urls = <DATAFILE>;
close(DATAFILE);

my $output_url_filename = "urls_list.txt";
my @good_links = ();

# getting list of secondary URLs
foreach my $input_url (@input_urls) {
	my $mech = WWW::Mechanize->new();
	$mech->get( $input_url );
	my @links = $mech->links();

	open(OUTPUTFILE, ">>$output_url_filename") || die "Unable to open output file $output_url_filename!";
	for my $link ( @links ) {
		my $abs_url = URI->new_abs($link->url,$input_url);
		print $abs_url . "\n";
		if ($link->url =~ /(\w+)\.(TXT|txt)/g) {   # we are interested in txt files only
			printf OUTPUTFILE "%s, %s\n", $link->text, $abs_url;
			push @good_links, $abs_url;
		}
	}
	close(OUTPUTFILE);
}

# download and store TXT files
foreach my $good_link (@good_links) {
	my $url = &trim($good_link); 
	my $output_filename = "undefined_output.txt"; # Use general output if no output filename is defined in URL
	if ($url =~ /.*\/(\w+)\/(\w+\.\w+)/g) {
		$output_filename = "out/" . $1 . "-" . $2;
	}
	print $output_filename . "\n";

	my $web_content = &web_browser($url);

	open(OUTPUTFILE, ">>$output_filename") || die "Unable to open output file $output_filename!";
	print OUTPUTFILE $web_content;
	close(OUTPUTFILE);
}
