/*
  Eric Villasenor
  evillase@gmail.com

  this block is the coherence protocol
  and artibtration for ram
*/

// interface include
`include "cache_control_if.vh"

// memory types
`include "cpu_types_pkg.vh"

module memory_control (
  input CLK, nRST,
  cache_control_if.cc ccif
);
  // type import
  import cpu_types_pkg::*;

  // number of cpus for cc
  parameter CPUS = 2;

  typedef enum logic[3:0] {
    IDLE, WB1, WB2, IFETCH, ARB, LDRAM1, LDRAM2, LDCACHE1, LDCACHE2, SNOOP
  } state_t;

  state_t state, nextstate;
  logic snooper, next_snooper;
  word_t [CPUS-1:0] next_ccsnoopaddr;
  logic  [CPUS-1:0] next_ccwait, next_ccinv;

  always_ff @ (posedge CLK, negedge nRST) begin
    if(nRST == 0) begin
      state <= IDLE;
      snooper <= 0;
    end
    else begin
      state <= nextstate;
      snooper <= next_snooper;
    end
  end

  //Next state Logic
  always_comb begin 
    nextstate = state;
    next_snooper = snooper;
    case(state) 
      IDLE: begin
        if(|ccif.dWEN)  nextstate = WB1;
        else if (|ccif.cctrans)  nextstate = ARB;
        else if (|ccif.iREN)  nextstate = IFETCH;
      end
      WB1: begin
        if(ccif.ramstate == ACCESS) nextstate = WB2;
      end
      WB2: begin
        if(ccif.ramstate == ACCESS) nextstate = IDLE;
      end
      IFETCH: begin
        if(ccif.ramstate == ACCESS) begin
          if(|ccif.cctrans)
            nextstate = ARB;
          else if(|ccif.dWEN)
            nextstate = WB1;
          else
            nextstate = IDLE;
        end
      end
      ARB: begin 
        if(|ccif.dREN) begin
          nextstate = SNOOP;
          if(ccif.dREN[0]) 
            next_snooper = 0;
          else if(ccif.dREN[1])
            next_snooper = 1;
        end
        else
          nextstate = IDLE;
      end
      SNOOP: begin
        if(ccif.cctrans[~snooper])
          nextstate = LDRAM1;
        else
          nextstate = LDCACHE1
      end
      LDRAM1: begin 
        if(ccif.ramstate == ACCESS) nextstate = LDRAM2;
      end
      LDRAM2: begin 
        if(ccif.ramstate == ACCESS) nextstate = IDLE;
      end
      LDCACHE1: begin 
        if(ccif.ramstate == ACCESS) nextstate = LDCACHE2;
      end
      LDCACHE2: begin 
        if(ccif.ramstate == ACCESS) nextstate = IDLE;
      end 
    endcase 
  end


/*
  assign ccif.iwait = ~(ccif.iREN && ~ccif.dWEN && ~ccif.dREN && (ccif.ramstate == ACCESS));
  assign ccif.dwait = ~((ccif.dWEN || ccif.dREN) && (ccif.ramstate == ACCESS));
  assign ccif.iload = ccif.iREN ? ccif.ramload : '0;
  assign ccif.dload = ccif.dREN ? ccif.ramload : '0;
  assign ccif.ramstore = ccif.dstore;
  assign ccif.ramWEN = ccif.dWEN;
  assign ccif.ramaddr = (ccif.dREN || ccif.dWEN) ? ccif.daddr : ccif.iaddr;
  assign ccif.ramREN = (ccif.dREN || ccif.iREN) & ~ccif.dWEN;
*/


endmodule
