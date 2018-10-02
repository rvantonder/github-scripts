#!/bin/bash

cat | xargs -P 10 -L 1 -I @ bash -c "git clone @ \`basename '@'\`-\`date +\"%Y-%m-%d-%H-%M-%S\"\`" 
