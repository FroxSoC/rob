module rob #(parameter NUM_CELL = 16) (
	input        clk       , // Clock
	input        rstn      , // Asynchronous reset active low

	vr_if.slave  host_req_i,
	vr_if.master host_rsp_o,

	vr_if.master mem_req_o ,
	vr_if.slave  mem_rsp_i
);

localparam NUM_CELL_LOG = $clog2(NUM_CELL);

rob_pkg::cell_t [NUM_CELL-1:0] tbl;
rob_pkg::cell_t cell_push_w;
rob_pkg::cell_t cell_fill_w;
rob_pkg::cell_t cell_pop_w;

logic [    NUM_CELL-1:0] tbl_busy_vec;
logic [NUM_CELL_LOG-1:0] tbl_fill_id ;
logic [NUM_CELL_LOG-1:0] tbl_push_id ;
logic [NUM_CELL_LOG-1:0] tbl_pop_id  ;

common_sync_fifo_if #(.DW(NUM_CELL_LOG),.DL(NUM_CELL_LOG)) fifo();

// ---------------------------------------- //
// ----------- Struct for Table ----------- //
// ---------------------------------------- //

always_comb begin : proc_cell_push_w

	cell_push_w.id    = host_req_i.data[0].id;
	cell_push_w.data  = 'h0;
	cell_push_w.busy  = 'b1;
	cell_push_w.valid = 'b0;

end

always_comb begin : proc_cell_fill_w

	cell_fill_w.id    = tbl[mem_rsp_i.data[0].id].id;
	cell_fill_w.data  = mem_rsp_i.data[0].data;
	cell_fill_w.busy  = 'b1;
	cell_fill_w.valid = 'b1;

end

always_comb begin : proc_cell_pop_w
	cell_pop_w = 'h0;
end

// ------------------------------------------------- //
// ----------- Control Signals for Table ----------- //
// ------------------------------------------------- //

assign tbl_push = host_req_i.valid && host_req_i.ready;
assign tbl_pop  = host_rsp_o.valid && host_rsp_o.ready;
assign tbl_fill = mem_rsp_i.valid;

assign tbl_fill_id = mem_rsp_i.data[0].id;
assign tbl_pop_id  = fifo.s.rdata;

penc #(.WIDTH(NUM_CELL)) i_penc (.vec(~tbl_busy_vec), .idx(tbl_push_id), .found());

// ----------------------------- //
// ----------- Table ----------- //
// ----------------------------- //

for (genvar i = 0; i < NUM_CELL; i++) begin

		always_ff @(posedge clk or negedge rstn) begin : proc_tbl
			if(~rstn) begin
				tbl[i] <= 0;
			end else begin
				tbl[i] <= (tbl_push && tbl_push_id==i) ? cell_push_w : 
						  (tbl_fill && tbl_fill_id==i) ? cell_fill_w :
						  (tbl_pop  && tbl_pop_id==i ) ? cell_pop_w  : tbl[i];
			end
		end

		assign tbl_busy_vec[i] = tbl[i].busy;
		
	end

// ---------------------------------- //
// ----------- Order FIFO ----------- //
// ---------------------------------- //

assign fifo.m.write = tbl_push;
assign fifo.m.read  = tbl_pop;
assign fifo.m.wdata = tbl_push_id;
assign fifo.m.clr   = 1'b0;

sync_fifo #(.DW(NUM_CELL_LOG),.DL(NUM_CELL_LOG)) i_order_fifo (
	.clk (clk ),
	.rstn(rstn),
	.fifo(fifo)
);

// ---------------------------------- //
// ----------- Interfaces ----------- //
// ---------------------------------- //

assign host_rsp_o.valid        = tbl[tbl_pop_id].valid && fifo.s.nempty;
assign host_rsp_o.data[0].id   = tbl[tbl_pop_id].id;
assign host_rsp_o.data[0].data = tbl[tbl_pop_id].data;

assign mem_req_o.valid         = host_req_i.valid && host_req_i.ready;
assign mem_req_o.data[0].id    = tbl_push_id;
assign mem_req_o.data[0].addr  = host_req_i.data[0].addr;

assign host_req_i.ready = fifo.s.nfull && mem_req_o.ready;

assign mem_rsp_i.ready = 1'b1;

endmodule