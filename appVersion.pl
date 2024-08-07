#!/usr/bin/perl
# Name: appVersion.pl
# Author: Jason Campisi
# Date: 8/7/2024
# Version v1.0.1
# Purpose: Tells you the version of a MacOS app installed in Applications folder
# Repository: https://github.com/xeoron/Convert-DMG-to-PKG
# License: Released under GPL v3 or higher. Details here http://www.gnu.org/licenses/gpl.html


use strict;
use Getopt::Long;

my ($app, $path, $help) = ("","/Applications/",0);
GetOptions("a:s"  =>\$app, "p:s" =>\$path, "help" =>\$help) or usage();

sub usage(){ # check required data or if help was called
  if ($help or $app eq ""){
    print <<EOD;
appVersion.pl Tells you the version of a MacOS app installed in Applications folder

    Usage:         appVersion.pl -a AppName
    Optional:      -p "/Application/Path/" 
                   Default is "/Applications/" or you can override it
                   -help
    Requirement:   install the app you want to harvest this data from
        
        
Example 1 : appVersion.pl -a VLC
3.0.12

Example 2: appBundleID -a /Applications/darktable.app
3.4.1

EOD
      exit 0;
    }#end if
}#end Usage

usage();
$path = "" if $app =~m/^\/Applications\//;
$app =~s/\.app[\/]?$//i;

 my $r=`mdls -name kMDItemVersion "$path$app.app"`;
  $r =~ s/^kMDItemVersion = \"(.*)\"$/$1/g;  #harvest the app version number
  print "$r";
 
exit 0;
