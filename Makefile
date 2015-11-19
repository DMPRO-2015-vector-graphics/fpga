VARS_OLD := $(.VARIABLES)

XILINX_BINDIR = /opt/Xilinx/12.4/ISE_DS/ISE/bin/lin
COREGEN = ${XILINX_BINDIR}/coregen
XST = ${XILINX_BINDIR}/xst
NGDBUILD = ${XILINX_BINDIR}/ngdbuild
MAP = ${XILINX_BINDIR}/map
PAR = ${XILINX_BINDIR}/par
BITGEN = ${XILINX_BINDIR}/bitgen
TRCE = ${XILINX_BINDIR}/trce
FUSE = ${XILINX_BINDIR}/fuse

SHELL = /bin/bash

TOP_NAME ?= VECTOR3K
SUPPORT_SRC = $(addprefix ${CURDIR}/,$(shell find supportFiles -type f))
STUDENT_SRC = $(addprefix ${CURDIR}/,$(shell find src -type f))
TEST_SRC = $(addprefix ${CURDIR}/,$(shell find test -type f -name '*.vhd' -o -name '*.v'))
CONSTRAINT_FILES = $(addprefix ${CURDIR}/,$(shell find supportFiles -type f -name '*.ucf'))
IP_FILES = $(addprefix ${CURDIR}/,$(shell find supportFiles -type f -name '*.xco'))
IP_NETLISTS = ${IP_FILES:.xco=.ngc}

WORK_DIR = ${CURDIR}/work
PROD_DIR = ${CURDIR}/products
TEST_DIR = ${CURDIR}/test

BITGEN_OUT = ${PROD_DIR}/${TOP_NAME}.bit
PAR_OUT = ${PROD_DIR}/${TOP_NAME}.ncd
MAP_OUT = ${PROD_DIR}/${TOP_NAME}_map.ncd
TRANSLATE_OUT = ${PROD_DIR}/${TOP_NAME}.ngd
SYNTH_OUT = ${PROD_DIR}/${TOP_NAME}.ngc
PROJECT_FILES = ${TOP_NAME}.xst ${TOP_NAME}.prj
TIMING_REPORT = ${PROD_DIR}/${TOP_NAME}_postpar_timing.twr

.DEFAULT_GOAL: gen

.PHONY: prj synth trans map par impl gen timing_report
gen: ${BITGEN_OUT}

${BITGEN_OUT}: ${PAR_OUT}
# Generate bitfile: produces the final FPGA configuration.
	@echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
	@echo -e "\n\n\n"
	@echo "Generating bitfile \"$@\""
	@echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
	@. /opt/Xilinx/12.4/ISE_DS/settings32.sh && \
	cd ${WORK_DIR} && \
	cp $^ . && \
	${BITGEN} -intstyle ise -f ${CURDIR}/${TOP_NAME}.ut $< ${TOP_NAME}.bit && \
	cp -v $(notdir $@) $(dir $@)

timing_report: ${TIMING_REPORT}
	@echo "Final post-PaR report produced in $<"

${TIMING_REPORT}: ${PAR_OUT} ${PROD_DIR}/${TOP_NAME}.pcf
	@echo "Producing post-PaR timing report"
	@echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
	@. /opt/Xilinx/12.4/ISE_DS/settings32.sh && \
	cd ${WORK_DIR} && \
	cp $^ . && \
	${TRCE} -intstyle xflow -v 3 -l 3 $(notdir ${PAR_OUT}) -o $@ ${TOP_NAME}.pcf

impl: ${PAR_OUT}

par: ${PAR_OUT}
${PAR_OUT}: ${MAP_OUT} ${PROD_DIR}/${TOP_NAME}.pcf
# Place and route: matches the FPGA components to actual instances, and connects them.
	@echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
	@echo -e "\n\n\n"
	@echo "Running place and route"
	@echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
	@. /opt/Xilinx/12.4/ISE_DS/settings32.sh && \
	cd ${WORK_DIR} && \
	cp $^ . && \
	${PAR} -w -intstyle ise -ol high -mt off ${TOP_NAME}_map.ncd ${TOP_NAME}.ncd ${TOP_NAME}.pcf && \
	cp -v $(notdir $@) ${TOP_NAME}.par $(dir $@)

map: ${MAP_OUT}
${MAP_OUT}: ${TRANSLATE_OUT}
# Map: maps netlist components to equivalent FPGA components within the available resources.
	@echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
	@echo -e "\n\n\n"
	@echo "Running map"
	@echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
	@. /opt/Xilinx/12.4/ISE_DS/settings32.sh && \
	cd ${WORK_DIR} && \
	cp $^ . && \
	${MAP} -intstyle ise -p xc6slx45-csg324-2 -w -logic_opt off -ol high -t 1 -xt 0 -register_duplication off -r 4 -global_opt off -mt off -ir off -pr off -lc off -power off -o ${TOP_NAME}_map.ncd ${TOP_NAME}.ngd ${TOP_NAME}.pcf  && \
	cp -v $(notdir $@) ${TOP_NAME}.pcf ${TOP_NAME}_map.mrp $(dir $@)


trans: ${TRANSLATE_OUT}
${TRANSLATE_OUT}: ${SYNTH_OUT} ${CONSTRAINT_FILES} ${IP_NETLISTS}
# Translate: merges netlists and constraint files.
	@echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
	@echo -e "\n\n\n"
	@echo "Running translate"
	@echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
	@. /opt/Xilinx/12.4/ISE_DS/settings32.sh && \
	cd ${WORK_DIR} && \
	cp ${SYNTH_OUT} ${IP_NETLISTS} . && \
	${NGDBUILD} -intstyle ise -dd _ngo -sd src/framework -nt timestamp $(addprefix -uc ,${CONSTRAINT_FILES})  -p xc6slx45-csg324-2 ${TOP_NAME}.ngc ${TOP_NAME}.ngd && \
	cp -v $(notdir $@) $(dir $@)


synth: ${SYNTH_OUT}

${SYNTH_OUT}: ${PROJECT_FILES}
# Synthesize: elaborates the design (inferring hardware), and creates an FPGA (LUT-based) implementation of it.
	@echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
	@echo -e "\n\n\n"
	@echo "Running synthesize"
	@echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
	@. /opt/Xilinx/12.4/ISE_DS/settings32.sh && \
	cd ${WORK_DIR} && \
	${XST} -intstyle ise -ifn "${CURDIR}/${TOP_NAME}.xst" -ofn "${TOP_NAME}.syr" && \
	cp -v $(notdir $@) ${TOP_NAME}.syr ${TOP_NAME}.ngr $(dir $@) 


prj: ${PROJECT_FILES}

${TOP_NAME}.xst: generic_xst.xst
	@echo -n "Generating XST file... "
	@sed -e 's/@designname@/${TOP_NAME}/' $< > $@ && echo "OK" || echo "failed"


${TOP_NAME}.prj: $(patsubst %.xco,%.vhd,${SUPPORT_SRC} ${STUDENT_SRC})
	@echo -n "Generating PRJ file... "
	@for f in $^; do \
	    case $$f in \
		*.v) echo "verilog $$f"; ;; \
	        *.vhd) echo "vhdl work $$f"; ;; \
		*) ;; \
	    esac; \
	done > $@ && echo "OK" || echo "failed"

# Target for generating VHDL from XCO specification.
# May need work
%.vhd %.ngc: %.xco
	@echo "Generating IP core from description file \"$*\""
	@. /opt/Xilinx/12.4/ISE_DS/ISE/settings32.sh && \
	cp -v src/coregen.cgp work/coregen.cgp && \
	cd ${WORK_DIR} && \
	${COREGEN} -p ./coregen.cgp -r -b $< && \
	cp -v $$(basename $*).vhd $(dir $@) && \
	(cp -v $$(basename $*).ngc $(dir $@) || :)

.PHONY: clean
clean:
	-find work -mindepth 1 -delete
	@-mkdir -p work/tmp

.PHONY:  purge
purge:	clean
	-find products -mindepth 1 -delete
	@-rm -v ${PROJECT_FILES}



.PRECIOUS: ${WORK_DIR}/%_driver 
.PRECIOUS: ${WORK_DIR}/%.prj 
.PRECIOUS: ${WORK_DIR}/sim_commands_%.tcl 
.PRECIOUS: ${PROD_DIR}/%.vcd ${WORK_DIR}/%.vcd

.PHONY: sims vcds vcd_sim_% sim_% clean_test

sims: $(addprefix ${WORK_DIR}/,$(addsuffix _driver,$(notdir ${TEST_SRC:.vhd=})))
vcds: $(addprefix ${PROD_DIR}/,$(notdir ${TEST_SRC:.vhd=.vcd}))

vcd_sim_%: ${PROD_DIR}/%.vcd
	@echo "VCD file produced in $<"

${PROD_DIR}/%.vcd: ${WORK_DIR}/%.vcd
	@cp -v $< $@

${WORK_DIR}/%.vcd: ${WORK_DIR}/%_driver ${WORK_DIR}/sim_commands_%.tcl
	@. /opt/Xilinx/12.4/ISE_DS/settings32.sh && \
	cd $(dir $<) && \
	echo "Running $< -tclbatch ${WORK_DIR}/sim_commands_$*.tcl" && \
	$< -vcdfile $@ -tclbatch ${WORK_DIR}/sim_commands_$*.tcl

${WORK_DIR}/%_driver: ${TEST_DIR}/%.vhd ${WORK_DIR}/%.prj
	@echo "Creating test driver from $^"
	@. /opt/Xilinx/12.4/ISE_DS/settings32.sh && \
	cd ${WORK_DIR} && \
	${FUSE} work.$* -prj ${WORK_DIR}/$*.prj -o $@

${WORK_DIR}/%.prj: ${CURDIR}/${TOP_NAME}.prj
	@cp $< $@
	@echo "vhdl work ${TEST_DIR}/$*.vhd" >> $@

${WORK_DIR}/sim_commands_%.tcl: generic_sim_commands.tcl ${TEST_DIR}/%.conf
	@echo -n "Generating $@... "; \
	uut=$$(head -n1 ${TEST_DIR}/$*.conf); \
	time=$$(tail -n1 ${TEST_DIR}/$*.conf); \
	sed -e "s!@uut@!$${uut}!" -e "s!@time@!$${time}!" generic_sim_commands.tcl > $@ && \
	echo "OK" || echo "SUCCESS"

${WORK_DIR}/sim_commands_%.tcl: generic_sim_commands.tcl ${TEST_DIR}/default.conf
	@echo -n "Generating $@... "; \
	uut=$$(head -n1 ${TEST_DIR}/default.conf); \
	time=$$(tail -n1 ${TEST_DIR}/default.conf); \
	sed -e "s!@uut@!$${uut}!" -e "s!@time@!$${time}!" generic_sim_commands.tcl > $@ && \
	echo "OK" || echo "SUCCESS"

sim_%: ${WORK_DIR}/%_driver
	@. /opt/Xilinx/12.4/ISE_DS/settings32.sh && \
	cd $(dir $<) && \
	tcl_arg=""; \
        waveform_arg=""; \
	if [ -f ${TEST_DIR}/$*.tcl ]; then \
	    tcl_arg="-tclbatch ${TEST_DIR}/$*.tcl"; \
	fi; \
	if [ -f ${TEST_DIR}/$*.wcfg ]; then \
	    waveform_arg="-view ${TEST_DIR}/$*.wcfg"; \
	fi; \
	echo "Running $< -gui $${waveform_arg} $${tcl_arg}"; \
	$< -gui $${waveform_arg} $${tcl_arg}

clean_test:
	@-rm -v work/{*.prj,*.tcl}

# Used for Makefile debugging.
.PHONY: print
print:
	$(foreach v, $(filter-out $(VARS_OLD) VARS_OLD, $(.VARIABLES)), $(info $(v) = $($(v))))
