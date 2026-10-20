# =============================================================================
# Makefile del BLINKER (Semana 1, paso 0)
#   make sim                  simula y muestra PC y LEDs en la terminal
#   make wave                 abre las formas de onda
#   make rtl                  diagrama RTL (build/blinker.svg)
#   make syn BOARD=colorlight | tangnano9k
#   make config BOARD=...
# =============================================================================
SHELL := /bin/bash
BOARD ?= colorlight

ifneq ($(shell command -v digital-logic-design 2>/dev/null),)
RUN ?= source digital-logic-design activate >/dev/null &&
else
RUN ?=
endif

YOSYS     ?= yosys
IVERILOG  ?= iverilog
VVP       ?= vvp
GTKWAVE   ?= gtkwave
NEXTPNR_ECP5  ?= nextpnr-ecp5
ECPPACK       ?= ecppack
NEXTPNR_GOWIN ?= nextpnr-himbaechel
GOWIN_PACK    ?= gowin_pack
LOADER    ?= openFPGALoader
RTL_GEN   ?= netlist2svg
B := build

.PHONY: sim wave rtl syn config clean

sim:
	mkdir -p $(B)
	$(RUN) $(IVERILOG) -g2012 -o $(B)/tb_blinker.vvp sim/tb_blinker.v rtl/blinker.v
	$(RUN) $(VVP) -n $(B)/tb_blinker.vvp

wave:
	$(RUN) $(GTKWAVE) $(B)/tb_blinker.vcd &

rtl:
	mkdir -p $(B)
	$(RUN) $(YOSYS) -q -p "prep -top blinker; write_json $(B)/blinker.json" rtl/blinker.v
	$(RUN) $(RTL_GEN) $(B)/blinker.json -o $(B)/blinker.svg

ifeq ($(BOARD),colorlight)
BITSTREAM := $(B)/colorlight.bit
CABLE_PINES ?= 0:3:4:1
$(BITSTREAM): rtl/blinker.v boards/colorlight/top_colorlight.v boards/colorlight/colorlight.lpf
	mkdir -p $(B)
	$(RUN) $(YOSYS) -q -p "synth_ecp5 -top top_colorlight -json $(B)/colorlight.json" rtl/blinker.v boards/colorlight/top_colorlight.v -l $(B)/yosys.log
	$(RUN) $(NEXTPNR_ECP5) --25k --package CABGA256 --speed 6 --freq 25 --json $(B)/colorlight.json \
	  --lpf boards/colorlight/colorlight.lpf --textcfg $(B)/colorlight.config -l $(B)/nextpnr.log 2> /dev/null
	$(RUN) $(ECPPACK) $(B)/colorlight.config $(BITSTREAM)
config:
	$(RUN) $(LOADER) -c ft232RL --pins=$(CABLE_PINES) --freq 3000000 -m $(BITSTREAM)
else ifeq ($(BOARD),tangnano9k)
BITSTREAM := $(B)/tangnano9k.fs
$(BITSTREAM): rtl/blinker.v boards/tangnano9k/top_tangnano9k.v boards/tangnano9k/tangnano9k.cst
	mkdir -p $(B)
	$(RUN) $(YOSYS) -q -p "synth_gowin -top top_tangnano9k -json $(B)/tangnano9k.json" rtl/blinker.v boards/tangnano9k/top_tangnano9k.v -l $(B)/yosys.log
	$(RUN) $(NEXTPNR_GOWIN) --device GW1NR-LV9QN88PC6/I5 --vopt family=GW1N-9C \
	  --vopt cst=boards/tangnano9k/tangnano9k.cst --freq 27 \
	  --json $(B)/tangnano9k.json --write $(B)/tangnano9k_pnr.json -l $(B)/nextpnr.log 2> /dev/null
	$(RUN) $(GOWIN_PACK) -d GW1N-9C -o $(BITSTREAM) $(B)/tangnano9k_pnr.json
config:
	$(RUN) $(LOADER) -b tangnano9k $(BITSTREAM)
else
$(error BOARD debe ser colorlight o tangnano9k)
endif

syn: $(BITSTREAM)

clean:
	rm -rf $(B)
