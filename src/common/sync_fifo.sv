// ----------------------------------------------------------------------------
// Module       : sync_fifo
// Description  : Synchronous FIFO with sync_fifo_if interfaces and static
//                flags
// ----------------------------------------------------------------------------

module sync_fifo (
                     input                     clk,rstn,
                     common_sync_fifo_if.slave fifo
                    );

parameter DW     = 32;
parameter DWI    = 1;
parameter DWO    = 1;
parameter DL     = 2;

localparam DEPTH = 1<<DL;

localparam TOP_AND = 32'hFFFFFFFF<<(DWO/2);
localparam BOT_AND = 32'hFFFFFFFF<<(DWI/2);

reg     [DW-1:0]     fifo_reg    [DEPTH-1:0];

reg     [DL:0]   top;
reg     [DL:0]   bot;

assign fifo.s.nempty = ((top[DL  :0] & TOP_AND)==(bot[DL  :0] & BOT_AND))                     ? 1'b0 : 1'b1;
assign fifo.s.nfull  = ((top[DL-1:0] & TOP_AND)==(bot[DL-1:0] & BOT_AND)) && top[DL]!=bot[DL] ? 1'b0 : 1'b1;

always @(posedge clk or negedge rstn)
    if (~rstn) begin
        top<=0;
        bot<=0;
    end else
    if (fifo.m.clr) begin
        top<=0;
        bot<=0;
    end
    else begin
        case ({fifo.m.write,fifo.m.read}) // synopsys full_case
            2'b00   : begin top<=top;       bot<=bot;       end
            2'b01   : begin top<=top;       bot<=bot + DWO; end
            2'b10   : begin top<=top + DWI; bot<=bot;       end
            2'b11   : begin top<=top + DWI; bot<=bot + DWO; end
        endcase
    end


always @(posedge clk)
if (fifo.m.write) begin
    for (int i = 0; i < DWI; i++) begin
        fifo_reg[top[DL-1:0]+i]<=fifo.m.wdata[DW*i +:DW];
    end
end

for (genvar i = 0; i < DWO; i++) begin
  
  assign fifo.s.rdata[DW*i +:DW] = fifo_reg[bot[DL-1:0]+i];

end

assign fifo.s.free   = (1<<DL) - (top - bot);
assign fifo.s.occ    = top - bot;

endmodule