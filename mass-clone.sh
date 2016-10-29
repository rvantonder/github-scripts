#!/bin/bash

cat | xargs -P 5 -L 1 -I @ bash -c "git clone @ \`basename '@'\`-\`date +\"%Y-%m-%d-%H-%M-%S\"\`" 
