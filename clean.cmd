@ECHO OFF

SETLOCAL ENABLEDELAYEDEXPANSION

:: The following need to match the directories in makerel.cmd and the Visual Studio project(s).
:: The PROJECT_NAME, PROJECT_SUITE and PROJECT_COMPANY should match those in the AppManifest.xml file Package/Identity/Name attribute.
SET PROJECT_NAME=MyApp
SET PROJECT_SUITE=MySuite
SET PROJECT_COMPANY=MyCompany
SET BUILD_OUTPUT_DIR_X86=build-x86
SET BUILD_OUTPUT_DIR_X64=build-x64

:: Define the absolute paths to the various directories containing build artifacts.
:: PROJECT_DIR is the directory containing the Visual Studio project file used to build the application.
SET ROOTDIR=%~dp0
SET UWPDIR=%~dp0%PROJECT_NAME%-UWP
SET PROJECT_DIR=%~dp0%PROJECT_NAME%
SET INCLUDESDIR=%~dp0include
SET OUTPUTDIR_X86=%~dp0%BUILD_OUTPUT_DIR_X86%
SET OUTPUTDIR_X64=%~dp0%BUILD_OUTPUT_DIR_X64%

:: Uninstall the application if it was installed in development mode.
PUSHD "%ROOTDIR%"
ECHO Removing development-mode application...
Powershell -Command "& {Get-AppxPackage -Name %PROJECT_COMPANY%.%PROJECT_SUITE%.%PROJECT_NAME% ^| Remove-AppxPackage;}"
POPD

:: Clean up the build output directories in the solution directory.
IF EXIST "%OUTPUTDIR_X86%" (
    ECHO Removing the x86 output directory...
    RMDIR /S /Q "%OUTPUTDIR_X86%"
)
IF EXIST "%OUTPUTDIR_X64%" (
    ECHO Removing the x64 output directory...
    RMDIR /S /Q "%OUTPUTDIR_X64%"
)

:: Clean up after Visual Studio, which places files all over the place.
IF EXIST "%PROJECT_DIR%\x86" (
    RMDIR /S /Q "%PROJECT_DIR%\x86"
)
IF EXIST "%PROJECT_DIR%\x64" (
    RMDIR /S /Q "%PROJECT_DIR%\x64"
)
IF EXIST "%PROJECT_DIR%\BundleArtifacts" (
    RMDIR /S /Q "%PROJECT_DIR%\BundleArtifacts"
)
IF EXIST "%PROJECT_DIR%\Generated Files" (
    RMDIR /S /Q "%PROJECT_DIR%\Generated Files"
)
IF EXIST "%PROJECT_DIR%\_pkginfo.txt" (
    DEL /Q "%PROJECT_DIR%\_pkginfo.txt"
)
IF EXIST "~dp0AppPackages" (
    ECHO Removing the AppPackages directory and all of its contents...
    RMDIR /S /Q "%~dp0AppPackages"
)

:: Clean up any appx artifacts generated during the packaging process.
IF EXIST "%ROOTDIR%\%PROJECT_NAME%.appx" (
    DEL /Q "%ROOTDIR%\%PROJECT_NAME%.appx"
)
IF EXIST "%UWPDIR%\resources.pri" (
    DEL /Q "%UWPDIR%\*.pri"
)
IF EXIST "%UWPDIR%\microsoft.system.package.metadata" (
    RMDIR /S /Q "%UWPDIR%\microsoft.system.package.metadata"
)

FOR %%a IN ("%~dp0*.VC.db") DO SET HAS_DB_FILES=1 & GOTO DELETE_VCDB

SET HAS_DB_FILES=0

:DELETE_VCDB
IF %HAS_DB_FILES% == 1 (
    ECHO Removing Visual Studio IntelliSense database files...
    DEL /Q "%~dp0*.VC.db"
)

ENDLOCAL
ECHO Re-run makerel.cmd to build everything.

