# Simple tests for an adder module
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Timer,RisingEdge,ReadOnly,FallingEdge,NextTimeStep
from cocotb.result import TestFailure
import random
import numpy as np
import vr

class vr_mem_cl():

	def __init__(self,vr_req,vr_rsp,addr_range=[0,2**32],max_delay=0,permutation=False, th=4):

		self.memory = range(0,2**32)
		self.permutation = permutation

		self.vr_req = vr_req
		self.vr_rsp = vr_rsp

		self.buffer = []
		self.th = th

		cocotb.fork(self.memrsp())
		cocotb.fork(self.memreq())

	@cocotb.coroutine
	def memreq(self):

		while True:
			req = yield self.vr_req.receive_data()
			self.buffer.append(req)
	
	@cocotb.coroutine
	def memrsp(self):

		while True:
			if len(self.buffer)>self.th and self.permutation:
				random.shuffle(self.buffer)

			if len(self.buffer)>0:
				yield self.vr_rsp.write_data(self.buffer.pop(0))
			else:
				yield RisingEdge(self.vr_rsp.clock)





		
