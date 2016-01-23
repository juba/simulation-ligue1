#!/bin/sh

rsync -Pavz --delete --copy-links app/ ww:~/www/shiny/www/sim_2015-2016/
exit 0