#!/bin/sh

env

brew update
brew upgrade xctool
gem install cocoapods
pod install
