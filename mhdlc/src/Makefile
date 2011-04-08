release =

ifeq ($(HOST),ubuntu606)
FLEX = flex
BISON= bison
else
FLEX = /home/xin_meng/tools/bin/flex
BISON= /home/xin_meng/tools/bin/bison
endif

ifeq ($(MACHTYPE),x86_64)
CXX = g++
TOP_EXE = mhdlc64
else 
CXX = /home/xin_meng/tools/bin/g++
TOP_EXE = mhdlc32
endif	

ifeq ($(release),)
PROFLAGS = -pg
CPPFLAGS = -g  `perl -MExtUtils::Embed -e ccopts` $(PROFLAGS)
LIBFLAGS = `perl -MExtUtils::Embed -e ldopts` $(PROFLAGS)
else 
CPPFLAGS = -O3  `perl -MExtUtils::Embed -e ccopts` 
LIBFLAGS = `perl -MExtUtils::Embed -e ldopts` 
endif



BISON_AUX_INC = location.hh position.hh stack.hh

M_CC_SRC    = CMHDLwrapper.cc 
M_FLEX_SRC  = mlexer.l
M_BISON_SRC = mparser.y
M_FLEX_CC_SRC  = $(M_FLEX_SRC:.l=.flex.cc)
M_BISON_CC_SRC = $(M_BISON_SRC:.y=.bison.cc)
M_BISON_INC    = $(M_BISON_CC_SRC:.cc=.hh)  
M_BISON_OUTPUT = $(M_BISON_CC_SRC:.cc=.output)
M_ALL_CC_SRC = $(M_CC_SRC) $(M_FLEX_CC_SRC) $(M_BISON_CC_SRC)
M_OBJ = $(addsuffix .o,$(basename $(M_CC_SRC) $(M_FLEX_CC_SRC) $(M_BISON_CC_SRC)))




SV_CC_SRC    = CSVwrapper.cc 
SV_FLEX_SRC  = svlexer.l
SV_BISON_SRC = svparser.y
SV_FLEX_CC_SRC  = $(SV_FLEX_SRC:.l=.flex.cc)
SV_BISON_CC_SRC = $(SV_BISON_SRC:.y=.bison.cc)
SV_BISON_INC    = $(SV_BISON_CC_SRC:.cc=.hh)  
SV_BISON_OUTPUT = $(SV_BISON_CC_SRC:.cc=.output)
SV_ALL_CC_SRC = $(SV_CC_SRC) $(SV_FLEX_CC_SRC) $(SV_BISON_CC_SRC)
SV_OBJ = $(addsuffix .o,$(basename $(SV_CC_SRC) $(SV_FLEX_CC_SRC) $(SV_BISON_CC_SRC)))



PP_CC_SRC       = create.cc vpp_interface.cc
PP_FLEX_SRC     = vpp.l
PP_BISON_SRC    = vpp.y
PP_FLEX_CC_SRC  = $(PP_FLEX_SRC:.l=.flex.cc)
PP_BISON_CC_SRC = $(PP_BISON_SRC:.y=.bison.cc)
PP_BISON_INC    = $(PP_BISON_CC_SRC:.cc=.hh)
PP_INC          = common.h proto.h yacc_stuff.h
PP_ALL_CC_SRC = $(PP_CC_SRC) $(PP_FLEX_CC_SRC) $(PP_BISON_CC_SRC)
PP_OBJ = $(addsuffix .o,$(basename $(PP_CC_SRC) $(PP_FLEX_CC_SRC) $(PP_BISON_CC_SRC)))


UTIL_CC_SRC  = Mfunc.cc
UTIL_ALL_CC_SRC  = $(UTIL_CC_SRC)
UTIL_OBJ = $(addsuffix .o,$(basename $(UTIL_CC_SRC)))


TOP_CC_SRC = mhdlc.cc
TOP_ALL_CC_SRC  = $(TOP_CC_SRC)
TOP_OBJ = $(addsuffix .o,$(basename $(TOP_CC_SRC)))
TOP_LIB = libmhdlc.a


OBJS = $(M_OBJ) $(SV_OBJ) $(PP_OBJ) $(UTIL_OBJ) $(TOP_OBJ)
CC_SRC = $(M_ALL_CC_SRC) $(SV_ALL_CC_SRC) $(PP_ALL_CC_SRC) $(UTIL_ALL_CC_SRC) $(TOP_ALL_CC_SRC)



.phony: lib clean obj tar


$(TOP_EXE): $(OBJS)
	$(CXX) -o $@ $^ $(LIBFLAGS)

.depend : $(CC_SRC)
	$(CXX) -MM $(CPPFLAGS) $^ > .depend

$(M_FLEX_CC_SRC) : $(M_FLEX_SRC)
	$(FLEX) $^

$(M_BISON_CC_SRC) : $(M_BISON_SRC)
	$(BISON) $^
	@perl -pi -e 's/enum yytokentype/enum mhdltokentype/' mparser.bison.hh


$(SV_FLEX_CC_SRC) : $(SV_FLEX_SRC)
	$(FLEX) $^

$(SV_BISON_CC_SRC) : $(SV_BISON_SRC)
	$(BISON) $^
	@perl -pi -e 's/enum yytokentype/enum svtokentype/' svparser.bison.hh


$(PP_FLEX_CC_SRC) : $(PP_FLEX_SRC)
	$(FLEX) $^
	@perl -pi -e 's/\#undef yytext_ptr//' vpp.flex.cc


$(PP_BISON_CC_SRC) : $(PP_BISON_SRC)
	$(BISON) $^


tar:
	rm -f src.tar*
	tar cvf src.tar $(M_CC_SRC) $(M_FLEX_SRC) $(M_BISON_SRC) 	      \
                        $(SV_CC_SRC) $(SV_FLEX_SRC) $(SV_BISON_SRC) 	      \
                        $(PP_CC_SRC) $(PP_FLEX_SRC) $(PP_BISON_SRC) $(PP_INC) \
                        $(UTIL_CC_SRC)  $(TOP_CC_SRC)			      \
                        CodeBlock.hh   MetaHDL.hh     Statement.hh	      \
                        Wrapper.hh     Expression.hh  Mfunc.hh vpp.hh	      \
                        Table.hh Makefile
	bzip2 src.tar

clean: 
	rm -fv $(M_FLEX_CC_SRC) $(M_BISON_CC_SRC) $(M_BISON_INC) $(M_BISON_OUTPUT) $(SV_FLEX_CC_SRC) $(SV_BISON_CC_SRC)  $(SV_BISON_INC) $(SV_BISON_OUTPUT) $(PP_FLEX_CC_SRC) $(PP_BISON_CC_SRC) $(PP_BISON_INC) $(OBJS) $(BISON_AUX_INC) .depend mhdlc src.tar* *~



-include .depend