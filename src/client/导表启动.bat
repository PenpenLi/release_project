set d=%~dp0
cd ../../tools/exporter/exporter
python run.py export
cd ../../behavior_tree
python parse.py
pause

@echo off
taskkill /f /im MyLuaGame.exe
start /d %d% %d%\..\..\tools\game\MyLuaGame.exe
