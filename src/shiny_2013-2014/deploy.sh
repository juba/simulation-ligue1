#!/bin/sh

rsync -Pavz --delete --copy-links app/ ww:~/www/shiny/www/sim_2013-2014/
exit 0