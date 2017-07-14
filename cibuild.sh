#!/bin/bash
set -e # Exit with nonzero exit code if anything fails

BUILD_DIR="_site"
SOURCE_BRANCH="master"
TARGET_BRANCH="gh-pages"

function doCompile {
  ./compile.sh
}

# Pull requests and commits to other branches shouldn't try to deploy, just build to verify
if [ "$TRAVIS_PULL_REQUEST" != "false" -o "$TRAVIS_BRANCH" != "$SOURCE_BRANCH" ]; then
    echo "Skipping deploy; just doing a build."
    doCompile
    exit 0
fi

# Save some useful information
REPO=`git config remote.origin.url`
SSH_REPO=${REPO/https:\/\/github.com\//git@github.com:}
SHA=`git rev-parse --verify HEAD`

rm -rf $BUILD_DIR
mkdir $BUILD_DIR
cp -R .git $BUILD_DIR
cd $BUILD_DIR
git checkout $TARGET_BRANCH || exit 20
cd ..


#######################
echo "la _site after rm -rf"
ls -la _site

# Run our compile script
doCompile

############
echo "la _site after doCompile"
ls -la _site

# Now let's go have some fun with the cloned repo
cd $BUILD_DIR

##############
echo "git status inside _site"
git status

git config user.name "Travis CI allover.earth"
git config user.email "travis.build@allover.earth"

# If there are no changes to the compiled $BUILD_DIR (e.g. this is a README update) then just bail.
if git diff --quiet; then
    echo "No changes to the output on this push"
fi

###################
echo "la img/"
ls -la img/

# Commit the "changes", i.e. the new version.
# The delta will show diffs between new and old versions.
git commit -am "Deploy to GitHub Pages: ${SHA}"

# Get the deploy key by using Travis's stored variables to decrypt travis_deploy.enc
ENCRYPTED_KEY_VAR="encrypted_${ENCRYPTION_LABEL}_key"
ENCRYPTED_IV_VAR="encrypted_${ENCRYPTION_LABEL}_iv"
ENCRYPTED_KEY=${!ENCRYPTED_KEY_VAR}
ENCRYPTED_IV=${!ENCRYPTED_IV_VAR}
openssl aes-256-cbc -K $ENCRYPTED_KEY -iv $ENCRYPTED_IV -in ../travis_deploy.enc -out ../travis_deploy -d
chmod 600 ../travis_deploy
eval `ssh-agent -s`
ssh-add ../travis_deploy

# Now that we're all set up, we can push.
git push $SSH_REPO $TARGET_BRANCH