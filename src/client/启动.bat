@echo off
taskkill /f /im MyLuaGame.exe
start /d %~dp0 %~dp0\..\..\tools\game\MyLuaGame.exe
