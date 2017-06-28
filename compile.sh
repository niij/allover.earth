#!/bin/bash
set -e # Exit with nonzero exit code if anything fails

bundle install
bundle exec jekyll build