#!/usr/bin/perl
# Name: dmg2pkg.pl
# Author: Jason Campisi
# Date: 4/9/2021
# Version: 1.1
# Purpose: Convert mounted dmg file into a pkg installer
# Repository: https://github.com/xeoron/Manage_Mosyle_MDM_MacOS
# License: Released under GPL v3 or higher. Details here http://www.gnu.org/licenses/gpl.html

use strict;
use Getopt::Long;
use Scalar::Util qw(looks_like_number);

my ($volume, $ver, $id, $create, $volName)=("","","","",""); 
my ($verbose, $help, $harvest, $list, $sortAlpha, $dryrun, $only) = (0,0,0,0,0,0,0);
my @applist; #sorted application list
my $appPick="";
my $vol="/Volumes/";

GetOptions( "n=s" =>\$volume,  "v=s" =>\$ver,   "id=s" =>\$id,
            "c=s"  =>\$create, "help" =>\$help, "verbose" =>\$verbose,
            "a" =>\$harvest,   "l" =>\$list,    "sort" =>\$sortAlpha,
            "dr" =>\$dryrun,   "o" =>\$only) or check();

sub usage(){ # check required data or if help was called

  print <<EOD;
dmg2pkg.pl Converts mounted dmg install folders and convert them to a pkg installer 
    package for MDM deployment. 

    Ussage:         dmg2pkg.pl -n VolumeNAME -v appVersion -s -i appBundleIdentifier path-to-save-MyMacApp
            
                    -n Name of mounted DMG Volume
                    -v Version The application encoded version number. Mke sure to sync this with the version you are 
                        trying to deploy (if it’s VLClan v3.1.12, then this parameter is 3.1.12). How to find 
                        the encoded version number go to the section Extra Detail for more information
                    -id Application bundle identifier. Go to the secion Extra Detail for more information
                    -c Name of the PKG file you will create in the current folder. Optional, iff -a is used.
                    
    Optional        -help
                    -verbose
                    -dr Dry run mode. It will confirm everything and not try to build anything.
                    -l list what is installed Applications found in /Applications/
                    -o Only list programs found in the Applications founder
                    -sort List of Applications sorted alphanumerically.
                    -a AppData...gather the required app version number and bundle id info automaticly.
                        This displays a list of installed apps and asks you which one is the target.
                        -c is optional, because it will harvest that information out of /Applications/
                        Requires the app to be installed in /Applications/ folder.

    Requirement:    Must have a dmg file you have opened/mounted for this program to work
    
    Extra Detail:   Please use the following apps to gather the required version and id informaiton:
                    The application you want to conver to a pkg must be installed for this to work.
                        
                        appBundleID.pl to discover/harvest the identifier code of a program.
                        
                        appVersion.pl to discoer/harvest the application version number that you 
                            want to convert to a pkg installer file. It is very important you use
                            the version it is signed with.

Examples:
  List the Apps in /Applications/
    dmg2pkg.pl -l
  
  Provide all the informaiton requred with vlc-3.0.12-intel64.dmg mounted file
    dmg2pkg.pl -n "/Volumes/VLC media player" -v 3.0.12 -id org.videolan.vlc -s -c VLC
        --> Creates VLC-3.0.12.pkg

  Have it grather most of the information for you with a vlc-3.0.12-intel64.dmg mounted file
    dmg2pkg.pl -a -n /Volumes/VLC\ media\ player/
        --> Creates VLC-3.0.12.pkg

EOD
    exit 0;    
}#end usage

sub check(){ #varify data
 
   usage() if $help;
   if ($list){getAppList(); exit 1; }   #display all /applications/
   if ($volume eq ""){##check if Volume exists and format info
        warn " Warning: DMG Volume location provided!\n\n";
        exit 1;
   } 
    $volume=~s/\\//g;  # remove forward slashs
    $volume=$vol . $volume if (not $volume =~ m/^$vol/); #add /volumes/ if not there so "foo" becomes /volumes/foo
    $volName=$1 if ($volume =~ m/^$vol(.*)\/$/); #harvest app name
    print " Program Name: $volName\n" if $verbose;
    if (not -d $volume){ #does volume exist?
        warn " Warning: DMG Volume not detected. Please mount/click the DMG file to be findable!\n";
        exit 1;
    }
    print " DMG Mounted Volume found: $volume\n" if $verbose;
    
    #check the rest of the data if it is present to work with
    if ($harvest){ #gather app bundle ID and appversion number
       print " Harvest appData\n" if $verbose;
       getAppList();
       
       do {
         print "    --> To gather the App Bundle ID and the App Version installed in /Applications/\n";
         print "        Choose the number of the program to harvest it from [0-$#applist]: ";
         my $appNumber = <STDIN>;
         chomp $appNumber;
         until ( looks_like_number($appNumber) && $appNumber<= $#applist){ #isValid number within range?
            print "     -> Choose a app number! [0-$#applist]: ";
            $appNumber = <STDIN>;
            chomp $appNumber;
         }
         $appPick=$applist[$appNumber];
         #get app bundle id
         $id=`osascript -e 'id of app "$appPick"'`;
          chomp $id;
          
         #get app version number
         $ver=`mdls -name kMDItemVersion "/Applications/$appPick"`; chomp $ver;
         #harvest the app version number 
         $ver =~ s/^kMDItemVersion = \"(.*)\"$/$1/g;
         if ($create eq ""){
            $create=$appPick;
            $create=~s/\.app$//;
         }
         print"  ~ AppName $appNumber is $appPick\n  ~ ID is $id\n  ~ Version is $ver\n";
       } while (askTF("    Does this info look correct? [Yes/No]: ")); 
       
    }else{
        if ($ver eq ""){ warn "-v App Version not provided\n\n"; exit 1; }
        if ($id eq ""){ warn "-i App Bundle ID not provided\n\n"; exit 1; }
        if ($create eq ""){ warn "-c Name of package to create was not provided\n\n"; exit 1; }
        elsif ($create =~m/\.pkg$/){ $create =~s/\.pkg$//; } #strip extension???
    }
}#end check()

sub askTF($){                #ask user question returning True/False. Parameters = $message
  my($msg) = @_; my $answer = "";
  
  print $msg;
  until(($answer=<STDIN>)=~m/^(n|y|no|yes)/i){ print"$msg"; }

 return $answer=~m/[n|no]/i;# ? 1 : 0 	 bool value of T/F
}#end askTF($)

sub getAppList(){ #grab App list, sort and print
my @alist=sort(`ls /Applications/`); 
 foreach ( @alist ) {  $_=~s/[\n|\r]?$//; } #strip out \n & \r chars
 if (!$sortAlpha){ @applist = sort { length $a <=> length $b } @alist; } #sort by length
 else { @applist = @alist;}
 
 @applist = grep {/.?\.app$/i} @applist if($only); #only display files ending in .app
 
 my ($c, $mid, $numSub, $pipe) =(0, 0, 2, "|");
 my @groupsOfTwo;
 #set mid count number
    if (0 == $#applist % 2) { $mid = $#applist/2; } #if even number
    else{ $mid = ($#applist+1)/2; } #else off number
 
 #build AoA with rows of 2 columns
 use List::MoreUtils 'natatime';
    my $iter = natatime $numSub, @applist;
    while (my @vals = $iter->()) { push @groupsOfTwo, \@vals; }

 #display results
    for my $row (@groupsOfTwo) {
        format STDOUT =
@<< @< @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< @<< @< @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        $c, $pipe, $row->[0], $mid, $pipe, $row->[1]
.
         write;
         $c++; $mid++;
      }
}#end getAppList


#### MAIN ####

print " Welcome to dmg2pkg\n ...Checking all the data is in order...\n" if $verbose;
check();

print " Compile command:\n  pkgbuild --root \"$volume\" --version $ver --identifier $id --install-location \/Applications $create-$ver.pkg\n" if $verbose or $dryrun;

system("pkgbuild --root \"$volume\" --version $ver --identifier $id --install-location \/Applications $create-$ver.pkg") if (!$dryrun);
 
exit 0;