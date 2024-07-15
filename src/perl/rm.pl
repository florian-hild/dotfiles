#!/usr/bin/perl -w

use strict;
use warnings;

use Getopt::Long qw(GetOptions);
Getopt::Long::Configure qw(gnu_getopt);
use File::Find;
use Time::Local;
use POSIX qw( strftime );
use Time::HiRes qw( time );

our $VERSION = '2.0';
my ( %parameters );
my ( $start, $end );
my ( $start_epoch, $end_epoch, $mtime );
my ( $start_year, $start_month, $start_day, $end_year, $end_month, $end_day );
my $matched_files = 0;
my $logfile = "rm_".strftime('%Y-%m-%d_%H_%m',localtime).".log";

if ( @ARGV == 0 && -t STDIN && -t STDERR ) {
  print("Kein Parameter angegeben.\n\n");
  $parameters{'help'} = 1;
}

GetOptions(
  \%parameters,
  'all|a',
  'help|?',
  'path|p=s',
  'start|s=s',
  'end|e=s',
  'dry|n',
  'yes|y',
  'verbose|v',
  'version|V' => sub{ print("$main::VERSION\n"); exit 0; }
);

if ( $parameters{'help'} ){
  print("
Description:
  Loescht rekursiv Dateien in einem angegebenen Zeitraum.

Usage:
  ${0} [options]...

Options:
  -a, --all             Delete all files
  -?, --help            Display this help and exit
  -p, --path            Path to directory (reqired)
  -s, --start           Start date (YYYY-MM-DD) (reqired if not all)
  -e, --end             End date (YYYY-MM-DD) (required if not all)
  -n, --dry             Dry-run. Just creating logfile
  -y, --yes             Automatically answer yes for all questions
  -v, --verbose         Print debugging messages
  -V, --Version         Display the version number and exit

Examples:
  Dry-run - Erstellt nur ein Log file
  ${0} -p \$PRINTS -s 2019-01-01 -e 2022-03-31 -n
");
  exit 0;
}

if ( ! $parameters{'path'} or ! -d $parameters{'path'} ){
  print("Ein gültiger Pfad muss mit angegeben werden.\n");
  exit 1;
}

if ( ! $parameters{'all'} ){
  if ( ! $parameters{'start'} or ! $parameters{'end'} ){
    print("Ein Start und End Datum muss mit angegeben werden.\n");
    exit 1;
  }

  if ( $parameters{'start'} !~ m/^([0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[1-2][0-9]|3[0-1]))$/ or $parameters{'end'} !~ m/^([0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[1-2][0-9]|3[0-1]))$/ ){
    print("Kein gültiges Datumsformat angegeben.\n");
    print("Gültiges Format = YYYY-MM-DD\n");
    exit 1;
  }

  ( $start_year, $start_month, $start_day ) = ( $parameters{'start'} =~ m/\b(\d{4})-(\d{2})-(\d{2})\b/ );
  ( $end_year, $end_month, $end_day ) = ( $parameters{'end'} =~ m/\b(\d{4})-(\d{2})-(\d{2})\b/ );
  print("Get files between: $start_year-$start_month-$start_day and $end_year-$end_month-$end_day\n");

  # Convert timestamp to epoch
  # Januar = 0 deshalb -1
  $start_epoch = timelocal( 00, 00, 00, $start_day, $start_month-1, $start_year );
  $end_epoch = timelocal( 00, 00, 00, $end_day, $end_month-1, $end_year );
  print("Get files between: $start_epoch and $end_epoch Unix time\n") if ( $parameters{'verbose'} );
}

$start = time();
printf("%-17s: %s\n", "Start at", strftime('%H:%M:%S', localtime));

open(FH, '>', $logfile) or die $!;
# Find dirs recursiv
printf("Get files in path \"%s\"\n", $parameters{'path'});
find( { wanted => \&process_file, no_chdir => 1 }, $parameters{'path'} );

sub process_file{
  if ( -f $_ && $_ !~ m/rm\.pl$/ && $_ !~ m/$logfile$/ ) {
    print("File: $_\n") if ( $parameters{'verbose'} );
    if ( ! $parameters{'all'} ){
      $mtime = (stat($_))[9];
      return if ( $mtime < $start_epoch or $mtime >= ($end_epoch+86400) ); # +1 Tag
    }

    if ( ! $parameters{'all'} ){
      printf FH ("%s | %s\n", strftime('%Y-%m-%d', gmtime($mtime)), $_);
    } else {
      printf FH ("%s\n", $_);
    }

    unlink $_ or warn "Unable to remove '$_': $!" if ( ! $parameters{'dry'} );

    $matched_files++;
  }
}

close(FH);
$end = time();
printf("%-17s: %s\n", "Finished at", strftime('%H:%M:%S', localtime));
printf("%-17s: %s\n", "Elapsed time", strftime('%T', gmtime $end - $start));
printf("%-17s: %s\n", "Files matched", $matched_files);
printf("%-17s: %s\n", "Logfile", $logfile." saved");
exit
