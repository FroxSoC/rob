package rob_pkg;

	localparam AW = 32;
	localparam DW = 32;
	localparam IW = 4;

	typedef struct packed {
		logic [AW-1:0] addr;
		logic [IW-1:0] id;
	} req_t;
	
	typedef struct packed {
		logic [DW-1:0] data;
		logic [IW-1:0] id;
	} rsp_t;

	typedef struct packed { 
		logic [DW-1:0] data ; 
		logic [IW-1:0] id   ; 
		logic          valid; 
		logic          busy ; 
	} cell_t;

endpackage