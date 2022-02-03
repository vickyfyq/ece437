`include "request_unit_if.vh"
`include "cpu_types_pkg.vh"

module request_unit(
    input logic CLK, nRST,
request_unit_if ruif
);

import cpu_types_pkg::*;

always_ff @(posedge CLK, negedge nRST) begin

if(!nRST) begin
    ruif.dmemREN <= 0;
    ruif.dmemWEN <= 0;
end else if (ruif.dhit)begin
    ruif.dmemREN <= 0;
    ruif.dmemWEN <= 0;
end else if (ruif.ihit)begin
    ruif.dmemREN <= ruif.MemtoReg;
    ruif.dmemWEN <= ruif.MemWr;
end


end
endmodule