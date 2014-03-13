FILE    := 2014-03-06-simulation-ligue1
JEKYLLDIR := /home/julien/projets/data.nozav.org

RMDFILE := $(FILE).Rmd
MDFILE  := $(FILE).md
IMAGEDIR := images/$(FILE)

all : jekyll publish

jekyll : 
	Rscript \
	   -e "library(knitr)" \
       -e "knitr::knit('$(RMDFILE)')"

publish :
	cp $(MDFILE) $(JEKYLLDIR)/_posts/
	cp -rp $(IMAGEDIR) $(JEKYLLDIR)/images/

clean :
	if [ -d images ]; then  rm -rf images/; fi
	if [ -d cache ]; then  rm -rf cache/; fi
	if [ -d out ]; then  rm -rf out/; fi
	if [ -e $(MDFILE) ]; then rm $(MDFILE); fi


