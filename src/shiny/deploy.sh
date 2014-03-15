#!/bin/sh

rsync -Pavz --delete --copy-links app/ ww:~/www/shiny/www/sim/
exit 0