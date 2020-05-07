module arb #(parameter WIDTH = 16) (
	input [WIDTH-1:0] req  ,
	input [WIDTH-1:0] base ,
	input [WIDTH-1:0] grant
);

logic [2*WIDTH-1:0] double_req;
logic [2*WIDTH-1:0] double_grant;

assign double_req   = {req,req};
assign double_grant = double_req & ~(double_req-base);
assign grant = double_grant[WIDTH-1:0] | double_grant[2*WIDTH-1:WIDTH];

endmodule