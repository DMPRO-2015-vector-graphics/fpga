vcd dumpvars -m @uut@
vcd dumplimit 1073741824
vcd dumpon
restart
run all
vcd dumpflush
quit
