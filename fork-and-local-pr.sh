#!/bin/bash

PASSWORD=`cat $HOME/github-scripts/password.txt`
USER=`cat $HOME/github-scripts/user.txt`
EMAIL=`cat $HOME/github-scripts/email.txt`

# Branch variables
BRANCH_NAME="test-39223578"
COMMIT_MESSAGE="hello"

# PR variables
TITLE="PR"
BODY="BODY"
BASE="master"

if [ $# -eq 0 ]; then
    echo "./cmd <branch name> <commit message> <PR title> <PR Body>"
    exit 1
fi

BRANCH_NAME=$1
COMMIT_MESSAGE=$2
TITLE=$3
BODY=$4
BASE=$5

NUM_CHANGED_FILES=`git diff --name-only | wc -l`

if [ "$NUM_CHANGED_FILES" -eq "0" ]; then
   echo "No changes for $(pwd)";
   exit;
fi

# GO-SPECIFIC
# copy gofmt precommit hook into this repo's .git
cp $HOME/github-scripts/pre-commit-gofmt-hook .git/hooks/pre-commit

TO_FORK=`git remote show origin | grep "https.*git" | python -c 's = raw_input().split("/"); print "https://@api.github.com/repos/"+s[-2]+"/"+s[-1][:-4]+"/"+"forks"'`

echo "Forking $TO_FORK"
curl -u "${USER}:${PASSWORD}" -d '' $TO_FORK

# sleep, fork can take time for, e.g., HHVM
sleep 2

echo "Checking out branch"
git checkout -b $BRANCH_NAME

# GO SPECIFIC
# add all *.go files but not vendor ones
git status -s | cut -c4- | grep "\.go$" | grep -v "vendor" | xargs -L 1 -I % git add %

# OCAML SPECIFIC
# git status -s | cut -c4- | grep "\.ml$" | xargs -L 1 -I % git add %
# git status -s | cut -c4- | grep "\.mli$" | xargs -L 1 -I % git add %

# DART SPECIFIC
# git status -s | cut -c4- | grep "\.dart$" | xargs -L 1 -I % git add %


# restore unstaged files, like vendor stuff
git checkout -- .

GIT_COMMITTER_NAME="${USER}" GIT_COMMITTER_EMAIL="${EMAIL}" git commit --author="${USER} <${EMAIL}>" -m "$COMMIT_MESSAGE"

REPO_NAME=`git remote show origin | grep "https.*git" | python -c 's = raw_input().split("/"); print s[-1][:-4]'`
echo "Pushing to $REPO_NAME"
expect -c "
  spawn git push --force https://${USER}@github.com/${USER}/$REPO_NAME.git
  expect \"Password\"
  send \"${PASSWORD}\n\"
  expect eof"

echo "Creating local PR"

curl \
  -u "${USER}:${PASSWORD}" \
  -d "{ \"title\": \"${TITLE}\", \"body\": \"${BODY}\", \"head\": \"${USER}:${BRANCH_NAME}\", \"base\": \"${BASE}\" }" \
  https://api.github.com/repos/${USER}/${REPO_NAME}/pulls

git checkout $BASE
