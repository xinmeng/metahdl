

vericom -full64 -debug_pp -sverilog -y . +libext+.v +libext+.sv +lint=all -P /tools/novas/verdi/2013.01/share/PLI/VCS/LINUX64/novas.tab /tools/novas/verdi/2013.01/share/PLI/VCS/LINUX64/pli.a top.v field.v priority_mux.v one_hot_mux.v


vcs -full64 -debug_pp -sverilog -y . +libext+.v +libext+.sv +lint=all -P /tools/novas/verdi/2013.01/share/PLI/VCS/LINUX64/novas.tab /tools/novas/verdi/2013.01/share/PLI/VCS/LINUX64/pli.a top.v


