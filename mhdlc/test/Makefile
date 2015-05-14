include /home/xinmeng/mxmf/projects/scripts/makefile/mhdl_macro.mk

mhdlc = ../src/mhdlc
mhdl_opt    = -verilog --macro-case-modifier
mhdl_opt   += -lmhdlc.log
mhdl_src    = $(wildcard mhdl/*.mhdl)
mhdl_incdir = mhdl
mhdl_mbase  = mhdl
mhdl_ibase  = 
mhdl_rtldir = rtl

.PHONY: test
test:
	echo $(mhdl_src)

$(eval $(call batch-mhdl-file-rule,$(mhdl_src)))
