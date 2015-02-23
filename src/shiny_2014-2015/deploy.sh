#!/bin/sh

rsync -Pavz --delete --copy-links app/ ww:~/www/shiny/www/sim_2014-2015/
exit 0