#!/bin/bash

PASSWORD=`cat $HOME/github-scripts/password.txt`
USER=`cat $HOME/github-scripts/user.txt`
EMAIL=`cat $HOME/github-scripts/email.txt`

BRANCH_NAME="test-39223578"
COMMIT_MESSAGE="hello"
NUM_CHANGED_FILES=`git diff --name-only | wc -l`

# PR variables
TITLE="PR"
BODY="BODY"
BASE="master"

if [ "$NUM_CHANGED_FILES" -eq "0" ]; then
   echo "No changes for $(pwd)";
   exit;
fi

# copy gofmt precommit hook into this repo's .git
cp $HOME/github-scripts/pre-commit-gofmt-hook .git/hooks

TO_FORK=`git remote show origin | grep "https.*git" | python -c 's = raw_input().split("/"); print "https://@api.github.com/repos/"+s[-2]+"/"+s[-1][:-4]+"/"+"forks"'`

echo "Forking $TO_FORK"
curl -u "${USER}:${PASSWORD}" -d '' $TO_FORK

echo "Checking out branch"
git checkout -b $BRANCH_NAME
git add .
GIT_COMMITTER_NAME="${USER}" GIT_COMMITTER_EMAIL="${EMAIL}" git commit --author="${USER} <${EMAIL}>" -m $COMMIT_MESSAGE

REPO_NAME=`git remote show origin | grep "https.*git" | python -c 's = raw_input().split("/"); print s[-1][:-4]'`
echo "Pushing to $REPO_NAME"
git push --force https://${USER}@github.com/${USER}/$REPO_NAME.git

echo "Creating local PR"

curl \
  -u "${USER}:${PASSWORD}" \
  -d "{ \"title\": \"${TITLE}\", \"body\": \"${BODY}\", \"head\": \"${USER}:${BRANCH_NAME}\", \"base\": \"${BASE}\" }" \
  https://api.github.com/repos/${USER}/${REPO_NAME}/pulls

git checkout master
