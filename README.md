About This Skeleton
===================

This skeleton is designed for users that want to build applications that may use C++/CX and consume Windows Runtime APIs, but for some reason cannot build a full Universal Windows Platform application - typically because some unsupported API needs to be used and there is no suitable replacement. The application is packaged into an AppX that can be distributed through the Windows Store or side-loaded onto customer machines using the Desktop Bridge (Project Centennial). The application is built using Visual Studio 2017 and Windows SDK 10.0.14393.0 or later.

Using the Skeleton
==================

First, copy the UWPDesktopSkeleton directory and all of its files to your destination location, and then rename UWPDesktopSkeleton directory to whatever project name you want. The following steps describe how to modify the files within your new project directory.

1. Rename MyApp.sln to match the name of your project, for example, *ProjectName*.sln.
2. Rename the MyApp and MyApp-UWP directories to match the name of your project, for example, MyApp becomes *ProjectName* and MyApp-UWP becomes *ProjectName*-UWP.
3. Rename the *ProjectName*\*.vcxproj files to match the name of your project. For example, MyApp.vcxproj becomes *ProjectName*.vcxproj and MyApp.vcxproj.filters becomes *ProjectName*.vcxproj.filters.
4. Edit *ProjectName*.sln to reference your renamed project file instead of MyApp.
5. Edit AppxManifest.xml in the *ProjectName*-UWP directory. You'll find various strings such as MyCompany, MySuite, MyApp, MyCity, MyState, MyCountry and Sample Description. Update these as appropriate. Note the values you use for the Package/Identity/Name attribute - you'll need these to update the batch files to build from the command line.
6. Edit makerel.cmd. Set the PROJECT_NAME, PROJECT_SUITE, and PROJECT_COMPANY to the values you used to replace MyApp, MySuite and MyCompany in the AppxManifest.xml file. If you are not using Visual Studio 2017 Professional, you'll also need to update the VSEDITION variable.
7. Edit clean.cmd. Set the PROJECT_NAME, PROJECT_SUITE and PROJECT_COMPANY to the values you used to replace MyApp, MySuite and MyCompany in the AppxManifest.xml file.
9. Open up a command prompt and cd to your project directory. Type makerel to build everything. You should see a lot of build output followed by BUILD SUCCESSFUL.
10. Type clean to clean everything.

Once you are ready to do a final signed deployment, you'll have to edit the MakeAppx step in makerel.cmd to sign the appx package so it can be installed by end users. As-is, running makerel will install the application in development mode for testing. Likewise, running clean will remove the development mode application.

