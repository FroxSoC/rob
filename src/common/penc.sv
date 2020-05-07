module penc #(
	parameter WIDTH = 16
	) (
	input  [        WIDTH-1:0] vec  ,
	output [$clog2(WIDTH)-1:0] idx  ,
	output                     found
);

function [$clog2(WIDTH):0] prior;
	input [WIDTH-1:0] vec;

	begin

		prior = {3'b0, 1'b0};

		for (int i=0; i<WIDTH; i++) begin 
			if (vec[i]) begin
				prior = {i, 1'b1}; // Override previous index
			end
		end

	end

	endfunction

assign {idx, found} = prior(vec);

endmodule