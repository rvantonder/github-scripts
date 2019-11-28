#!/bin/bash

cat | comby -stdin -stdout 'https://:[x].git' 'https://:[x]' | xargs -P 10 -L 1 -I @ bash -c "wget -O \`basename '@'\`-\`date +\"%Y-%m-%d-%H-%M-%S\"\`.zip @/archive/master.zip" 
