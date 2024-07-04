# ==============================================================================
# Authors:              Mubeen Ahmad Fayyaz
#
# Cocotb Testbench:     For Single Cycle RISCV Project
#
# Description:
# ------------------------------------
# Test bench for the single cycle RISCV processor that allows us to test our single cycle computer
#
# License:  
# ==============================================================================

import logging
import cocotb
from Helper_lib import read_file_to_list, rotate_right, shift_helper, reverse_hex_string_endiannes
from Helper_Student import Log_Datapath,Log_Controller
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge, RisingEdge, Edge, Timer
from cocotb.binary import BinaryValue

def convert_to_signed(n, l):
    if n & (1 << (l - 1)):
        n -= (1 << l)
    return n
class type_r:

    ADDSUB = 0
    XOR = 4
    OR = 6
    AND = 7
    SLL = 1
    SRLA  = 5
    SLT = 2
    SLTU = 3
class type_i:
    LB = 0x0
    LH = 0x1
    LW = 0x2
    LBU = 0x4
    LHU = 0x5
class type_b:
    BEQ = 0x0
    BNE = 0x1
    BLT = 0x4
    BGE = 0x5
    BLTU = 0x6
    BGEU = 0x7

class type_s:
    SB = 0x0
    SH = 0x1
    SW = 0x2
class ByteAddressableMemory:
    def __init__(self, size):
        self.size = size
        self.memory = bytearray(size)  # Initialize memory as a bytearray of the given size

    def read(self, address, read_type='word'):
        if read_type == 'byte':
            length = 1
        elif read_type == 'halfword':
            length = 2
        elif read_type == 'word':
            length = 4
        else:
            raise ValueError("Invalid read type specified")

        if address < 0 or address + length > self.size:
            raise ValueError("Invalid memory address or length")
        return_val = bytes(self.memory[address : address + length])
        return_val = return_val[::-1]
        return return_val

    def write(self, address, data, write_type='word'):
        if write_type == 'byte':
            length = 1
        elif write_type == 'halfword':
            length = 2
        elif write_type == 'word':
            length = 4
        else:
            raise ValueError("Invalid write type specified")
        data_bytes = data.to_bytes(length, byteorder='little')
        self.memory[address : address + length] = data_bytes 
def little_to_big_endian_binary(bin_str):
    # Ensure the binary string is a multiple of 8 bits (1 byte)
    if len(bin_str) % 8 != 0:
        raise ValueError("Binary string length must be a multiple of 8")

    # Split the input binary string into a list of bytes (8 bits each)
    byte_list = [bin_str[i:i + 8] for i in range(0, len(bin_str), 8)]

    # Reverse the order of bytes to convert from little-endian to big-endian
    byte_list.reverse()

    # Join the bytes back into a single binary string
    big_endian_str = ''.join(byte_list)
    return big_endian_str

#custom class for extracting relevant information from the given instructions
class Instruction:
    def __init__(self, instruction):
        #self.binary_instr = little_to_big_endian_binary(format(int(instruction, 16), '032b'))
        self.binary_instr = format(int(instruction, 16), '032b')
        # Extract the fields based on the binary representation
        self.Op = int(self.binary_instr[25:32], 2)
        self.rd = int(self.binary_instr[20:25], 2)
        self.funct3 = int(self.binary_instr[17:20], 2)
        self.rs1 = int(self.binary_instr[12:17], 2)
        self.rs2 = int(self.binary_instr[7:12], 2)
        self.funct7 = int(self.binary_instr[1:7], 2)
        
        # Extract the immediate values
        self.imm_i = int(self.binary_instr[0:12], 2)
        
        self.imm_s = (int(self.binary_instr[0:6], 2) << 5) | int(self.binary_instr[20:25], 2)
        self.imm_b = (int(self.binary_instr[0], 2) << 12) | (int(self.binary_instr[24], 2) << 11) | (int(self.binary_instr[1:7], 2) << 5) | (int(self.binary_instr[20:24], 2) << 1)
        self.imm_u = int(self.binary_instr[0:20], 2) << 12
        self.imm_j = (int(self.binary_instr[0], 2) << 20) | (int(self.binary_instr[12:20], 2) << 12) | (int(self.binary_instr[11], 2) << 11) | (int(self.binary_instr[1:11], 2) << 1)
        
    def extract_bits(self, start, end):
        # Extract bits from 'start' to 'end' (inclusive) and return as integer
        mask = (1 << (end - start + 1)) - 1
        return (self.instruction >> start) & mask

    def log(self, logger):
        # Log the extracted fields for debugging purposes
        logger.debug(f"Instruction: {self.binary_instr}")
        #logger.debug(f"Instruction unconverted: {self.binary_instr1}")
        logger.debug(f"Opcode: {self.Op}")
        logger.debug(f"rd: {self.rd}")
        logger.debug(f"funct3: {self.funct3}")
        logger.debug(f"rs1: {self.rs1}")
        logger.debug(f"rs2: {self.rs2}")
        logger.debug(f"funct7: {self.funct7}")
        logger.debug(f"imm_i: {self.imm_i}")
        logger.debug(f"imm_s: {self.imm_s}")
        logger.debug(f"imm_b: {self.imm_b}")
        logger.debug(f"imm_u: {self.imm_u}")
        logger.debug(f"imm_j: {self.imm_j}")
       
    


# Setup logging
logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger()

class TB:
    def __init__(self, Instruction_list,dut,dut_PC,dut_regfile):
        self.dut = dut
        self.dut_PC = dut_PC
        self.dut_regfile = dut_regfile
        self.Instruction_list = Instruction_list
        self.logger = logging.getLogger(__name__)
        self.logger.setLevel(logging.DEBUG)
        #Initial values are all 0 as in a FPGA
        self.PC = 0
        self.Register_File =[]
        for i in range(32):
            self.Register_File.append(0)
        #Memory is a special class helper lib to simulate HDL counterpart    
        self.memory = ByteAddressableMemory(1024)
        self.clock_cycle_count = 0        
          
    #Calls user populated log functions    
    def log_dut(self):
        Log_Datapath(self.dut,self.logger)
        Log_Controller(self.dut,self.logger)

    #Compares and lgos the PC and register file of Python module and HDL design
    def compare_result(self):
        self.logger.debug("************* Performance Model / DUT Data  **************")
        self.logger.debug("PC:%08x \t PC:%08x",self.PC-4,self.dut_PC.value.integer-4)
        self.logger.debug(f"mem: {int.from_bytes(self.memory.read(2, 'word'))}")
        for i in range(32):
            self.logger.debug("Register%d: %08x \t %08x",i,self.Register_File[i], self.dut_regfile.Reg_Out[i].value.integer)
        assert self.PC == self.dut_PC.value
        assert self.dut_regfile.Reg_Out[0].value == 0
        for i in range(1, 32):
           assert self.Register_File[i] == self.dut_regfile.Reg_Out[i].value

    def write_to_register_file(self,register_no, data):
       
        self.Register_File[register_no] = data


    def performance_model(self):
        self.logger.debug("**************** Clock cycle: %d **********************", self.clock_cycle_count)
        self.clock_cycle_count += 1
        # Read current instructions, extract and log the fields
        self.logger.debug("**************** Instruction No: %d **********************", int((self.PC) / 4))
        current_instruction = self.Instruction_list[int((self.PC) / 4)]
        current_instruction = current_instruction.replace(" ", "")
        # We need to reverse the order of bytes since little endian makes the string reversed in Python
        current_instruction = reverse_hex_string_endiannes(current_instruction)
        # Initial R15 value for operations
        self.PC = self.PC + 4
    
        inst_fields = Instruction(current_instruction)
        inst_fields.log(self.logger)
       

        # I will implement XORID here later and CHANGE COMMENT once implemented
        if inst_fields.Op == 11 and inst_fields.funct3 == 4:
            datap_result =  self.Register_File[inst_fields.rs1] ^ 0x3EE2
            self.write_to_register_file(inst_fields.rd, datap_result)
    #type r handled below
        elif inst_fields.Op == 51:
            rs1_val = convert_to_signed(self.Register_File[inst_fields.rs1],32)
            rs2_val = convert_to_signed(self.Register_File[inst_fields.rs2],32)

            # Type R case
            match inst_fields.funct3:
                case type_r.ADDSUB:
                    if inst_fields.funct7 == 0:
                        datap_result = rs1_val + rs2_val
                        self.write_to_register_file(inst_fields.rd, datap_result)
                    else:
                        datap_result = rs1_val - rs2_val
                        self.write_to_register_file(inst_fields.rd, datap_result)
                case type_r.XOR:
                    datap_result = self.Register_File[inst_fields.rs1] ^ self.Register_File[inst_fields.rs2]
                    self.write_to_register_file(inst_fields.rd, datap_result)
                case type_r.AND:
                    datap_result = rs1_val & rs2_val
                    self.write_to_register_file(inst_fields.rd, datap_result)
                case type_r.OR:
                    datap_result = rs1_val | rs2_val
                    self.write_to_register_file(inst_fields.rd, datap_result)

                case type_r.SLL:
                    datap_result = shift_helper(rs1_val, rs2_val & 0x1F, 0)
                    self.write_to_register_file(inst_fields.rd, datap_result)

                case type_r.SRLA:
                    if inst_fields.funct7 == 0x00:
                        datap_result = convert_to_signed(shift_helper(self.Register_File[inst_fields.rs1],self.Register_File[inst_fields.rs2] & 0x1F, 1),32)
                    elif inst_fields.funct7 == 0x20:
                        datap_result = shift_helper(rs1_val, rs2_val & 0x1F, 2)
                    self.write_to_register_file(inst_fields.rd, datap_result)

                case type_r.SLT:
                    datap_result = 1 if rs1_val < rs2_val else 0
                    self.write_to_register_file(inst_fields.rd, datap_result)

                case type_r.SLTU:
                    datap_result = 1 if (self.Register_File[inst_fields.rs1] & 0xFFFFFFFF) < (self.Register_File[inst_fields.rs2] & 0xFFFFFFFF) else 0
                    self.write_to_register_file(inst_fields.rd, datap_result)
                case _:
                    self.logger.error("Not supported data processing instruction!!")
                    assert False
    #type I data instructions handled below    
        elif inst_fields.Op == 19:
            if inst_fields.imm_i & 0x800 != 0:
                        inst_fields.imm_i |= 0xFFFFF000 
            match inst_fields.funct3:
                
                case type_r.ADDSUB:
                    datap_result = self.Register_File[inst_fields.rs1] + shift_helper(inst_fields.imm_i,0,0) 
                    self.write_to_register_file(inst_fields.rd, datap_result)
                case type_r.XOR:
                    datap_result = self.Register_File[inst_fields.rs1] ^ shift_helper(inst_fields.imm_i,0,0)
                    self.write_to_register_file(inst_fields.rd, datap_result)
                case type_r.AND:
                    datap_result = self.Register_File[inst_fields.rs1] & shift_helper(inst_fields.imm_i,0,0)
                    self.write_to_register_file(inst_fields.rd, datap_result)
                case type_r.OR:
                    datap_result = self.Register_File[inst_fields.rs1] | shift_helper(inst_fields.imm_i,0,0)
                    self.write_to_register_file(inst_fields.rd, datap_result)

                case type_r.SLL:
                    datap_result = shift_helper(self.Register_File[inst_fields.rs1], inst_fields.rs2  & 0x1F, 0)
                    self.write_to_register_file(inst_fields.rd, datap_result)

                case type_r.SRLA:
                    if inst_fields.funct7 == 0x00:
                        datap_result = shift_helper(self.Register_File[inst_fields.rs1], inst_fields.rs2 & 0x1F, 1)
                    elif inst_fields.funct7 == 0x20:
                        datap_result = shift_helper(self.Register_File[inst_fields.rs1], inst_fields.rs2 & 0x1F, 2)
                    self.write_to_register_file(inst_fields.rd, datap_result)

                case type_r.SLT:
                    datap_result = 1 if convert_to_signed(self.Register_File[inst_fields.rs1],32) < inst_fields.imm_i else 0
                    self.write_to_register_file(inst_fields.rd, datap_result)

                case type_r.SLTU:
                    datap_result = 1 if ((self.Register_File[inst_fields.rs1] & 0xFFFFFFFF) < inst_fields.imm_i & 0xFFF) else 0
                    self.write_to_register_file(inst_fields.rd, datap_result)
                case _:
                    self.logger.error("Not supported data processing instruction!!")
                    assert False
    #type I memory load instructions handled below
        elif inst_fields.Op == 3:
            base_address = self.Register_File[inst_fields.rs1] + inst_fields.imm_i
            match inst_fields.funct3:
                case type_i.LB:   
                    byte_val = int.from_bytes(self.memory.read(base_address, 'byte'))
                    if byte_val & 0x80:  # Sign extend if negative
                        byte_val |= 0xFFFFFF00                 
                    self.write_to_register_file(inst_fields.rd, byte_val)
                case type_i.LH:
                    halfword_val = int.from_bytes(self.memory.read(base_address, 'halfword'))
                    if halfword_val & 0x8000:  # Sign extend if negative
                        halfword_val |= 0xFFFF0000
                    self.write_to_register_file(inst_fields.rd, halfword_val)
                case type_i.LW:
                    word_val = int.from_bytes(self.memory.read(base_address, 'word'))
                    self.write_to_register_file(inst_fields.rd, word_val)
                case type_i.LBU:
                    byte_val = int.from_bytes(self.memory.read(base_address, 'byte'))
                    byte_val &= 0x000000FF
                    self.write_to_register_file(inst_fields.rd, byte_val)
                case type_i.LHU:
                    halfword_val =  int.from_bytes(self.memory.read(base_address, 'halfword'))
                    halfword_val &= 0x0000FFFF
                    self.write_to_register_file(inst_fields.rd, halfword_val)
                case _:
                    self.logger.error("Not supported load instruction!!")
                    assert False
    #type s memory store instructions below
        elif inst_fields.Op == 35:
            base_address = self.Register_File[inst_fields.rs1] + inst_fields.imm_s
            match inst_fields.funct3:
                case type_s.SB:
                    self.memory.write(base_address,self.Register_File[inst_fields.rs2] & 0XFF, 'byte')
                case type_s.SH:
                    self.memory.write(base_address,self.Register_File[inst_fields.rs2] & 0XFFFF, 'halfword')
                case type_s.SW:
                   self.memory.write(base_address,self.Register_File[inst_fields.rs2] & 0XFFFFFFFF, 'word')

                case _:
                    self.logger.error("Not supported load instruction!!")
                    assert False
    #type b r=instructions handled below    
        elif inst_fields.Op == 99:  # Branch instructions
            self.PC = self.PC 
            rs1_val = self.Register_File[inst_fields.rs1]
            rs2_val = self.Register_File[inst_fields.rs2]
            offset = inst_fields.imm_b 
            match inst_fields.funct3:
                case type_b.BEQ:
                    if rs1_val == rs2_val:
                        self.PC += offset
                case type_b.BNE:
                    if rs1_val != rs2_val:
                        self.PC += offset 
                case type_b.BLT:
                    if rs1_val < rs2_val:
                        self.PC += offset
                case type_b.BGE:
                    if rs1_val >= rs2_val:
                        self.PC += offset
                case type_b.BLTU:
                    if (rs1_val & 0xFFFFFFFF) < (rs2_val & 0xFFFFFFFF):
                        self.PC += offset
                case type_b.BGEU:
                    if (rs1_val & 0xFFFFFFFF) >= (rs2_val & 0xFFFFFFFF):
                        self.PC += offset
                case _:
                    self.logger.error("Not supported branch instruction!!")
                    assert False
    #type j instructins handled below
        elif inst_fields.Op == 111:
            self.PC = self.PC
            datap_result = self.PC  
            self.write_to_register_file(inst_fields.rd, datap_result)
            self.PC += inst_fields.imm_j
        elif inst_fields.Op == 103:
            self.PC = self.PC - 4
            datap_result = self.PC + 4 
            self.write_to_register_file(inst_fields.rd, datap_result)
            self.PC = inst_fields.imm_i + self.Register_File[inst_fields.rs1]
    #type U handled below
        elif inst_fields.Op == 55:
            datap_result = shift_helper(inst_fields.imm_u, 0, 0) 
            self.write_to_register_file(inst_fields.rd, datap_result)
        elif inst_fields.Op == 23:
            datap_result = self.PC - 4 + shift_helper(inst_fields.imm_u, 0, 0) 
            self.write_to_register_file(inst_fields.rd, datap_result)
        else:
            self.logger.error("Invalid operation type")
            assert False


    async def run_test(self):
        self.performance_model()
        #Wait 1 us the very first time bc. initially all signals are "X"
        await Timer(1, units="us")
        self.log_dut()
        await RisingEdge(self.dut.clk)
        await FallingEdge(self.dut.clk)
        self.compare_result()
        while(int(self.Instruction_list[int((self.PC)/4)].replace(" ", ""),16)!=0 and int(self.Instruction_list[int((self.PC+4)/4)].replace(" ", ""),16)!=0 and int(self.Instruction_list[int((self.PC+8)/4)].replace(" ", ""),16)!=0) :
            self.performance_model()
            #Log datapath and controller before clock edge, this calls user filled functions
            self.log_dut()
            await RisingEdge(self.dut.clk)
            await FallingEdge(self.dut.clk)
            self.compare_result()
            input()
                
                   
@cocotb.test()
async def Single_cycle_test(dut):
    #Generate the clock
    await cocotb.start(Clock(dut.clk, 10, 'us').start(start_high=False))
    #Reset onces before continuing with the tests
    dut.reset.value=1
    await RisingEdge(dut.clk)
    dut.reset.value=0
    await FallingEdge(dut.clk)
    instruction_lines = read_file_to_list('Instructions.hex')
    #Give PC signal handle and Register File MODULE handle
    tb = TB(instruction_lines,dut, dut.PC, dut.my_datapath.My_RegisterFile)
    await tb.run_test()
 
        
   