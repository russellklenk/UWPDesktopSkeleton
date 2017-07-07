@ECHO OFF 

SETLOCAL ENABLEDELAYEDEXPANSION

:: Windows version constants for WINVER and _WIN32_WINNT.
SET WINVER_WIN10=0x0A00

:: Windows SDK version constants. Used when building store apps.
SET WINSDK_WIN10=10.0.10240.0
SET WINSDK_WIN10_NOV2015=10.0.10586.0
SET WINSDK_WIN10_JUL2016=10.0.14393.0

:: Specify the project name, Windows version and Windows SDK version.
:: The PROJECT_NAME, PROJECT_SUITE and PROJECT_COMPANY should match those 
:: in the AppxManifest.xml file Package/Identity/Name attribute.
SET PROJECT_NAME=MyApp
SET PROJECT_SUITE=MySuite
SET PROJECT_COMPANY=MyCompany
SET PROJECT_WINVER=%WINVER_WIN10%
SET PROJECT_WINSDK=%WINSDK_WIN10_JUL2016%
SET PROJECT_SLN=%~dp0%PROJECT_NAME%.sln

:: The following need to match the build output directories set in the Visual Studio projects.
SET BUILD_OUTPUT_CONFIG_DEBUG=Debug
SET BUILD_OUTPUT_CONFIG_RELEASE=Release
SET BUILD_OUTPUT_DIR_X86=build-x86
SET BUILD_OUTPUT_DIR_X64=build-x64

:: Define the absolute paths to the various directories containing build artifacts.
SET ROOTDIR=%~dp0
SET UWPDIR=%~dp0%PROJECT_NAME%-UWP
SET PROJECT_DIR=%~dp0%PROJECT_NAME%
SET INCLUDESDIR=%~dp0include
SET OUTPUTDIR_X86=%~dp0%BUILD_OUTPUT_DIR_X86%
SET OUTPUTDIR_X64=%~dp0%BUILD_OUTPUT_DIR_X64%

:: Define the absolute paths to the various directories containing build tools.
:: VS2017 did a horrible thing and changed the directory structure and embedded the edition name.
:: Set VSEDITION to whichever edition you have installed.
SET VSEDITION=Professional
SET VSVARSBAT="%ProgramFiles(x86)%\Microsoft Visual Studio\2017\%VSEDITION%\VC\Auxiliary\Build\vcvarsall.bat"
SET MSBUILD="%ProgramFiles(x86)%\Microsoft Visual Studio\2017\%VSEDITION%\MSBuild\15.0\Bin\MSBuild.exe"

:: Make sure that all tools can be found.
IF NOT DEFINED DevEnvDir (
    CALL %VSVARSBAT% x86_amd64 %PROJECT_WINSDK%
)

:: Everything is configured through the project and solution files and builds with MSBuild.
PUSHD "%ROOTDIR%"
%MSBUILD% "%PROJECT_SLN%" /p:Configuration=%BUILD_OUTPUT_CONFIG_RELEASE% /m /nologo
POPD
:: If the ERRORLEVEL (msbuild exit code) is not zero, the build failed.
IF ERRORLEVEL 1 GOTO Build_Failed

:: The build was successful, so clean any Appx artifacts before rebuilding the Appx package.
:: This prevents some additional warning output and confirmations from being displayed.
IF EXIST "%ROOTDIR%\%PROJECT_NAME%.appx" (
    DEL /Q "%ROOTDIR%\%PROJECT_NAME%.appx"
)
IF EXIST "%UWPDIR%\resources.pri" (
    DEL /Q "%UWPDIR%\*.pri"
)
IF EXIST "%UWPDIR%\microsoft.system.package.metadata" (
    RMDIR /S /Q "%UWPDIR%\microsoft.system.package.metadata"
)

:: Copy the application executable to the package directory.
IF EXIST "%OUTPUTDIR_X64%\%BUILD_OUTPUT_CONFIG_RELEASE%\%PROJECT_NAME%.exe" (
    COPY /Y "%OUTPUTDIR_X64%\%BUILD_OUTPUT_CONFIG_RELEASE%\%PROJECT_NAME%.exe" "%UWPDIR%"
)

:: Re-generate UWP Application Package resources.
PUSHD "%UWPDIR%"
makepri new /pr "%UWPDIR%" /cf "%UWPDIR%\priconfig.xml" /mn "%UWPDIR%\AppxManifest.xml"
POPD
:: If the ERRORLEVEL (makepri exit code) is not zero, the makepri process failed.
IF ERRORLEVEL 1 GOTO Build_Failed

:: Build the actual Appx package files.
:: Remove the /v flag to disable verbose output.
PUSHD "%ROOTDIR%"
MakeAppx pack /v /h SHA256 /l /d "%UWPDIR%" /p %PROJECT_NAME%.appx
POPD
:: If the ERRORLEVEL (MakeAppx exit code) is not zero, the MakeAppx process failed.
IF ERRORLEVEL 1 GOTO Build_Failed

:: Install the package in development mode.
PUSHD "%ROOTDIR%"
Powershell -Command "& {Get-AppxPackage -Name %PROJECT_COMPANY%.%PROJECT_SUITE%.%PROJECT_NAME% ^| Remove-AppxPackage;}"
Powershell -Command "& {Add-AppxPackage -Register '%UWPDIR%\AppxManifest.xml';}"
POPD
:: If the ERRORLEVEL (Powershell exit code) is not zero, the app registration failed.
IF ERRORLEVEL 1 GOTO Build_Failed

:Build_Success
ECHO.
ECHO BUILD SUCCEEDED.
ECHO The application has been installed on the local machine in development mode.
ECHO Locate your application %PROJECT_NAME% in the Start Menu and click-to-launch.
ECHO To remove your development UWP application, launch PowerShell and run:
ECHO Get-AppxPackage -Name %PROJECT_COMPANY%.%PROJECT_SUITE%.%PROJECT_NAME% ^| Remove-AppxPackage
ENDLOCAL
EXIT /b 0

:Build_Failed
ECHO.
ECHO BUILD FAILED.
ENDLOCAL
EXIT /b 1

