Convert macOS DMG installer files to the PGK format. 
===============
 This is a colleciton of Perl scripts for converting MacOS Apps to PKG deployment installer files to use with Mosyle or any other MDM

appBundleID
===============
	Will tell you the Application Bundle Identifier of a installed App stored in the
    Applications folder.

    Example 1: appBundleID -a VLC
        org.videolan.vlc

    Example 2: appBundleID -a "davinci resolve"
        com.blackmagic-design.DaVinciResolveLite

    Example 3: appBundleID -a /Applications/darktable.app
        org.darktable

appVersion 
===============
	Tells you the version of a Application stored in the Applications folder.

    Example 1 : appVersion.pl -a VLC
        3.0.12

    Example 2: appVersion.pl -a /Applications/darktable.app
        3.4.1

app2pkg 
===============
	Converts an app program installed in /Applications/ to the pkg installer format.
    It will ask to choose which app from a list and then making a pkg installer version.
    This is a front end to productbuild to make the process less painful.

    Convert installed apps in the Applications folder to a pkg installer
    by asking you which program you can to harvest and convert into a deployment installer.

    Usage:          app2pkg
    
    Optional        
                    -dr     Dry run mode
                    -l      list everything found in the folder /Applications/
                    -o      Only list programs found in the /Applications/ Applications folder.
                    -s|sort Sort the applications list alphanumerically.
                    -h|help

    Requirement:    install the app you want to harvest this data from
  

dmg2pkg
===============
	Converts a mounted dmg installer file to a pkg MDM deplpoyment installer format to work with Mosyle.
    This is a front end to pkgbuild to make the process less painful.

     List the Apps in /Applications/
       dmg2pkg -o
  
     For best results, provide all the informaiton requred with vlc-3.0.12-intel64.dmg mounted file.
       dmg2pkg -n "/Volumes/VLC media player" -v 3.0.12 -id org.videolan.vlc -s -c VLC
            --> Creates VLC-3.0.12.pkg

     Have it grather most of the information for you with a vlc-3.0.12-intel64.dmg mounted file
       dmg2pkg -a -n /Volumes/VLC\ media\ player/
            --> Creates VLC-3.0.12.pkg

     See help for more options
       dmg2pkg -help
