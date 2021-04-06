#!/usr/bin/perl
# Name: dmg2pkg.pl
# Author: Jason Campisi
# Date: 4/6/2021
# Purpose: Convert mounted dmg file into a pkg installer
# Repository: https://github.com/xeoron/Manage_Mosyle_MDM_MacOS
# License: Released under GPL v3 or higher. Details here http://www.gnu.org/licenses/gpl.html


use strict;
use Getopt::Long;

my ($volume, $ver, $id, $save, $help, $volName, $verbose) = ("","","","",0, "", 0);
my $vol="/Volumes/";
GetOptions( "n:s" =>\$volume, "v:s" =>\$ver, "i:s" =>$id,
            "s:s"  =>\$save,  "help" =>\$help, "verbose" =>\$verbose) or usage();
            
sub usage(){ # check required data or if help was called

  print <<EOD;
dmg2pkg.pl Converts mounted dmg install folders and convert them to a pkg installer package for MDM
    deployment. 

    Ussage:         dmg2pkg.pl -n VolumeNAME -v appVersion -s -i appBundleIdentifier path-to-save-Mac
            
                    -n Name of mounted DMG Volume
                    -v version The application encoded version number. Mke sure to sync this with the version you are 
                        trying to deploy (if it’s VLClan v3.1.12, then this parameter is 3.1.12). How to find 
                        the encoded version number go to the section Extra Detail for more information
                    -i application bundle identifier. Go to the secion Extra Detail for more information
                    -s is the locaiton & name of the installer pkg file you want to save to
                    
    Optional        -help
                    -verbose

    Requirement:    Must have a dmg file you have opened/mounted for this program to work
    
    Extra Detail:   Please use the following apps to gather the required version and id informaiton:
                    The application you want to conver to a pkg must be installed for this to work.
                        
                        appBundleID.pl to discover/harvest the identifier code of a program.
                        
                        appVersion.pl to discoer/harvest the application version number that you 
                            want to convert to a pkg installer file. It is very important you use
                            the version it is signed with.
                        
    
        
Example: dmg2pkg.pl -n "/Volumes/VLC media player" -v 3.1.12 -i org.videolan.vlc -s /Users/NotSure/Downloads/VLC
Deployment package created --> /Users/NotSure/Downloads/VLC-3.1.12.pkg 

EOD
    exit 0;    
}#end usage

sub check(){
   usage() if $help;
   usage() if ($volume eq ""); #check if Volume exists and format info
    $volume=~s/\\//g;  # remove forward slashs
    $volume=$vol . $volume if (not $volume =~ m/^$vol/); #add /Volumes if not there
    $volName=$1 if ($volume =~ m/^$vol(.*)\/$/); #harvest app name
    print "Program Name: $volName\n" if $verbose;
    usage() if (not -d $volume); #does volume exist?
    print "DMG Mounted Volume found: $volume\n" if $verbose;
    
    #check the rest of the data if it is present to work with
    usage() if (($save eq "") and ($ver eq "") and ($id eq ""));

}#end check

check();

<<END 
pkgbuild --root /Volumes/dmgNAME --version 1.1 --identifier com.example.sample --install-location / Sample-1.1.pkg

Parameters Explained
/Volumes/DMGName The full path to the mounted DMG file.

version The application version, make sure to sync this with the version you are trying to deploy (if it’s Zoom 5.6, then this parameter is 5.6).

identifier The app identifier, if you don’t know the value, follow this guide (The Bundle ID is what you are looking for) to get it.

install-location The location where the PKG will be installed, leave it as it is.

Sample-1.0.pkg The full path and name of the PKG file that will be generated, adjust it as needed.
END
