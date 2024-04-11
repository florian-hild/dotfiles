#!/usr/bin/perl -w

################################################################################
# Kurzbeschr. :
# Entwickler  : F.Hild
# Datum       :
# Ablageort   :
# Git-Repo    :
# Beschreibung:
################################################################################

use strict;
use warnings;

use Net::LDAP;

our $VERSION = '1.0';

my $server = "vmservices";
my $ldap = Net::LDAP->new( $server ) or die $@;
$ldap->bind;

my $result = $ldap->search(
    #base   => "dc=sup-logistik,dc=de",
    # filter => "cn=*eghm*",
    filter => "cn=*",
);

die $result->error if $result->code;

printf "COUNT: %s\n", $result->count;

#foreach my $entry ($result->entries) {
#    $entry->dump;
#}

foreach my $entry ($result->entries) {
  printf "%s <%s>\n",
        $entry->get_value("cn"),
        ($entry->get_value("orclNetDescString") || '');
}

$ldap->unbind;
