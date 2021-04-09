#!/usr/bin/perl
# Name: app2pkg.pl
# Author: Jason Campisi
# Date: 4/9/2021
# Version 0.2 alpha
# Purpose: Convert installed apps in the Applications folder to a pkg installer
# Repository: https://github.com/xeoron/Manage_Mosyle_MDM_MacOS
# License: Released under GPL v3 or higher. Details here http://www.gnu.org/licenses/gpl.html


use strict;
use Getopt::Long;
use Scalar::Util qw(looks_like_number);
my ($path, $create) = ("","");
my ($list, $sortAlpha, $dryrun, $help)=(0, 0, 0, 0);
GetOptions( "l" =>\$list, "sort" =>\$sortAlpha, "dr" =>\$dryrun, "help" =>\$help) or usage();

my @applist; #sorted application list
my $appPick="";

sub usage(){ # check required data or if help was called
  print <<EOD;
app2pkg.pl Convert installed apps in the Applications folder to a pkg installer
    by asking you which program you can to harvest and convert into a deployment installer.

    Ussage:         app2pkg.pl 
    
    Optional        -help
                    -l Only list applications install.
                    -sort Sort the applications list alphanumerically.
    Requirement:    install the app you want to harvest this data from


EOD
    exit 0;    
}#end usage

sub getAppList(){ #grab App list, sort and print
my @alist=sort(`ls /Applications/`); 
 foreach ( @alist ) {  $_=~s/[\n|\r]?$//; } #strip out \n & \r chars
 if (!$sortAlpha){ @applist = sort { length $a <=> length $b } @alist; } #sort by length
 else { @applist = @alist;}
 
 my ($c, $pipe) =(0, "|");
  for my $app (@applist){
     if (0 == $c % 2) { #if even number
         printf("  %s %02d. %s ", $pipe, $c, $app ) if ($app ne "");
         print "\n" if $c == $#applist; #final loop close the line
     }else{
         printf("%s %02d. %s\n", "or", $c, $app ) if ($app ne "");
     }
     $c++;
  }
}#end getAppList

sub askTF($){                #ask user question returning True/False. Parameters = $message
  my($msg) = @_; my $answer = "";
  
  print $msg;
  until(($answer=<STDIN>)=~m/^(n|y|no|yes)/i){ print"$msg"; }

 return $answer=~m/[n|no]/i;# ? 1 : 0 	 bool value of T/F
}#end askTF($)

sub findApp(){
 getAppList();
 do {    print "    --> Choose the program to build a pkg installer from /Applications/ [0-$#applist]: ";
         my $appNumber = <STDIN>;
         chomp $appNumber;
         until ( looks_like_number($appNumber) && $appNumber<= $#applist){ #isValid number within range?
            print "     -> Choose a app number! [0-$#applist]: ";
            $appNumber = <STDIN>;
            chomp $appNumber;
         }
         $appPick=$applist[$appNumber];

         print"    ~ AppName $appNumber is $appPick\n";
    } while (askTF("      Does this info look correct? [Yes/No]: ")); 
       
       $path="/Applications/$appPick";
       #Create package build name 
         my $ver=`mdls -name kMDItemVersion "/Applications/$appPick"`; chomp $ver; #get app version
         #harvest the app version number 
         $ver =~ s/^kMDItemVersion = \"(.*)\"$/$1/g;
         $appPick =~s/\.app$//i;
        $create = "$appPick-$ver.pkg";
}#end findApp()


usage() if $help;
if ($list){ getAppList(); exit 0;}
findApp();

 if ($dryrun){
    print " Compile command:\n  sudo productbuild --component$path $create\n";
 }else{
    print "~~~~############ Alpha Code.... build will fail! ############~~~~\n";
    system ("sudo productbuild --component$path $create");
 }
