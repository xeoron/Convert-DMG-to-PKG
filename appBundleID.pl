#!/usr/bin/perl
# Name: appBundleID.pl
# Author: Jason Campisi
# Date: 8/7/2024
# Version v1.0.1
# Purpose: Tells you what a MacOS Application Bundle Identifier ID is
# Repository: https://github.com/xeoron/Convert-DMG-to-PKG
# License: Released under GPL v3 or higher. Details here http://www.gnu.org/licenses/gpl.html

use strict;
use Getopt::Long;

my ($app, $help) = ("",0);
GetOptions("a:s"  =>\$app, "help" =>\$help) or usage();

sub check(){ # check required data or if help was called
  if ($help or $app eq ""){
  print <<EOD;
appBundleID Tells you what a MacOS Application Bundle Identifier ID is.
Knowing this is useful MDM's for when converting DMG -> PKG files

    Usage:         appBundleID -a AppName
                   -help
    Requirement:   install the app you want to harvest this data from
        
        
Example 1: appBundleID -a VLC
org.videolan.vlc

Example 2: appBundleID -a "davinci resolve"
com.blackmagic-design.DaVinciResolveLite

Example 3: appBundleID -a /Applications/darktable.app
org.darktable
EOD
    exit 0;
  } #end if

}#end usage


check(); 

$app="/Applications/" . $app . ".app" if ($app !~m /^\/Applications\//);

print `osascript -e 'id of app "$app"'`;

exit 0;