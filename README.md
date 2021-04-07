Manage Mosyle MDM MacOS Apps
===============
 This is a colleciton of Perl scripts for converting MacOS Apps to PKG deployment installer files to use with Mosyle or any other MDM

appBundleID
===============
	Will tell you the Application Bundle Identifier of a installed App stored in the
    Applications folder.

appVersion 
===============
	Tells you the version of a Application stored in the Applications folder.

app2pkg: not usable yet
===============
	Converts an app program installed in /Applications/ to the pkg installer format
    making it a MDM deplpoyment installer that will work with Mosyle.
    This is a front end to productbuild to make the process less painful.

dmg2pkg
===============
	Converts a mounted dmg installer file to a pkg MDM deplpoyment installer format to work with Mosyle.
    This is a front end to pkgbuild to make the process less painful.