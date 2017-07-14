#!/bin/bash
set -e # Exit with nonzero exit code if anything fails

bundle install # ruby stuff for Jekyll
npm install # Get grunt and image processing deps installed
grunt build # run imagemin (progressive JPEG and image compression), then jekyll build