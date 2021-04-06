#!/usr/bin/perl
# Name: app2pkg.pl
# Author: Jason Campisi
# Date: 4/6/2021
# Purpose: Convert installed apps in the Applications folder to a pkg installer
# Repository: https://github.com/xeoron/Manage_Mosyle_MDM_MacOS
# License: Released under GPL v3 or higher. Details here http://www.gnu.org/licenses/gpl.html


use strict;
use Getopt::Long;

my ($path, $save, $help) = ("","",0);
GetOptions("p:s" =>\$path, "s:s"  =>\$save, "help" =>\$help) or usage();

sub usage(){ # check required data or if help was called
  return if ($help || ($save ne "" (and $path ne ""));
  print <<EOD;
app2pkg.pl Convert installed apps in the Applications folder to a pkg installer

    Ussage:         app2pkg.pl -p /path/toMac.app -s path-to-save-Mac.pkg
    
                    -p is the location where the mac.app folder/file is stored
                    -s is the locaiton & name of the installer pkg file you want to save to
                    
    Optional        -help
    Requirement:    install the app you want to harvest this data from
        
        
Example: app2pkg.pl -p /Applications/VLC.app -s $HOME/Downloads/VLC
Deployment package created --> $HOME/Downloads/VLC-1.0.pkg 

EOD
    exit 0;    
}#end usage

usage(); 

print "sudo productbuild --component$path $save.pkg\n";

#sudo productbuild --component/path1/macapp.app /path2/packagename.pkg

# component  The path to the .app file that will be used during PKG generation.
#
# path_to_savedpackage/packagename.pkg The destination path for the generated PKG file and desired name.