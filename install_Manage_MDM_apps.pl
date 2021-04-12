#!/bin/sh -e
#Author: Jason Campisi
#Filename: install_Manage_MDM_apps
# Description: install the Manage Mosyle MDM MacOS apps
#Date: 4/12/2021
#version 1.0.0 For MacOS X or higher
#Project: https://github.com/xeoron/Manage_Mosyle_MDM_MacOS
#Released under the GPL v3 or higher

EXT="pl"
NAME1="appBundleID"
FILE1="$NAME1.$EXT"

NAME2="appVersion"
FILE2="$NAME2.$EXT"

NAME3="dmg2pkg"
FILE3="$NAME3.$EXT"

NAME4="app2pkg"
FILE4="$NAME4.$EXT"

LOCATION="/opt/local/bin/"
echo "installer for: $NAME1, $NAME2, $NAME3, $NAME4\n";

echo " Checking for Perl at /usr/bin/perl ...";
if [ "$(whereis perl)" != '/usr/bin/perl' ]; then
	echo " Error: Perl can not be found.";
	echo " ->If it is installed, then make a symlink that points /usr/bin/perl to the right location, else please install it.";
	exit 1;
else 
	echo " ...Perl found!\n";
fi

echo " Checking if you have the clearance to install this ...";
if [ "$(whoami)" != 'root' ]; then
	echo " You do not have permission to install ./$FILE1, ./$FILE2, ./$FILE3";
	echo " ->You must be a root user.";
	echo " ->Try instead: sudo $0";
	exit 1;
else
	echo " Root access granted for $0\n";	
fi

echo " Installing $NAME1, $NAME2, $NAME4 to $LOCATION ...\n";

#appBundleID
 echo " Checking if '$FILE1' exists in the current folder..."
   if [ ! -n "$FILE1" ]; then
      echo "   Error - Filename is not set!"
      exit 1;
   elif [ ! -e "$FILE1" ]; then
      echo "   Error - The location of '$FILE1' does not exist!"
      exit 1;
   fi
 echo " ...found!\n";
 echo " Installing $NAME1...";
 cp ./$FILE1 $LOCATION$NAME1 
 echo "  Setting file to executable...\n";
 chmod +x ./$FILE1

#appVersion
 echo " Checking if '$FILE2' exists in the current folder..."
   if [ ! -n "$FILE2" ]; then
      echo "   Error - Filename is not set!"
      exit 1;
   elif [ ! -e "$FILE2" ]; then
      echo "   Error - The location of '$FILE2' does not exist!"
      exit 1;
   fi
 echo " ...found!\n";
 echo " Installing $NAME2...";
 cp ./$FILE2 $LOCATION$NAME2
 echo "  Setting file to executable...\n";
 chmod +x ./$FILE2

#dmg2pkg
 echo " Checking if '$FILE3' exists in the current folder..."
   if [ ! -n "$FILE3" ]; then
      echo "   Error - Filename is not set!"
      exit 1;
   elif [ ! -e "$FILE3" ]; then
      echo "   Error - The location of '$FILE3' does not exist!"
      exit 1;
   fi
 echo " ...found!\n";
 echo " Installing $NAME3...";
 cp ./$FILE3 $LOCATION$NAME3
 echo " Setting file to executable...";
 chmod +x ./$FILE3

#app2pkg
 echo " Checking if '$FILE4' exists in the current folder..."
   if [ ! -n "$FILE4" ]; then
      echo "   Error - Filename is not set!"
      exit 1;
   elif [ ! -e "$FILE4" ]; then
      echo "   Error - The location of '$FILE4' does not exist!"
      exit 1;
   fi
 echo " ...found!\n";
 echo " Installing $NAME4...";
 cp ./$FILE4 $LOCATION$NAME4
 echo " Setting file to executable...";
 chmod +x ./$FILE4

echo "...Setup complete."
