# Simple tests for an adder module
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Timer,RisingEdge,ReadOnly,ReadWrite,NextTimeStep,Lock,FallingEdge
from cocotb.drivers import BusDriver
from cocotb.monitors import BusMonitor
from cocotb.result import TestFailure
import random

class vr_master(BusDriver):

    _signals = ["valid","data","ready"]

    def __init__(self, entity, name, clock, valid_max_delay=0, wait_ready=True, **kwargs):

        BusDriver.__init__(self,entity,name,clock,**kwargs)

        self.log.info("Driver start initialization: %s",name)

        self.bus.valid.setimmediatevalue(0)
        self.bus.data.setimmediatevalue(0)

        self.delay_max = valid_max_delay
        self.wait_ready = wait_ready

        self.busy = False

    @cocotb.coroutine
    def _send_write_data(self,data):

        delay = random.randint(0,self.delay_max)

        for cycle in range(delay):
            yield RisingEdge(self.clock)

        self.bus.valid <= 1
        self.bus.data <= data

        if (self.wait_ready):
            yield self._wait_for_signal(self.bus.ready)

        yield RisingEdge(self.clock)

        self.bus.valid <= 0

    @cocotb.coroutine
    def write_data(self,data):

        self.busy = True

        yield self._send_write_data(data)

        self.busy = False

    @cocotb.coroutine
    def write_packet(self,packet):

        pack = packet.copy()

        self.busy = True

        yield RisingEdge(self.clock)

        for i,data in enumerate(pack):
            yield self._send_write_data(data)

        self.log.info("Packet was sent of %d words" % len(pack))

        self.busy = False

        
class vr_slave(BusDriver):

    _signals = ["valid","data","ready"]

    packet = []

    def __init__(self, entity, name, clock, ready_max_delay=0, **kwargs):

        BusDriver.__init__(self,entity,name,clock,**kwargs)

        self.log.info("Driver start initialization: %s",name)

        self.bus.ready.setimmediatevalue(1)

        self.delay_max = ready_max_delay

        self.wait = False

        cocotb.fork(self._random_ready())

    @cocotb.coroutine
    def _random_ready(self):

        if self.delay_max!=0:
            while True:

                delay = random.randint(0,self.delay_max)
    
                for i in range(delay):
                    yield RisingEdge(self.clock)
                    self.bus.ready <= 0
    
                self.bus.ready <= 1

    @cocotb.coroutine       
    def _receive_data(self):

        while True:
            yield RisingEdge(self.clock)
            yield ReadOnly()
            if self.bus.valid.value and self.bus.ready.value:
                break

        return self.bus.data.value

    @cocotb.coroutine
    def receive_data(self):

        self.wait = True

        data = yield self._receive_data()

        self.wait = False

        return data

    @cocotb.coroutine
    def receive_packet(self,len):

        self.wait = True
        
        for i in range(len):
            data = yield self.receive_data()
            self.packet.append(data)

        self.wait = False

        return self.packet

    def get_packet(self,clean):

        if clean:
            tmp = self.packet.copy()
            self.packet = []
        else:
            tmp = self.packet.copy()
        
        return tmp

class vr_monitor(BusMonitor):

    _signals = ["valid","data","ready"]

    packet = []

    def __init__(self, entity, name, clock, **kwargs):

        BusMonitor.__init__(self,entity,name,clock,**kwargs)

        self.log.info("Driver start initialization: %s",name)

    @cocotb.coroutine
    def _monitor_recv(self):

        while True:
            
            yield FallingEdge(self.clock)
            yield ReadOnly()

            if self.bus.valid.value and self.bus.ready.value:
                vec = int(self.bus.data.value)
                self._recv(vec)

