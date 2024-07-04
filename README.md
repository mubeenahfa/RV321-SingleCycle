# RV321-SingleCycle soft-core and Testbench
This is a working single cycle RISCV soft core that works on the RV321 Instruction set.

## Overview
This is a working single cycle RISCV soft core that works on the RV321 Instruction set. It also contains a python testbench made with cocotb to simulate various RISCV instructions and compare them with expected outputs to authenticate functionality.

## Table of Contents

- [Project Structure](#project-structure)
- [Features](#features)
- [Setup](#setup)


## Project Structure
- **HDL**: Contains the Verilog source files for the RISC-V processor.
- **Test**: Contains the python testbench and make file for the RISC-V processor.
- **Instructions.hex**: Hex file with the instructions to be loaded into the testbench.
- **Control Unit.pdf**: contains rtl diagram of control unit.
- **Datapath RTL.pdf**: contains rtl diagram of datapath.
- **Project_report.pdf**: This is a detailed report on the workings of this soft core and testbench.
- **Top-Level RTL.pdf**: contains rtl diagram of the top module
- **riscv.py**: Cocotb testbench script.
- **README.md**: This file.

## Features

- **RISC-V Instruction Parsing**: Parses and simulates RISC-V instructions.
- **Endianness Handling**: Converts little-endian hex strings to big-endian binary strings.
- **Memory Operations**: Simulates byte-addressable memory for load and store instructions.
- **Logging**: Detailed logging of datapath and controller signals for debugging.
- **Instruction Simulation**: Simulates various RISC-V instruction types including R, I, S, B, U, and J types.

## Setup

### Prerequisites

- Python 3.x
- Cocotb
- Icarus Verilog (or other supported simulator)

