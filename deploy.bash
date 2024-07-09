#!/bin/bash

echo 'have you updated the version in pubspec.yaml? (y/n): '
read answer
if [ $answer != 'y' ]; then
  echo 'Please update the version in pubspec.yaml'
  exit 1
fi


cd skola_offline
flutter build appbundle
nautilus build/app/outputs/bundle/release &

flutter build apk
cp build/app/outputs/flutter-apk/app-release.apk ../skola_offline.apk

flutter build web
rm -fr ../../SkolaOffline.github.io/*
cp -r build/web/* ../../SkolaOffline.github.io

cd ../../SkolaOffline.github.io
git status
git add .
git commit -m "automatic web update from deploy.bash"
git push