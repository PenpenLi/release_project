@echo off
del /f /s /q /a %~dp0\cocos\base
rd /s /q %~dp0\cocos\base

xcopy /s /y /i %~dp0\client\base %~dp0\cocos\base

set curdir=%~dp0
set jitdir=%~dp0\..\tools\luajit
cd %jitdir%
echo "start luajit ..." > %curdir%packlog.log
python jit.py >> %curdir%packlog.log 2>&1
cd %curdir%cocos
echo "start compile ..." >> %curdir%packlog.log
cocos run -p android -j 4 >> %curdir%packlog.log 2>&1
pause
