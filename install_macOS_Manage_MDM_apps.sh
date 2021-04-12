#!/bin/sh -e
#Author: Jason Campisi
#Filename: install_Manage_MDM_apps
# Description: install the Manage Mosyle MDM MacOS apps
#Date: 4/12/2021
#version 1.1.1 For MacOS X or higher
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

declare -a NameList=("$NAME1" "$NAME2" "$NAME3" "$NAME4")

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
	echo " You do not have permission to install ./$FILE1, ./$FILE2, ./$FILE3, ./$FILE4";
	echo " ->You must be a root user.";
	echo " ->Try instead: sudo $0";
	exit 1;
else
	echo " Root access granted for $0\n";	
fi

echo " Installing $NAME1, $NAME2, $NAME4 to $LOCATION ...\n";

#Iterate thru a list of filenames: Check if each file exists, make it runnable and install it
for val in ${NameList[@]}; do
    echo " Checking if '$val' exists in the current folder..."
       if [ ! -n "$val.$EXT" ]; then
            echo "   Error - Filename is not set!"
            exit 1;
        elif [ ! -e "$val.$EXT" ]; then
            echo "   Error - The location of '$val.$EXT' does not exist!"
            exit 1;
        fi
    echo " ...found!\n";
    echo "  Setting file to executable...\n";
    chmod +x ./$val.$EXT
    echo " Installing $val...";
    cp ./$val.$EXT $LOCATION$val
done

echo "...Setup complete."
