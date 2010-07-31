pdflatex  = "pdflatex.exe"
epstopdf  = "epstopdf.exe"
makeindex = "makeindex.exe"

incdir =  "--include-directory=d:/template/latex/" 


tex = $(wildcard *.tex)
eps = $(wildcard *.eps)
pic = $(subst eps,pdf,$(eps))
dust = $(wildcard *.aux *.ilg *.ind *.idx *.toc *.log *.out *.lot *.lol *.lof *.tmp *~)

top = MetaHDL_man

$(top).pdf : $(tex) $(pic) 
	$(pdflatex)  $(incdir) $(top)
	$(makeindex) $(top)
	$(pdflatex)  $(incdir) $(top)

%.pdf : %.eps
	$(epstopdf) $<

.phone : clean clean_all pic eps dust bnf

bnf:
	./gentex.pl ../../src/mparser.bison.output


clean: 
	del $(dust)

clean_all:
	del $(dust) $(pic) $(top).pdf 

pic : 
	@echo $(pic)

eps : 
	@echo $(eps)

dust:
	@echo $(dust)