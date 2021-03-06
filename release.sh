#!/bin/bash
# set -e

changelogPath=""
configPath="src"

# Validate version - compare with config.toml
# version="4"

branchStatus=$(git status -b --porcelain)
branchIsMaster=$(echo $branchStatus | grep -Po "^(## master)" | grep -o "master")
filesStatus=$(echo $(git status -u --porcelain))

master="## master"

if [ -z "$branchIsmaster" ]; then
  echo "You need to be on master bran == "" ]]ch to release."
fi
if [ -n "$filesStatus" ]; then
  echo "Uncommited changes. Your working tree needs to be clean to release."
fi
if [ -z "$branchIsMaster" ] || [ -n "$filesStatus" ]; then
  echo "Would exit normally"
  # exit 1
fi

Echo "Fetching to compare with remote"
git fetch
branchStatus=$(git status -b --porcelain)
branchIsBehind=$(echo $branchStatus | grep -Po "( \[behind [0-9]\])")
echo "Is branch behind? : $branchIsBehind"

if [ -n branchIsBehind]; then
  echo "Your branch is out of date"
  echo "Would exit normally"
  # exit 1
fi

toChange="\#\# \[Unreleased\]"

if [ -z "$(find . "changelog.md" | grep -Po "^changelog.md")" ]; then
  echo "Cannot find changelog.md in $PWD"
fi

findLine=$(grep -P -o "$toChange" changelog.md)

if [ -z "$findLine" ]; then
  echo "Required line: '## [Unreleased]' not found in changelod.md."
  echo "Would exit normally"
  # exit 1
fi

echo "\nDo not merge anything untill release is done!\n"
echo -n "Pass a new version number and press [ENTER]: "
read v

today="$(date -- +%Y-%m-%d)"
newHeader="## [v$v] - $today"

template="## [Unreleased]\n\n### Added\n\n### Changed\n\n### Fixed"

sed -i "s/$toChange/$template\n\n$newHeader/" changelog.md

if [ -z "$(find ./src "config.toml" | grep -Po "^config.toml")" ]; then
  echo "Cannot find config.toml in $PWD"/src
fi

newVersion="uiVersion = '$v'"

sed -i "s/"uiVersion.*$"/$newVersion/" ./src/config.toml

commitMessage="Release"

git commit -a -m ""

# export github auth token
# Run release-it with:
# github.release: true
# github.releaseNotes - from stdout
