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
  logic  [CPUS-1:0] next_ccwait, next_ccinv;
  word_t [CPUS-1:0] next_ccsnoopaddr;

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

//Output logic 
always_comb begin
  ccif.iwait = 2'b11;
  ccif.iload = '0;
  ccif.dwait = 2'b11;
  ccif.dload = '0;

  ccif.ramaddr = '0;
  ccif.ramstore = '0;
  ccif.ramWEN = 0;
  ccif.ramREN = 0;

  ccif.ccwait = 2'b00;
  ccif.ccsnoopaddr = '0;
  ccif.ccinv[0] = ccif.ccwrite[1];
  ccif.ccinv[1] = ccif.ccwrite[0];
  case (state)
    IFETCH: begin
      if(iREN[0] == 1) begin
        ccif.ramaddr = ccif.iaddr[0];
        ccif.ramREN = iREN[0];
        ccif.iwait[0] = ccif.ramstate != ACCESS;
        ccif.iload[0] = ccif.ramload;
      end
      else if(iREN[1] == 1) begin
        ccif.ramaddr = ccif.iaddr[1];
        ccif.ramREN = iREN[1];
        ccif.iwait[1] = ccif.ramstate != ACCESS;
        ccif.iload[1] = ccif.ramload;
      end
    end
    WB1: begin
      if(ccif.dWEN[0])begin
        ccif.ramaddr = ccif.daddr[0];
        ccif.ramWEN = ccif.dWEN[0];
        ccif.ramstore = ccif.dstore[0];
        ccif.dhit[0] = ccif.ramstate != ACCESS;
        ccif.ccwait[1] = 1;
      end
      else if(ccif.dWEN[1]) begin
        ccif.ramaddr = ccif.daddr[1];
        ccif.ramWEN = ccif.dWEN[1];
        ccif.ramstore = ccif.dstore[1];
        ccif.dhit[1] = ccif.ramstate != ACCESS;
        ccif.ccwait[0] = 1;
      end
    end
    WB2: begin
      if(ccif.dWEN[0])begin
        ccif.ramaddr = ccif.daddr[0];
        ccif.ramWEN = ccif.dWEN[0];
        ccif.ramstore = ccif.dstore[0];
        ccif.dhit[0] = ccif.ramstate != ACCESS;
        ccif.ccwait[1] = 1;
      end
      else if(ccif.dWEN[1]) begin
        ccif.ramaddr = ccif.daddr[1];
        ccif.ramWEN = ccif.dWEN[1];
        ccif.ramstore = ccif.dstore[1];
        ccif.dhit[1] = ccif.ramstate != ACCESS;
        ccif.ccwait[0] = 1;
      end
    end

    ARBITRATE: begin
      ccif.ccwait[~next_snooper] = 1;
      ccif.ccsnoopaddr[~next_snooper] = ccif.daddr[snooper];
    end

    SNOOP: begin
      ccif.ccwait[~snooper] = 1;
      ccif.ccsnoopaddr[~snooper] = ccif.daddr[snooper];
    end

    LDRAM1: begin
      ccif.dwait[snooper] = ccif.ramstate != ACCESS;
      ccif.dload[snooper] = ccif.ramload;
      ccif.ramaddr = ccif.daddr[snooper];
      ccif.ramREN = ccif.dREN[snooper];
      ccif.ccwait[~snooper] = 1;
    end

    LDRAM2: begin
      ccif.dwait[snooper] = ccif.ramstate != ACCESS;
      ccif.dload[snooper] = ccif.ramload;
      ccif.ramaddr = ccif.daddr[snooper];
      ccif.ramREN = ccif.dREN[snooper];
      ccif.ccwait[~snooper] = 1;
    end

    LDCACHE1: begin
      ccif.dwait[snooper] = ccif.ramstate != ACCESS;
      ccif.dwait[~snooper] = ccif.ramstate != ACCESS;
      ccif.dload[snooper] = ccif.dstore[~snooper];
      ccif.ramaddr = ccif.daddr[~snooper];
      ccif.ramstore = ccif.dstore[~snooper];
      ccif.ramWEN = 1;
      ccif.ccwait[~snooper] = 1;
      ccif.ccsnoopaddr = ccif.daddr[snooper];
    end

    LDCACHE2: begin
      ccif.dwait[snooper] = ccif.ramstate != ACCESS;
      ccif.dwait[~snooper] = ccif.ramstate != ACCESS;
      ccif.dload[snooper] = ccif.dstore[~snooper];
      ccif.ramaddr = ccif.daddr[~snooper];
      ccif.ramstore = ccif.dstore[~snooper];
      ccif.ramWEN = 1;
      ccif.ccwait[~snooper] = 1;
      ccif.ccsnoopaddr = ccif.daddr[snooper];
    end
  endcase

end

endmodule
