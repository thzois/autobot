#!/bin/bash

set -x -e

GIT_CONFIG_USER_EMAIL=$1
GIT_CONFIG_USER_NAME=$2
SOURCE_DIR=$3
SOURCE_DIR_COPY_GLOB=$4
TARGET_REPO=$5
TARGET_DIR=$6
PR_TARGET_REPO_BASE_BRANCH=$7
PR_TARGET_REPO_COMPARE_BRANCH=$8
PR_TITLE=$9
PR_LABEL=${10}
PR_DESCRIPTION_TEXT=${11}

DEFAULT_AUTOBOT_TEXT="[autobot] [$(date '+%d-%m-%Y %H:%M:%S')] Automated changes"

# PR base and compare branch cannot be the same
if [ "$PR_TARGET_REPO_BASE_BRANCH" = "$PR_TARGET_REPO_COMPARE_BRANCH" ]
then
  echo "Pull request base branch cannot be the same as the compare branch"
  exit 1
fi

# Default autobot branch
if [ -z "$PR_TARGET_REPO_COMPARE_BRANCH" ]
then
    PR_TARGET_REPO_COMPARE_BRANCH="autobot/$(printf '%s' "$GITHUB_SHA" | cut -c 1-7)/$GITHUB_RUN_ID-$GITHUB_RUN_ATTEMPT"
fi

# Default PR title
if [ -z "$PR_TITLE" ]
then
    PR_TITLE="chore: "$DEFAULT_AUTOBOT_TEXT
fi

# Default PR description text
if [ -z "$PR_DESCRIPTION_TEXT" ]
then
    PR_DESCRIPTION_TEXT=$DEFAULT_AUTOBOT_TEXT
fi

echo "Configuring git"
export GITHUB_TOKEN=$GH_ACCESS_TOKEN
git config --global user.email "$GIT_CONFIG_USER_EMAIL"
git config --global user.name "$GIT_CONFIG_USER_NAME"

echo "Cloning target repository"
CLONE_DIR=$(mktemp -d)
git clone "https://$GH_ACCESS_TOKEN@github.com/$TARGET_REPO.git" "$CLONE_DIR"

echo "Copying contents to target repo"

# Enable/Disable globbing
shopt -s globstar extglob dotglob
cp -R "$SOURCE_DIR"$SOURCE_DIR_COPY_GLOB "$CLONE_DIR/$TARGET_DIR"
shopt -u  globstar extglob dotglob

echo "Creating branch to commit changes"
cd "$CLONE_DIR"
git checkout -b "$PR_TARGET_REPO_COMPARE_BRANCH"

echo "Committing changes"
git add .
if git status | grep -q "Changes to be committed"
then
    gh label create "$PR_LABEL" --description "$PR_LABEL" --color EDCB18 --force
    git commit -m "Updates from https://github.com/$GITHUB_REPOSITORY/commit/$GITHUB_SHA"
    git push -u origin HEAD:"$PR_TARGET_REPO_COMPARE_BRANCH"
    echo "Creating a pull request"
    gh pr create -t "$PR_TITLE" \
        -b "$PR_DESCRIPTION_TEXT" \
        -B "$PR_TARGET_REPO_BASE_BRANCH" \
        -H "$PR_TARGET_REPO_COMPARE_BRANCH" \
        -l "$PR_LABEL"
else
    echo "No changes detected"
fi
