# Usage

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
