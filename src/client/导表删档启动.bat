set d=%~dp0
cd ../../tools/exporter/exporter
python run.py export
cd ../../behavior_tree
python parse.py
pause

@echo off
taskkill /f /im MyLuaGame.exe
del /f/s/q/a %~dp0\..\..\tools\game\UserDefault.xml
start /d %~dp0 %~dp0\..\..\tools\game\MyLuaGame.exe
