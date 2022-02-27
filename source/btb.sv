`include "btb_if.vh"
`include "cpu_types_pkg.vh"


module BTB (
  input logic CLK, nRST,
  btb_if btbif
);

import cpu_types_pkg::*;

logic btbWEN;
logic [59:0] t0,t1,t2,t3,n_t0,n_t1,n_t2,n_t3;


assign btbWEN = (btbif.pcen && (btbif.beq || btbif.bne));
assign n_t0 = (btbif.ex_pc[3:2] == 2'b00) ? {btbif.ex_pc[31:4],btbif.npc_branch} : t0;
assign n_t1 = (btbif.ex_pc[3:2] == 2'b01) ? {btbif.ex_pc[31:4],btbif.npc_branch} : t1;
assign n_t2 = (btbif.ex_pc[3:2] == 2'b10) ? {btbif.ex_pc[31:4],btbif.npc_branch} : t2;
assign n_t3 = (btbif.ex_pc[3:2] == 2'b11) ? {btbif.ex_pc[31:4],btbif.npc_branch} : t3;


always_ff @(posedge CLK, negedge nRST) begin
  if (!nRST) begin
    t0 <= '0;
    t1 <= '0;
    t2 <= '0;
    t3 <= '0;
  end else if (btbWEN) begin
    t0 <= n_t0;
    t1 <= n_t1;
    t2 <= n_t2;
    t3 <= n_t3;
  end
end


always_comb begin
	btbif.branch_found = 0;
	btbif.branch_addr = '0;
	if (btbif.pc[31:4] != 0) begin
    	case(btbif.pc[3:2])
			2'b00: begin
				if (t0[59:32] == btbif.pc[31:4]) begin
				  btbif.branch_found = 1;
				  btbif.branch_addr = t0[31:0];
				end
			end
				2'b01: begin
				if (t1[59:32] == btbif.pc[31:4]) begin
				  btbif.branch_found = 1;
				  btbif.branch_addr = t1[31:0];
				end
			end
			2'b10: begin
				if (t2[59:32] == btbif.pc[31:4]) begin
				  btbif.branch_found = 1;
				  btbif.branch_addr = t2[31:0];
				end
			end
			2'b11: begin
				if (t3[59:32] == btbif.pc[31:4]) begin
				  btbif.branch_found = 1;
				  btbif.branch_addr = t3[31:0];
				end
			end
			default: begin
				btbif.branch_found = 0;
				btbif.branch_addr = '0;
			end
    	endcase
  	end
end


endmodule