// interface
`include "cpu_types_pkg.vh"
`include "register_file_if.vh"

module register_file(
input logic CLK,nRST,
register_file_if.rf rfif
);

// import types
import cpu_types_pkg::*;

//32 locations with 32 bits wide each
word_t [31:0] registers; 

always_ff@ (negedge CLK, negedge nRST) begin
  if (!nRST) registers <= '{default: '0}; //set all registers to zero 
  else if (rfif.WEN && rfif.wsel != '0)  registers[rfif.wsel] <= rfif.wdat; //write data into selected regs and reg 0 is always 0

end

always_comb begin
  rfif.rdat1 = registers[rfif.rsel1];
  rfif.rdat2 = registers[rfif.rsel2];
end 

endmodule
