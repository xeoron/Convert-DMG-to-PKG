#!/usr/bin/perl
# Name: appBundleID.pl
# Author: Jason Campisi
# Date: 4/6/2021
# Purpose: Tells you what a MacOS Application Bundle Identifier ID is
# Repository: https://github.com/xeoron/Manage_Mosyle_MDM_MacOS
# License: Released under GPL v3 or higher. Details here http://www.gnu.org/licenses/gpl.html

use strict;
use Getopt::Long;

my ($app, $help) = ("",0);
GetOptions("a:s"  =>\$app, "help" =>\$help) or usage();

sub check(){ # check required data or if help was called
  return if ($help || $app ne "");
  print <<EOD;
appBundleID Tells you what a MacOS Application Bundle Identifier ID is.
Knowing this is useful MDM's for when converting DMG -> PKG files

    Ussage:        appBundleID.pl -a AppName
                   -help
    Requirement:   install the app you want to harvest this data from
        
        
Example: appBundleID.pl -a VLC
org.videolan.vlc

EOD
    exit 0;    
}#end usage


check(); 

 my $r=`osascript -e 'id of app "$app"'`;
  print "$r";

exit 0;