import cpu_types_pkg::*;
`include "datapath_cache_if.vh"
`include "caches_if.vh"

module icache (
	input logic CLK, nRST,
	datapath_cache_if dcif,
	caches_if.icache cif
);

icache_frame hashTable [15:0]; //to match the addrs

logic [25:0] tag;
logic [3:0] index;

word_t imemload;
logic ihit, miss;
integer i;
typedef enum logic { HIT, MISS } state_t;
state_t state, nextstate;

//The maps
always_ff @(posedge CLK or negedge nRST) begin
	if(!nRST) begin
		for (i = 0; i < 16; i++) begin
			 hashTable[i].tag <= 0;
			 hashTable[i].data <= 0;
			 hashTable[i].valid <= 0;
		end
        state <= HIT;
	end else begin
		if(ihit) begin
			 hashTable[index].tag <= tag;
			 hashTable[index].data <= imemload;
			 hashTable[index].valid <= 1;
		end
        state <= nextstate;
	end
end

//Datapath
assign tag = dcif.imemaddr[31:6];
assign index = dcif.imemaddr[5:2];
assign ihit = ~cif.iwait;
assign imemload = cif.iload;

always_comb begin
    nextstate = state;
    casez (state) 
        HIT:
            if(!dcif.halt && dcif.imemREN && !dcif.dmemREN && !dcif.dmemWEN)
                if((tag != hashTable[index].tag) || !hashTable[index].valid) 
                    nextstate = MISS;
        MISS:
            if(ihit)
                nextstate = HIT;

    endcase
end

always_comb begin

    casez (state)
        HIT: begin
            cif.iREN = '0;
            cif.iaddr = '0;
            dcif.ihit = 0;
            dcif.imemload = '0;
            if(!dcif.halt && dcif.imemREN && !dcif.dmemREN && !dcif.dmemWEN) begin
                if((tag == hashTable[index].tag) && hashTable[index].valid) begin
                    dcif.ihit = 1;
                    dcif.imemload = hashTable[index].data;
                end
            end
        end
        MISS: begin
            cif.iREN = dcif.imemREN;
            cif.iaddr = dcif.imemaddr;
            dcif.ihit = ihit;
            dcif.imemload = imemload;
		end
    endcase
end

endmodule // icache