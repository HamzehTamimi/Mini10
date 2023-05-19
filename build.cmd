@echo off
title Mini10 Automatic Builder
cd /d %~dp0
echo Mini10 Automatic Builder
echo Version 1.0
echo.
net file >nul 2>&1
if "%errorlevel%" neq "0" (
	"%~dp0Bin\NSudo.exe" -U:T -P:E -Priority:RealTime %0% >nul 2>&1
	exit
)
echo Image Version 1809 (Windows 10 LTSC 2019)
echo.
if exist "%~dp0DVD.iso" (echo ISO was found, skipping...) else (
echo Downloading with aria2...
"%~dp0Bin\aria2\aria2c.exe" "https://dl.malwarewatch.org/windows/mods/Tiny 10.iso" -oDVD.iso
)
echo Extracting...
"%~dp0Bin\7z.exe" x DVD.iso -o"%~dp0DVD"
echo Deleting Useless stuffs...
rd /q /s "%~dp0DVD\sources\$OEM$"
del /f /q "%~dp0DVD\Auto-saved*.xml"
del /f /q "%~dp0DVD\NTLite.log"
del /f /q "%~dp0DVD\sources\install.ini"
echo Copying unattended file...
copy /Y "%~dp0Plugins\Unattend\autounattend.xml" "%~dp0DVD\autounattend.xml"
echo Modifying image...
md "%~dp0Mount"
dism /export-image /SourceImageFile:"%~dp0DVD\sources\install.esd" /SourceIndex:1 /DestinationImageFile:"%~dp0DVD\sources\install.wim" /Compress:max
del /f /q "%~dp0DVD\sources\install.esd"
dism /mount-image /imageFile:"%~dp0DVD\sources\install.wim" /Index:1 /MountDir:""%~dp0Mount"
reg load HKEY_LOCAL_MACHINE\MINI10_NTUSER "%~dp0Mount\Users\Default\ntuser.dat"
reg load HKEY_LOCAL_MACHINE\MINI10_SOFTWARE "%~dp0Mount\Windows\System32\config\SOFTWARE"
reg load HKEY_LOCAL_MACHINE\MINI10_SOFTWARE "%~dp0Mount\Windows\System32\config\SYSTEM"
for /F %%f in ('dir "%~dp0Plugins\Registry\*.reg" /s /b') do (regedit /s %%f)
reg unload HKEY_LOCAL_MACHINE\MINI10_NTUSER
reg unload HKEY_LOCAL_MACHINE\MINI10_SOFTWARE
reg unload HKEY_LOCAL_MACHINE\MINI10_SYSTEM
copy /Y "%~dp0Plugins\RunOnce\RunOnce.cmd" "%~dp0Mount\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\RunOnce.cmd"
robocopy "%~dp0Plugins\AdditionalFiles" "%~dp0Mount"
del /f /q "%~dp0Mount\_README.txt"
md "%~dp0DVD\sources\$OEM$"
robocopy "%~dp0Plugins\OEM" "%~dp0DVD\sources\$OEM$"
del /f /q "%~dp0DVD\sources\$OEM$\_README.txt"
dism /unmount-image /MountDir:"%~dp0Mount" /Commit
echo Converting WIM to ESD...
dism /export-image /SourceImageFile:"%~dp0DVD\sources\install.wim" /SourceIndex:1 /DestinationImageFile:"%~dp0DVD\sources\install.esd" /Compress:recovery
del /f /q "%~dp0DVD\sources\install.wim"
echo Making ISO...
"%~dp0Bin\oscdimg.exe" -h -m -o -u2 -udfver102 -bootdata:"2#p0,e,b%~dp0DVD\boot\etfsboot.com#pEF,e,b%~dp0DVD\efi\microsoft\boot\efisys.bin" -lMini10 "%~dp0DVD" "%~dp0Mini10.iso"
echo Cleaning up...
rd /s /q "%~dp0DVD"
rd /s /q "%~dp0Mount"