#!/bin/bash

rm -rf cocos/res/*
rm -rf cocos/src/*
cp -rf client/src/* cocos/src/
cp -rf client/res/* cocos/res/

echo 'done.'
