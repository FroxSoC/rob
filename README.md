# Reorder Buffer (Table)
## Prerequisites
* python 3.7 
* cocotb: https://pypi.org/project/cocotb/
* argparse: https://pypi.org/project/argparse/
* pyyaml: https://pypi.org/project/PyYAML/
* EDA sim: modelsim, incisive, vcs... (with full support of SystemVerilog (e.g. parametrized types) and VPI support)

## Help
make PY_TB_ARGS='--help'
~~~~
usage: cocotb [-h] [-len LENGTH] [-dhreq DHREQ] [-dhrsp DHRSP] [-dmreq DMREQ] [-dmrsp DMRSP] [-id ID_WIDTH]
Arguments for test
optional arguments:
   -h, --help            show this help message and exit
   -len LENGTH, --length LENGTH
   -dhreq DHREQ, --max_delay_host_req DHREQ
   -dhrsp DHRSP, --max_delay_host_rsp DHRSP
   -dmreq DMREQ, --max_delay_mem_req DMREQ
   -dmrsp DMRSP, --max_delay_mem_rsp DMRSP
   -id ID_WIDTH, --id_width ID_WIDTH
~~~~
## Simulation
make PY_TB_ARGS='-len 100' WAVES=1

