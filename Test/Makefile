# Copyright (c) 2016 Technische Universitaet Dresden, Germany
# Chair for VLSI-Design, Diagnostic and Architecture
# Author: Martin Zabel
# All rights reserved.

CWD=$(shell pwd)

SIM ?= icarus
TOPLEVEL_LANG ?=verilog


VERILOG_SOURCES =C:/Users/mubee/OneDrive/Desktop/2415842_2417152_Project/2415842_2417152_Project/HDL/*.v


TOPLEVEL = RISCV_Computer
MODULE := riscv
COCOTB_HDL_TIMEUNIT=1us
COCOTB_HDL_TIMEPRECISION=1us

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim
