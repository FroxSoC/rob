SIM ?= modelsim
PWD =$(shell pwd)

ARCH ?=i686

SIM_BUILD=./

COCOTB_RESOLVE_X=RANDOM

TOPLEVEL_LANG := verilog

TB_FILELIST = ./tb.files

VERILOG_SOURCES = $(shell python $(PWD)/../scripts/abspath_gen.py $(TB_FILELIST))

PYTHONPATH := $(PWD)/pytest/

TOPLEVEL := tb
MODULE   := pytest

include $(shell cocotb-config --makefiles)/Makefile.inc
include $(shell cocotb-config --makefiles)/Makefile.sim



