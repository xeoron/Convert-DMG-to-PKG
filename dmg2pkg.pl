#!/usr/bin/perl
# Name: dmg2pkg.pl
# Author: Jason Campisi
# Date: 5/4/2021
# Version: 1.2.0
# Purpose: Convert mounted dmg file into a pkg installer
# Repository: https://github.com/xeoron/Manage_Mosyle_MDM_MacOS
# License: Released under GPL v3 or higher. Details here http://www.gnu.org/licenses/gpl.html

use strict;
use Getopt::Long;
use Scalar::Util qw(looks_like_number);

my ($volume, $ver, $id, $create, $volName, $appPick)=("","","","","", ""); 
my ($verbose, $help, $harvest, $list, $sortAlpha, $dryrun, $only) = (0,0,0,0,0,0,0);
my @applist; #sorted application list

GetOptions( "n=s" =>\$volume,  "v=s" =>\$ver,   "id=s" =>\$id,
            "c=s"  =>\$create, "help" =>\$help, "verbose" =>\$verbose,
            "a" =>\$harvest,   "l" =>\$list,    "sort" =>\$sortAlpha,
            "dr" =>\$dryrun,   "o" =>\$only) or check();

sub usage(){ # check required data or if help was called

  print <<EOD;
dmg2pkg Converts mounted dmg install folders and convert them to a pkg installer 
    package for MDM deployment. 

    Usage:         dmg2pkg -n VolumeNAME -v appVersion -s -i appBundleIdentifier appPackageName
            
                    -n Name of mounted DMG Volume
                    -v Version The application encoded version number. Mke sure to sync this with the version you are 
                        trying to deploy (if it’s VLClan v3.1.12, then this parameter is 3.1.12). How to find 
                        the encoded version number go to the section Extra Detail for more information
                    -id Application bundle identifier. Go to the secion Extra Detail for more information
                    -c Name of the PKG file you will create in the current folder. Optional, iff -a is used.
                    
    Optional        -help
                    -verbose
                    -dr Dry run mode. It will confirm everything and not try to build anything.
                    -l list everything found in the folder /Applications/
                    -o Only list programs found in the /Applications/ Applications folder.
                    -sort List of Applications sorted alphanumerically.
                    -a AppData...gather the required app version number and bundle id info automaticly.
                        This displays a list of installed apps and asks you which one is the target.
                        -c is optional, because it will harvest that information out of /Applications/
                        Requires the app to be installed in /Applications/ folder.

    Requirement:    Must have a dmg file you have opened/mounted for this program to work
                    -a requires the app to be installed in /Applications
    
    Extra Detail:   Please use the following apps to gather the required version and id informaiton:
                    The application you want to conver to a pkg must be installed for this to work.
                        
                        appBundleID.pl to discover/harvest the identifier code of a program.
                        
                        appVersion.pl to discoer/harvest the application version number that you 
                            want to convert to a pkg installer file. It is very important you use
                            the version it is signed with.

Examples:
  List the Apps in /Applications/
    dmg2pkg -o
  
  For best results, provide all the informaiton requred with vlc-3.0.12-intel64.dmg mounted file.
    dmg2pkg -n "/Volumes/VLC media player" -v 3.0.12 -id org.videolan.vlc -s -c VLC
        --> Creates VLC-3.0.12.pkg

  Have it grather most of the information for you with a vlc-3.0.12-intel64.dmg mounted file
    dmg2pkg -a -n /Volumes/VLC\ media\ player/
        --> Creates VLC-3.0.12.pkg

EOD
    exit 0;    
}#end usage

sub harvestData(){ #harvest appVersion, app bundle ID and app name

if ($harvest){ #gather app bundle ID and appversion number
       print " Harvest app data\n" if ($verbose);
       getAppList(); #grab a list of files in /Applications/
       
       do {
         print "    --> To gather the App Bundle ID and the App Version installed in /Applications/\n";
         print "        Choose the number of the program to harvest it from [0-$#applist]: ";
         my $appNumber = <STDIN>; chomp $appNumber;
         until ( looks_like_number($appNumber) && $appNumber <= $#applist ){ #isValid number within range?
            print "     -> Choose a app number! [0-$#applist]: ";
            $appNumber = <STDIN>; chomp $appNumber;
         }
         $appPick = $applist[$appNumber];
         
         #get app bundle id from mounted volume
         $id=`osascript -e 'id of app "/Applications/$appPick"'`; chomp $id;
          
         #get app version number from installed copy
         $ver=`mdls -name kMDItemVersion "/Applications/$appPick"`; chomp $ver;
         
         #harvest the app version number 
         $ver =~ s/^kMDItemVersion = \"(.*)\"$/$1/g;
         if ($create eq ""){
            $create = $appPick;
            $create =~s/\.app$//;
         }
         print"  ~ AppName $appNumber is $appPick\n  ~ ID is $id\n  ~ Version is $ver\n";
       } while (askTF("    Does this info look correct? [Yes/No]: ")); 
  return 1;   
 }
 return 0;
}#end harvestData()

sub check(){ #varify data
 
   usage() if $help;
    if ($list or ($only and $volume eq "")){ getAppList(); exit 0; }   #display all /applications/
    
    print "volume name: $volume\n" if($verbose);
    if ($volume eq ""){##check if Volume exists and format info
        warn " Warning: DMG Volume location not provided!\n\n";
        usage();
    }
    if (not -d $volume){ #does volume exist?
        warn " Warning: DMG Volume not detected. Please mount/click the DMG file to be findable!\n\n";
        usage();
    }
    print " DMG Mounted Volume found: $volume\n" if ($verbose);
    $volume =~s/\\//g;  # remove forward slashs
    my $vol ="/Volumes/";
     $volume=$vol . $volume if (not $volume =~ m/^$vol/); #add /volumes/ if not there so "foo" becomes /volumes/foo
     $volName=$1 if ($volume =~ m/^$vol(.*)\/$/); #harvest app name
    print " Program Name: $volName\n" if ($verbose);

    if (! harvestData() ){
        if ($ver eq ""){ warn "-v App Version not provided\n\n"; exit 1; }
        if ($id eq ""){ warn "-i App Bundle ID not provided\n\n"; exit 1; }
        if ($create eq ""){ warn "-c Name of package to create was not provided\n\n"; exit 1; }
        elsif ($create =~m/\.pkg$/){ $create =~s/\.pkg$//; } #strip extension???
    }
}#end check()

sub askTF($){                #ask user question returning True/False. Parameters = $message
  
  my($msg) = @_; my $answer = "";
  print $msg;
  until( ($answer =<STDIN>)=~m/^(n|y|no|yes)/i ){ print"$msg"; }

 return $answer =~m/[n|no]/i;# ? 1 : 0 	 bool value of T/F
}#end askTF($)

sub getAppList(){ #grab App list, sort and print

my @alist =sort(`ls /Applications/`); #grab list of files
my ($leftCount, $rightCount, $pipe) =(0, 0, "|");
my (@groupsOfTwo, @left, @right);

  foreach ( @alist ) {  $_ =~s/[\n|\r]?$//; } #strip out \n & \r chars
  if (!$sortAlpha){ @applist = sort { length $a <=> length $b } @alist; } #sort by length
  else { @applist = @alist;}
 
  @applist = grep {/.?\.app$/i} @applist if ($only); #only display files ending in .app
 
    if (0 == $#applist % 2) { $rightCount = ($#applist/2)+1; } #if even number
    else{ $rightCount = ($#applist+1)/2; } #else odd number
 
 #build AoA with rows of 2 columns
 use List::MoreUtils 'natatime';
    my $iter = natatime 2, @applist; 
    while (my @vals = $iter->()) { push @groupsOfTwo, \@vals; }

if ($list){ print "Installed apps to harvest the Version Number and App BundleID from\n"; }
else{ print "Match the dmg app: Choose the installed app to harvest the Version Number and App BundleID from\n" }

 #display results
    for my $row (@groupsOfTwo) {   
        $rightCount = "" if($row->[1] eq "" ); #final case when an odd number only
        format STDOUT =
@<< @< @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< @<< @< @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        $leftCount, $pipe, $row->[0], $rightCount, $pipe, $row->[1]
.
        write;
         
        push (@left, $row->[0]);
        push (@right, $row->[1]);
        $leftCount++; $rightCount++;
    }     

    #re-order the @applist so number lists match index
    for my $value (@right) { $left[++$#left] = $value; } #bc push (@a1, @a2) is buggy on macOS11
    pop @left if ($left[$#left] eq ""); #last one is empty if odd number... shed it
    @applist = @left;
}#end getAppList()


#### MAIN ####

print "Welcome to dmg2pkg ...Checking all the data is in order...\n" if ($verbose);
check();

print " Compile command:\n  pkgbuild --root \"$volume\" --version $ver --identifier $id --install-location \/Applications $create-$ver.pkg\n" if ($verbose or $dryrun);

system("pkgbuild --root \"$volume\" --version $ver --identifier $id --install-location \/Applications $create-$ver.pkg") if (!$dryrun);
 
exit 0;