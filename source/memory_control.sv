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
    IDLE, WB1, WB2, IFETCH, ARB, LDRAM1, LDRAM2, RAMCACHE1, RAMCACHE2, SNOOP
  } state_t;

  logic  [CPUS-1:0] iwait, dwait, ccwait, ccinv;
  word_t [CPUS-1:0] iload, dload, ccsnoopaddr;

  always_ff @(posedge CLK, negedge nRST) begin 
    if (!nRST) begin
        ccif.iwait <= 0;
        ccif.dwait <= 0;
        ccif.iload <= 0;
        ccif.dload <= 0;
        ccif.ccwait <= 0;
        ccif.ccinv <= 0;
        ccif.ccsnoopaddr <= 0;
    end
    else begin
        ccif.iwait <= iwait;
        ccif.dwait <= dwait;
        ccif.iload <= iload;
        ccif.dload <= dload;
        ccif.ccwait <= ccwait;
        ccif.ccinv <= ccinv;
        ccif.ccsnoopaddr <= ccsnoopaddr;
    end
  end

  state_t state, nextstate;
  logic snooper, next_snooper, access, next_access;
  //logic  [CPUS-1:0] next_ccwait, next_ccinv;
  //word_t [CPUS-1:0] next_ccsnoopaddr;

  always_ff @ (posedge CLK, negedge nRST) begin
    if(nRST == 0) begin
      state <= IDLE;
      snooper <= 0;
      access <= 0;
    end
    else begin
      state <= nextstate;
      snooper <= next_snooper;
      access <= next_access;
    end
  end

  //Next state Logic
  always_comb begin 
    nextstate = state;
    next_snooper = snooper;
    next_access = access;
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
        if(ccif.ramstate == ACCESS) begin
          next_access = ~access;
          nextstate = IDLE;
        end
      end
      IFETCH: begin
        if(ccif.ramstate == ACCESS) begin
          next_access = ~access;
          if(|ccif.dWEN)
            nextstate = WB1;
          else if(|ccif.cctrans)
            nextstate = ARB;
          else
            nextstate = IDLE;
        end
      end
      ARB: begin 
        if(|ccif.dWEN)  nextstate = WB1;
        else if(|ccif.dREN) begin
          nextstate = SNOOP;
          if(ccif.dREN[0] && (~access || (~ccif.dREN[1] && ~ccif.dWEN[1]))) begin 
            next_snooper = 0;
          end
          else if(ccif.dREN[1] && (access || (~ccif.dREN[0] && ~ccif.dWEN[0]))) begin 
            next_snooper = 1;
          end
        end
        else
          nextstate = IDLE;
      end
      SNOOP: begin
        if(ccif.cctrans[~snooper])
          nextstate = RAMCACHE1;
        else
          nextstate = LDRAM1;
      end
      LDRAM1: begin 
        if(ccif.ramstate == ACCESS) begin
          if(ccif.cctrans[~snooper])
            nextstate = RAMCACHE2;
          else
            nextstate = LDRAM2;
        end
      end
      LDRAM2: begin 
        if(ccif.ramstate == ACCESS) begin
          nextstate = IDLE;
          next_access = ~access;
        end
      end
      RAMCACHE1: begin 
        if(ccif.ramstate == ACCESS) nextstate = RAMCACHE2;
      end
      RAMCACHE2: begin 
        if(ccif.ramstate == ACCESS) begin
          nextstate = IDLE;
          next_access = ~access;
        end
      end 
    endcase 
  end

//Output logic 
always_comb begin
  iwait = 2'b11;
  iload = '0;
  dwait = 2'b11;
  dload = '0;

  ccif.ramaddr = '0;
  ccif.ramstore = '0;
  ccif.ramWEN = 0;
  ccif.ramREN = 0;

  ccwait = 2'b00;
  ccsnoopaddr = '0;
  ccinv[0] = ccif.ccwrite[1];
  ccinv[1] = ccif.ccwrite[0];
  case (state)
    IFETCH: begin
      if(ccif.iREN[0] == 1 && (~access || ~ccif.iREN[1])) begin
        ccif.ramaddr = ccif.iaddr[0];
        ccif.ramREN = ccif.iREN[0];
        iwait[0] = ccif.ramstate != ACCESS;
        iload[0] = ccif.ramload;
      end
      else if(ccif.iREN[1] == 1 && (access || ~ccif.iREN[0])) begin
        ccif.ramaddr = ccif.iaddr[1];
        ccif.ramREN = ccif.iREN[1];
        iwait[1] = ccif.ramstate != ACCESS;
        iload[1] = ccif.ramload;
      end
    end
    WB1: begin
      if(ccif.dWEN[0] && (~access || ~ccif.dWEN[1]))begin
        ccif.ramaddr = ccif.daddr[0];
        ccif.ramWEN = ccif.dWEN[0];
        ccif.ramstore = ccif.dstore[0];
        dwait[0] = ccif.ramstate != ACCESS;
        ccwait[1] = 1;
      end
      else if(ccif.dWEN[1] && (access || ~ccif.dWEN[0])) begin
        ccif.ramaddr = ccif.daddr[1];
        ccif.ramWEN = ccif.dWEN[1];
        ccif.ramstore = ccif.dstore[1];
        dwait[1] = ccif.ramstate != ACCESS;
        ccwait[0] = 1;
      end
    end
    WB2: begin
      if(ccif.dWEN[0] && (~access || ~ccif.dWEN[1]))begin
        ccif.ramaddr = ccif.daddr[0];
        ccif.ramWEN = ccif.dWEN[0];
        ccif.ramstore = ccif.dstore[0];
        dwait[0] = ccif.ramstate != ACCESS;
        ccwait[1] = 1;
      end
      else if(ccif.dWEN[1] && (access || ~ccif.dWEN[0])) begin
        ccif.ramaddr = ccif.daddr[1];
        ccif.ramWEN = ccif.dWEN[1];
        ccif.ramstore = ccif.dstore[1];
        dwait[1] = ccif.ramstate != ACCESS;
        ccwait[0] = 1;
      end
    end

    ARB: begin
      ccwait[~next_snooper] = 1;
      ccsnoopaddr[~next_snooper] = ccif.daddr[snooper];
    end

    SNOOP: begin
      ccwait[~snooper] = 1;
      ccsnoopaddr[~snooper] = ccif.daddr[snooper];
    end

    LDRAM1: begin
      dwait[snooper] = ccif.ramstate != ACCESS;
      dload[snooper] = ccif.ramload;
      ccif.ramaddr = ccif.daddr[snooper];
      ccif.ramREN = ccif.dREN[snooper];
      ccwait[~snooper] = 1;
      if(ccif.cctrans[~snooper]) begin
        dwait[snooper] = ccif.ramstate != ACCESS;
        dwait[~snooper] = ccif.ramstate != ACCESS;
        dload[snooper] = ccif.dstore[~snooper];
        ccif.ramaddr = ccif.daddr[snooper];
        ccif.ramstore = ccif.dstore[~snooper];
        ccif.ramWEN = 1;
        ccwait[~snooper] = 1;
        ccsnoopaddr[~snooper] = ccif.daddr[snooper];
      end
    end

    LDRAM2: begin
      dwait[snooper] = ccif.ramstate != ACCESS;
      dload[snooper] = ccif.ramload;
      ccif.ramaddr = ccif.daddr[snooper];
      ccif.ramREN = ccif.dREN[snooper];
      ccwait[~snooper] = 1;
    end

    RAMCACHE1: begin
      dwait[snooper] = ccif.ramstate != ACCESS;
      dwait[~snooper] = ccif.ramstate != ACCESS;
      dload[snooper] = ccif.dstore[~snooper];
      ccif.ramaddr = ccif.daddr[snooper];
      ccif.ramstore = ccif.dstore[~snooper];
      ccif.ramWEN = 1;
      ccwait[~snooper] = 1;
      ccsnoopaddr[~snooper] = ccif.daddr[snooper];
    end

    RAMCACHE2: begin
      dwait[snooper] = ccif.ramstate != ACCESS;
      dwait[~snooper] = ccif.ramstate != ACCESS;
      dload[snooper] = ccif.dstore[~snooper];
      ccif.ramaddr = ccif.daddr[snooper];
      ccif.ramstore = ccif.dstore[~snooper];
      ccif.ramWEN = 1;
      ccwait[~snooper] = 1;
      ccsnoopaddr[~snooper] = ccif.daddr[snooper];
    end
  endcase

end

endmodule
