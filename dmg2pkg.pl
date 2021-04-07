#!/usr/bin/perl
# Name: dmg2pkg.pl
# Author: Jason Campisi
# Date: 4/6/2021
# Purpose: Convert mounted dmg file into a pkg installer
# Repository: https://github.com/xeoron/Manage_Mosyle_MDM_MacOS
# License: Released under GPL v3 or higher. Details here http://www.gnu.org/licenses/gpl.html


use strict;
use Getopt::Long;

my ($volume, $ver, $id, $save, $help, $volName, $verbose, $harvest) = ("","","","",0, "", 0,0);
my $vol="/Volumes/";
GetOptions( "n:s" =>\$volume, "v:s" =>\$ver,    "i:s" =>$id,
            "s:s"  =>\$save,  "help" =>\$help,  "verbose" =>\$verbose,
            "a" =>\$harvest) or check();
            
sub usage(){ # check required data or if help was called

  print <<EOD;
dmg2pkg.pl Converts mounted dmg install folders and convert them to a pkg installer 
    package for MDM deployment. 

    Ussage:         dmg2pkg.pl -n VolumeNAME -v appVersion -s -i appBundleIdentifier path-to-save-MyMacApp
            
                    -n Name of mounted DMG Volume
                    -v Version The application encoded version number. Mke sure to sync this with the version you are 
                        trying to deploy (if it’s VLClan v3.1.12, then this parameter is 3.1.12). How to find 
                        the encoded version number go to the section Extra Detail for more information
                    -i Application bundle identifier. Go to the secion Extra Detail for more information
                    -s This is the locaiton & name of the installer pkg file you want to save to
                    
    Optional        -help
                    -verbose
                    -a AppData...gather the required app version number and bundle id info automaticly.
                        Requires the app to be installed in /Applications/ folder

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

sub check(){ #varify data

   usage() if $help;
   usage() if ($volume eq ""); #check if Volume exists and format info
    $volume=~s/\\//g;  # remove forward slashs
    $volume=$vol . $volume if (not $volume =~ m/^$vol/); #add /volumes/ if not there so "foo" becomes /volumes/foo
    $volName=$1 if ($volume =~ m/^$vol(.*)\/$/); #harvest app name
    print " Program Name: $volName\n" if $verbose;
    usage() if (not -d $volume); #does volume exist?
    print " DMG Mounted Volume found: $volume\n" if $verbose;
    
    #check the rest of the data if it is present to work with
   if ($harvest){
       #gather app bundle ID and appversion number
       print " Harvest mode\n" if $verbose;
       do {
        my $appName = ask(" Name of the program to gather id and version info from? ");
            chomp $appName;
            
         #get app bundle id
         $id=`osascript -e 'id of app "$appName"'`;
          chomp $id;
         #get app version number
         $ver=`mdls -name kMDItemVersion "/Applications/$appName.app"`;
          chomp $ver;
          $ver =~ s/^kMDItemVersion = \"(.*)\"$/$1/g;  #harvest the app version number
         
         print"  AppName is $appName\n  ID is $id\n  Version is $ver\n"; # if $verbose;
       } while (askTF("Do you want to use this data? [Yes/No]: ")); 
       
   }else{
       usage() if ($ver eq "") and ($id eq "");
    
   }
   usage() if ($save eq "");

}#end check

sub ask($){                #ask the user a question. Parameters = $message
  my($msg) = @_; my $answer = "";
  print $msg;
  return $answer=<STDIN>;
}#end ask($)

sub askTF($){                #ask user question returning True/False. Parameters = $message
  my($msg) = @_; my $answer = "";
  
  print $msg;
  until(($answer=<STDIN>)=~m/^(n|y|no|yes)/i){ print"$msg"; }

 return $answer=~m/[n|no]/i;# ? 1 : 0 	 bool value of T/F
}#end askTF($)

#### MAIN ####
print " Welcome to dmg2pkg\n ...Checking all the data is in order...\n" if $verbose;
check();
print " Compiling...." if ($verbose);

system("pkgbuild --root \"$volume\" --version $ver --identifier $id --install-location / $save-$ver.pkg");

exit 0;