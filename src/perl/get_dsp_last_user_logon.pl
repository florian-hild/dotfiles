#!/usr/bin/perl -w

#-------------------------------------------------------------------------------
# Author     : Florian Hild
# Created    : 19-06-2024
# Description: Quick and dirty script to get last logon timestanp for users in dsp logfile
# Create spool file:
# $SQL
# SET FEEDBACK OFF
# SET NEWPAGE NONE
# SET TAB OFF
# SET TERMOUT OFF
# set pagesize 0
# set linesize 250
# spool sup_users.lst
# SELECT BENUTZERNAME FROM BENUTZER where KUNDEN_KENNZ = 'J' order by BENUTZERNAME;
# spool off
#-------------------------------------------------------------------------------

use strict;
use warnings;
use File::stat;
use Time::Piece;
use Data::Dumper;

our $VERSION = '1.0';

my $dir = $ENV{LOG};
my $file_pattern = 'dsp.*';
my $sup_db_users_file = '/home/hild/sup_users.lst';
my $timestamp_format = '%Y/%m/%d-%H:%M';
my %logon;

# Read files matching pattern
opendir(my $dh, $dir) or die "Cannot open directory $dir: $!";
my @files = grep { /^$file_pattern$/ && -f "$dir/$_" } readdir($dh);
closedir($dh);

# Sort files by modification time
@files = sort { -M "$dir/$a" <=> -M "$dir/$b" } (@files);

# DEBUG
# print(join(",\n", @files));

# Array to store matching lines
my @file_lines;
my $fh;

foreach my $file (@files) {
  if ( $file =~ /\.gz$/i ) {
    open($fh, '-|', "/usr/bin/gzip -dc $dir/$file") or die "Cannot open file $file: $!";
  } else {
    open($fh, '<', "$dir/$file") or die "Cannot open file $file: $!";
  }
  while (my $line = <$fh>) {
  	if ( $line =~ m/^(\d{4}\/\d{2}\/\d{2}-\d{2}:\d{2}).*LOGON.*benutzername=(\w+).*$/ ) {
  	  my $timestamp = $1;
  	  my $benutzer = $2;

      if ( exists $logon{$benutzer} ){
        if ( Time::Piece->strptime($timestamp, $timestamp_format) > Time::Piece->strptime($logon{$benutzer}, $timestamp_format) ) {
          # DEBUG
          # print("$benutzer: Timestamp $timestamp newer then $logon{$benutzer}\n");
          $logon{$benutzer} = $timestamp;
        }
      } else {
        $logon{$benutzer} = $timestamp;
      }


  	}
  }
  close($fh);
}

# DEBUG
# print Dumper(\%logon);


#
comp_users();


# Die Benutzer wurden aus der DB in eine Datei gespooled
# Hier werden dann die Benutzer in dem HASh mit den Benutzern in der Datei verglichen
# Der Output ist im CSV Format und kann in eine Datei redirected werden
sub comp_users {
  # Print CSV header
  print("Benutzer;Letzte Anmeldung\n");
  open(FH, '<', $sup_db_users_file) or die "Cannot open file sup_db_users_file: $!";

  while(<FH>){
  	# Remove new lines and carriage returns
  	$_ =~ s/\n//g;
  	$_ =~ s/\r//g;

    # Check if user found in logfile (hash)
  	if ( exists $logon{$_} ){
      print("$_;$logon{$_}\n");
  	} else {
      print("$_;Nicht gefunden\n");
  	}
  }

  close(FH);
}

