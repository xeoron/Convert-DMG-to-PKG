Convert macOS apps or DMG installer files to the PGK format
===============
 This is a colleciton of Perl scripts for converting MacOS Apps to PKG deployment installer files to use with other systems
 or to deploy via MDM's such as Mosyle. Target installed apps or DMG files.

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
                    -dr      Dry run mode
                    -l|list  List everything found in the folder /Applications/
                    -o|only  Only list programs found in the /Applications/ Applications folder.
                    -s|sort  Sort the applications list alphanumerically.
                    -h|help

    Requirement:    install the app you want to harvest this data from
  

dmg2pkg
===============
	Converts a mounted dmg installer file to a pkg MDM deplpoyment installer format.
    This is a front end to pkgbuild to make the process less painful. It requires a lot of info to work.
    The hope is use the automation to make it easy or use the other tools to gather that info for yourself.

     List the Apps in /Applications/
       dmg2pkg -o
  
     For best results, provide all the informaiton requred with vlc-3.0.12-intel64.dmg mounted file.
       dmg2pkg -n "/Volumes/VLC media player" -v 3.0.12 -id org.videolan.vlc -s -c VLC
            --> Creates VLC-3.0.12.pkg

     Have it gather most of the information for you with a vlc-3.0.12-intel64.dmg mounted file
       dmg2pkg -a -n /Volumes/VLC\ media\ player/
            --> Creates VLC-3.0.12.pkg

    dmg2pkg -help
           Usage:   dmg2pkg -n VolumeNAME -v appVersion -s -i appBundleIdentifier appPackageName
            
                    -n Name of mounted DMG Volume
                    -v Version The application encoded version number. Mke sure to sync this with the version you are 
                        trying to deploy (if it’s VLClan v3.1.12, then this parameter is 3.1.12). How to find 
                        the encoded version number go to the section Extra Detail for more information
                    -id Application bundle identifier. Go to the secion Extra Detail for more information
                    -c Name of the PKG file you will create in the current folder. Optional, iff -a is used.
                    
    Optional        -help
                    -verbose
                    -dr   Dry run mode. It will confirm everything and not try to build anything.
                    -l    list everything found in the folder /Applications/
                    -o    Only list programs found in the /Applications/ Applications folder.
                    -sort List of Applications sorted alphanumerically.
                    -a    AppData...gather the required app version number and bundle id info automaticly.
                        This displays a list of installed apps and asks you which one is the target.
                        Note: -c is optional, because it will harvest that information out of /Applications/
                        Requires the app to be installed in /Applications/ folder.

    Requirement:    Must have a dmg file you have opened/mounted for this program to work
                    -a requires the app to be installed in /Applications
    
    Extra Detail:   Please use the following apps to gather the required version and id informaiton:
                    The application you want to conver to a pkg must be installed for this to work.
                        
                        appBundleID.pl to discover/harvest the identifier code of a program.
                        
                        appVersion.pl to discoer/harvest the application version number that you 
                            want to convert to a pkg installer file. It is very important you use
                            the version it is signed with.
