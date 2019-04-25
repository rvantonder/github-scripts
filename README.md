# Mass Clone Usage

Put your github access token in `token.txt`

Then as simple as:

```
./grab-repos.py python 10 | ./mass-clone.sh
                |      |      |
                |      |      ` clone into to this directory
                |      ` top 10 repos by stars
                ` repo language, e.g., python, java, ...
```

`mass-clone.sh` spins off 5 concurrent download processes by default.

Use `./grab-repos.py python 10` if you just want a list of top repos.

# Fork and PR Usage:

```
bash -x ../../fork-and-local-pr.sh "branch-name" "commit message" "commit title" "PR body" master
```
