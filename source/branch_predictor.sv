`include "branch_predictor_if.vh"
`include "cpu_types_pkg.vh"

module branch_predictor (
	input logic CLK, nRST,
	branch_predictor_if bpif
);

import cpu_types_pkg::*;


assign bpif.pred_result = bpif.pred == 2'b10 || bpif.pred == 2'b11;

always_ff @(posedge CLK or negedge nRST) begin : proc_
	if(!nRST)
		bpif.pred <= 0;
	else if(bpif.pcen && (bpif.beq || bpif.bne))
		bpif.pred <= bpif.n_pred;
	
end

always_comb begin
	case(bpif.pred)
		2'b00: begin //strong nt
			if(bpif.flush) 
				bpif.n_pred = 2'b01; //taken
			else
				bpif.n_pred = 2'b00; //not taken
		end

		2'b01: begin //weak nt
			if(bpif.flush) 
				bpif.n_pred = 2'b10;
			else
				bpif.n_pred = 2'b00;
		end

		2'b10: begin //weak taken
			if(bpif.flush) 
				bpif.n_pred = 2'b01; 
			else 
				bpif.n_pred = 2'b11;
		end

		2'b11: begin //strong taken
			if(bpif.flush) 
				bpif.n_pred = 2'b10; //not taken
            else 
				bpif.n_pred = 2'b11; //taken
		end
		default: bpif.n_pred = 2'b00;
	endcase
end

endmodule