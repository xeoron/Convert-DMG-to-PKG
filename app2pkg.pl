#!/usr/bin/perl
# Name: app2pkg.pl
# Author: Jason Campisi
# Date: 7/18/2024
# Version 1.1.1 
# Purpose: Convert installed apps in the Applications folder to a pkg installer
# Repository: https://github.com/xeoron/Manage_Mosyle_MDM_MacOS
# License: Released under GPL v3 or higher. Details here http://www.gnu.org/licenses/gpl.html


use strict;
use Getopt::Long;
use Scalar::Util qw(looks_like_number);
use Data::Dumper;
my ($path, $create, $appPick) = ("","", "");
my ($list, $sortAlpha, $dryrun, $only, $help)=(0, 0, 0, 0, 0);
GetOptions( "l" =>\$list, "s|sort" =>\$sortAlpha, "dr" =>\$dryrun, 
            "o" =>\$only, "h|help" =>\$help) or usage();

my @applist; #sorted application list

sub usage(){ # check required data or if help was called
  print <<EOD;
app2pkg Convert installed apps in the Applications folder to a pkg installer
    by asking you which program you can to harvest and convert into a deployment installer.

    Usage:          app2pkg
    
    Optional        
                    -l      List everything found in the folder /Applications/
                    -dr     Dry run mode
                    -o      Only list programs found in the /Applications/ Applications folder.
                    -s|sort Sort the applications list alphanumerically.
                    -h|help 

    Requirement:    install the app you want to harvest this data from


EOD
    exit 0;    
}#end usage

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

if ($list){ print "Installed apps to the Version Number from\n"; }
else{ print "Match the dmg app: Choose the installed app to harvest the Version Number from\n" }

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

sub askTF($){                #ask user question returning True/False. Parameters = $message
  my($msg) = @_; my $answer = "";
  
  print $msg;
  until( ($answer=<STDIN>) =~m/^(n|y|no|yes)/i ){ print"$msg"; }

 return $answer =~m/[n|no]/i;# ? 1 : 0 	 bool value of T/F
}#end askTF($)

sub findApp(){
 getAppList();
 do {    print "    --> Choose the program to build a pkg installer from /Applications/ [0-$#applist]: ";
         my $appNumber = <STDIN>;
         chomp $appNumber;
         until ( looks_like_number($appNumber) && $appNumber <= $#applist){ #isValid number within range?
            print "     -> Choose a app number! [0-$#applist]: ";
            $appNumber = <STDIN>;
            chomp $appNumber;
         }
         $appPick=$applist[$appNumber];

         print"    ~ AppName $appNumber is $appPick\n";
    } while (askTF("      Does this info look correct? [Yes/No]: ")); 
       
       $path ="/Applications/$appPick"; #Create package build name 
         my $ver =`mdls -name kMDItemVersion "$path"`; chomp $ver; #get app version
         #harvest the app version number 
         $ver =~ s/^kMDItemVersion = \"(.*)\"$/$1/g;
         $appPick =~s/\.app$//i;
         $create = "$appPick-$ver.pkg";
}#end findApp()


usage() if $help;
 print "Welcome to app2pkg\n";
 
 if ($list or ($only and $list)){ getAppList(); exit 0;}
 findApp();

 if ($dryrun){
    print " Compile command:\n  sudo productbuild --component '$path' $create\n";
 }else{
    system ("sudo productbuild --component '$path' $create");
 }
