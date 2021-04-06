#!/usr/bin/perl
# Name: appVersion.pl
# Author: Jason Campisi
# Date: 4/6/2021
# Purpose: Tells you the version of a MacOS app installed in Applications folder
# License: Released under GPL v3 or higher. Details here http://www.gnu.org/licenses/gpl.html

use strict;
use Getopt::Long;

my ($app, $path, $help) = (0,"/Applications/",0);
GetOptions("a:s"  =>\$app,"p:s"  =>\$path , "help" =>\$help);

sub check(){ # check required data or if help was called
  return if ($help || $app ne "0");
  print <<EOD;
appVersion.pl Tells you the version of a MacOS app installed in Applications folder

    Ussage:        appVersion.pl -a AppName
    Optional:      -p "/Application/Path/" 
                   Default is "/Applications/" or you can override it
                   -help
    Requirement:   install the app you want to harvest this data from
        
        
Example: appVersion.pl -a VLC
3.0.12

EOD
    exit 0;    
}#end Check

check(); 

 my $r=`mdls -name kMDItemVersion "$path$app.app"`;
  $r =~ s/^kMDItemVersion = \"(.*)\"$/$1/g;  #harvest the app version number
  print "$r";
 
exit 0;
