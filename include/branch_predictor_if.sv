`ifndef BRANCH_PREDICTOR_IF_VH
`define BRANCH_PREDICTOR_IF_VH

`include "cpu_types_pkg.vh"
interface branch_predictor_if ();
    import cpu_types_pkg::*;
    
    logic [1:0]pred, n_pred;
    logic pred_result;
    
    logic bne,beq, flush,pcen;
endinterface branch_predictor_if
`endif