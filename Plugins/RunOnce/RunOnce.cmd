:: DO NOT CHANGE ::
@echo off
title Mini10 RunOnce
:: YOUR COMMANDS HERE ::
"%WinDir%\Setup\Scripts\SlimBrowser.exe"
rd /s /q "%WinDir%\Setup\Scripts"
:: DO NOT CHANGE ::
del /f /q %0%