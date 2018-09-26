#!/bin/bash

PASSWORD=`cat password.txt`
USER=`cat user.txt`
EMAIL=`cat email.txt`

BRANCH_NAME="test-39223578"
COMMIT_MESSAGE="hello"
NUM_CHANGED_FILES=`git diff --name-only | wc -l`

if [ "$NUM_CHANGED_FILES" -eq "0" ]; then
   echo "No changes for $(pwd)";
   exit;
fi

TO_FORK=`git remote show origin | grep "https.*git" | python -c 's = raw_input().split("/"); print "https://@api.github.com/repos/"+s[-2]+"/"+s[-1][:-4]+"/"+"forks"'`

echo "Forking $TO_FORK"
curl -u "${USER}:${PASSWORD}" -d '' $TO_FORK

echo "Checking out branch"
git checkout -b $BRANCH_NAME
git add .
GIT_COMMITTER_NAME="${USER}" GIT_COMMITTER_EMAIL="${EMAIL}" git commit --author="${USER} <${EMAIL}>" -m $COMMIT_MESSAGE

REPO_NAME=`git remote show origin | grep "https.*git" | python -c 's = raw_input().split("/"); print s[-1]'`
echo "Pushing to $REPO_NAME"
git push --force https://${USER}@github.com/${USER}/$REPO_NAME

git checkout master
