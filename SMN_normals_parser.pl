#!/usr/local/bin/perl
##---------------------------------------------------------------------------##
##  Author:
##      Viacheslav Shalisko       vshalisko@gmail.com
##  Date:
##      16.11.2016
##  Description: 
##      Script to extract monthly climatic normal values from separate files 
##      and store them in separate table (tab-separated)
##  Usage:
##      The output directory and output file should be defined in $dir 
##      and $output_file variables, the output file is stored in same directory
##      where input data is located, the input file mask list should be
##      stored as array in @filemask
##      Script can be executed by typing perl SMN_normals_parser.pl
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

sub trim {
	my @out = @_;
	for (@out) {
		s/^\s+//;
		s/\s+$//;
	};
	return wantarray ? @out : $out[0];
}

my $dir = "out_smn";
my $output_file = "_normales8110.txt";
my @filemask = ("Normales8110-NORMAL*.txt", "Normales8110-NORMAL*.TXT");

my $empty_data = "-9999\t" x 13;

chdir $dir || die "\nCan`t change directory to $dir\n";

open(OUTPUTFILE, ">$output_file") || die "\nCan`t write to output file $output_file\n";

# output file heading
print OUTPUTFILE "SMN_code\tSMN_name\tLatitude\tLongitude\tAltitude\t";
print OUTPUTFILE "TMIN_01\tTMIN_02\tTMIN_03\tTMIN_04\tTMIN_05\tTMIN_06\tTMIN_07\tTMIN_08\tTMIN_09\tTMIN_10\tTMIN_11\tTMIN_12\tTMIN_AN\t";
print OUTPUTFILE "TMEAN_01\tTMEAN_02\tTMEAN_03\tTMEAN_04\tTMEAN_05\tTMEAN_06\tTMEAN_07\tTMEAN_08\tTMEAN_09\tTMEAN_10\tTMEAN_11\tTMEAN_12\tTMEAN_AN\t";
print OUTPUTFILE "TMAX_01\tTMAX_02\tTMAX_03\tTMAX_04\tTMAX_05\tTMAX_06\tTMAX_07\tTMAX_08\tTMAX_09\tTMAX_10\tTMAX_11\tTMAX_12\tTMAX_AN\t";
print OUTPUTFILE "PREC_01\tPREC_02\tPREC_03\tPREC_04\tPREC_05\tPREC_06\tPREC_07\tPREC_08\tPREC_09\tPREC_10\tPREC_11\tPREC_12\tPREC_AN\n";

while (<@filemask>) {
	print $_ . "\n";

        open(FILE,"<$_");
	undef $/;	# read the entire file as one line, ignoring line breaks
	my $file = <FILE>;

	#search for station code and name
	my $station_num = "-9999";
	my $station_nom = "-9999";
	if ($file =~ m/ESTACION:\s+(\d+)\s+([\p{L}\w\s()-+.,]+)\s+LATITUD/ism) {
		$station_num = $1;
		$station_nom = $2;
	}

	# search for station coordinates and convert them to degrees
	my $station_lat = -9999;
	if ($file =~ m/LATITUD:\s+(\d{1,2})\D(\d{1,2})'([0-9.]+)"\s+([NS])\./ism) {
		$station_lat = $1 + $2/60 + $3/3600;
		if ( $4 eq "S" ) { $station_lat = -1 * $station_lat; }
	}	

	my $station_lon = -9999;
	if ($file =~ m/LONGITUD:\s+(\d{1,3})\D(\d{1,2})'([0-9.]+)"\s+([WE])\./ism) {
		$station_lon = $1 + $2/60 + $3/3600;
		if ( $4 eq "W" ) { $station_lon = -1 * $station_lon; }
	}	
	
	# search for station altitude
	my $station_alt = -9999;
	if ($file =~ m/ALTURA:\s+([\d,.-]+)\s+MSNM\./ism) {
		$station_alt = $1;
		$station_alt =~ s/,//;
	}	

	# search for climatic normals (entire strings, only full data)
	my $tmax_normal_string = $empty_data;
	if ($file =~ m/TEMPERATURA\s+MAXIMA\nNORMAL([\d\s.+-]+)\nMAXIMA\s+MENSUAL/ism) {
		$tmax_normal_string = $1;
	}	
	my $tmean_normal_string = $empty_data;
	if ($file =~ m/TEMPERATURA\s+MEDIA\nNORMAL([\d\s.+-]+)\nA\p{L}OS\s+CON\s+DATOS/ism) {
		$tmean_normal_string = $1;
	}	
	my $tmin_normal_string = $empty_data;
	if ($file =~ m/TEMPERATURA\s+MINIMA\nNORMAL([\d\s.+-]+)\nMINIMA\s+MENSUAL/ism) {
		$tmin_normal_string = $1;
	}	
	my $prec_normal_string = $empty_data;
	if ($file =~ m/PRECIPITACION\nNORMAL([\d\s.,]+)\nMAXIMA\s+MENSUAL/ism) {
		$prec_normal_string = $1;
		$prec_normal_string =~ s/,//;
	}	


	printf "SMN Code: %s, Name: %s\n", $station_num, $station_nom;
	printf "Latitude: %s, Longitude: %s, Altitude: %s\n", $station_lat, $station_lon, $station_alt;
	printf "TMAX: %s\n", $tmax_normal_string;
	printf "TMIN: %s\n", $tmin_normal_string;
	printf "TMEAN: %s\n", $tmean_normal_string;
	printf "PREC: %s\n", $prec_normal_string;

	close(FILE);

	$tmax_normal_string =~ s/\s+/\t/g;
	$tmax_normal_string = &trim($tmax_normal_string);
	$tmean_normal_string =~ s/\s+/\t/g;
	$tmean_normal_string = &trim($tmean_normal_string);
	$tmin_normal_string =~ s/\s+/\t/g;
	$tmin_normal_string = &trim($tmin_normal_string);
	$prec_normal_string =~ s/\s+/\t/g;
	$prec_normal_string = &trim($prec_normal_string);

	printf OUTPUTFILE "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n", 
		$station_num, $station_nom, $station_lat, $station_lon, $station_alt, 
		$tmax_normal_string, $tmin_normal_string, $tmean_normal_string, $prec_normal_string;
	;

}

close(OUTPUTFILE);