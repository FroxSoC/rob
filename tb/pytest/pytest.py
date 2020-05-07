# Simple tests for an adder module
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Timer,RisingEdge,ReadOnly,FallingEdge
from cocotb.result import TestFailure
from cocotb.scoreboard import Scoreboard
import random
import numpy as np
import os
import shlex
from argparse import ArgumentParser

import vr
import vr_mem

CLK_PERIOD = 10

def setup_clk(dut):
    cocotb.fork(Clock(dut.clk,CLK_PERIOD,'ns').start())

def packet_generate(args,max_num=16):
    
    tmp_a  = [random.randint(0,2**32) for iter in range(max_num)]
    tmp_id = [random.randint(0,1<<args.id_width) for iter in range(max_num)]

    tmp = []

    for i in range(max_num):
        tmp.append(tmp_a[i]<<args.id_width | tmp_id[i])
        
    return tmp

@cocotb.test()
def rob_simple_test(dut):

    # TB_ARGS parser

    parser = ArgumentParser(description='Arguments for test')

    parser.add_argument("-len","--length",dest="length",type=int,default=32)
    parser.add_argument("-dhreq","--max_delay_host_req",dest="dhreq",type=int,default=0)
    parser.add_argument("-dhrsp","--max_delay_host_rsp",dest="dhrsp",type=int,default=0)
    parser.add_argument("-dmreq","--max_delay_mem_req",dest="dmreq",type=int,default=0)
    parser.add_argument("-dmrsp","--max_delay_mem_rsp",dest="dmrsp",type=int,default=0)
    parser.add_argument("-id","--id_width",dest="id_width",type=int,default=4)

    argument_list = shlex.split(os.environ["PY_TB_ARGS"])

    args = parser.parse_args(argument_list)

    # Setup CLK and Reset

    vr_in  = vr.vr_master(dut,name="bug_host_req_i",clock=dut.clk,bus_separator=".",valid_max_delay=args.dhreq)
    vr_out = vr.vr_slave(dut,name="bug_host_rsp_o",clock=dut.clk,bus_separator=".",ready_max_delay=args.dhrsp)

    mem_req = vr.vr_slave(dut,name="bug_mem_req_o",clock=dut.clk,bus_separator=".",ready_max_delay=args.dmreq)
    mem_rsp = vr.vr_master(dut,name="bug_mem_rsp_i",clock=dut.clk,bus_separator=".",valid_max_delay=args.dmrsp)

    vr_out_mon = vr.vr_monitor(dut,name="bug_host_rsp_o",clock=dut.clk,bus_separator=".")

    setup_clk(dut)

    dut.rstn <= 0

    yield Timer(CLK_PERIOD*10,units='ns')

    dut.rstn <= 1

    # Init interfaces

    memory = vr_mem.vr_mem_cl(mem_req,mem_rsp,permutation=True)

    packet = packet_generate(args,random.randint(1,args.length))

    with open("./ref.dat","w") as f:
        for i in packet:
            f.write(str(i)+'\n')

    scoreboard = Scoreboard(dut)
    scoreboard.add_interface(vr_out_mon,packet)

    cocotb.fork(vr_out.receive_packet(len(packet)))
    cocotb.fork(vr_in.write_packet(packet))
   
    while (vr_in.busy):
        yield RisingEdge(dut.clk)

    memory.th = 0 # flush buffer

    while (vr_out.wait):
        yield RisingEdge(dut.clk)

    yield Timer(CLK_PERIOD,units='ns')

    packet_out = list(map(int,vr_out.get_packet(clean=True)))

    with open("./out.dat","w") as f:
        for i in packet_out:
            f.write(str(i)+'\n')

 





    


