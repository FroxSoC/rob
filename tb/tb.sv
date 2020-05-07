module tb ();

logic clk;
logic rstn;

vr_if #(.DTYPE(logic [$bits(rob_pkg::req_t)-1:0])) bug_host_req_i();
vr_if #(.DTYPE(logic [$bits(rob_pkg::rsp_t)-1:0])) bug_host_rsp_o();
vr_if #(.DTYPE(logic [$bits(rob_pkg::req_t)-1:0])) bug_mem_req_o();
vr_if #(.DTYPE(logic [$bits(rob_pkg::rsp_t)-1:0])) bug_mem_rsp_i();

vr_if #(.DTYPE(rob_pkg::req_t)) host_req_i();
vr_if #(.DTYPE(rob_pkg::rsp_t)) host_rsp_o();
vr_if #(.DTYPE(rob_pkg::req_t)) mem_req_o();
vr_if #(.DTYPE(rob_pkg::rsp_t)) mem_rsp_i();

assign host_req_i.data      = bug_host_req_i.data;
assign host_req_i.valid     = bug_host_req_i.valid;
assign bug_host_req_i.ready = host_req_i.ready;

assign bug_host_rsp_o.data  = host_rsp_o.data;
assign bug_host_rsp_o.valid = host_rsp_o.valid;
assign host_rsp_o.ready     = bug_host_rsp_o.ready;

assign bug_mem_req_o.data  = mem_req_o.data;
assign bug_mem_req_o.valid = mem_req_o.valid;
assign mem_req_o.ready     = bug_mem_req_o.ready;

assign mem_rsp_i.data       = bug_mem_rsp_i.data;
assign mem_rsp_i.valid      = bug_mem_rsp_i.valid;
assign bug_mem_rsp_i.ready  = mem_rsp_i.ready;

rob #(.NUM_CELL(16)) i_rob (
	.clk       (clk       ),
	.rstn      (rstn      ),
	.host_req_i(host_req_i),
	.host_rsp_o(host_rsp_o),
	.mem_req_o (mem_req_o ),
	.mem_rsp_i (mem_rsp_i )
);


endmodule