import cpu_types_pkg::*;
`include "datapath_cache_if.vh"
`include "caches_if.vh"
module dcache (
	input logic CLK, nRST,
	datapath_cache_if.dcache dcif,
	caches_if.dcache cif
);

dcachef_t daddr;
dcache_frame [7:0] left, right,n_left, n_right;
// logic valid;
// logic dirty;
// logic [DTAG_W - 1:0] tag;
// word_t [1:0] data;
assign daddr = dcif.dmemaddr;
//     logic [DTAG_W-1:0]  tag;
//     logic [DIDX_W-1:0]  idx;
//     logic [DBLK_W-1:0]  blkoff;
//     logic [DBYT_W-1:0]  bytoff;

typedef enum logic[3:0] {
	IDLE, WB1, WB2, LD1, LD2, FLUSH1, FLUSH2, DIRTY, CNT, HALT
} state_t;
state_t state, n_state;
logic miss;
logic [7:0] hit_left, n_hit_left; //choose left or right frame
word_t cnt, n_cnt; //hit count
logic [4:0] frame_cnt, n_frame_cnt; //select each row frame

always_ff @(posedge CLK, negedge nRST) begin
    if (!nRST) begin
        left <= '0;
        right <= '0;
        state <= IDLE;
        frame_cnt <= '0; //count each row of frame from left to right
        cnt <= '0;// count hits
        hit_left <= '0;//choose left data/right data
    end
    else begin
        left <= n_left;
        right <= n_right;
        state <= n_state;
        frame_cnt <= n_frame_cnt;
        cnt <= n_cnt;
        hit_left <= n_hit_left;
    end
end

always_comb begin
    n_left = left;
    n_right = right;
    miss = 0;
    //datapath output
    dcif.dhit = 0;
	dcif.dmemload = 0;
    //cache output	
    cif.daddr = 0;
	cif.dstore = 0;
	cif.dREN = 0;
	cif.dWEN = 0;
    dcif.flushed = 0;
    n_hit_left = hit_left;
    n_cnt = cnt;

    case(state)
        HALT : begin
            dcif.flushed = 1;
        end
        CNT : begin
			cif.dWEN = 1;
			cif.daddr = 32'h00003100;
			cif.dstore = cnt; 
		end   
        FLUSH1 : begin
            cif.dWEN = 1;
            cif.daddr = ((frame_cnt - 1) < 8) ? {left[daddr.idx].tag, frame_cnt -1, 3'b000}:{right[daddr.idx], frame_cnt-8, 3'b000};
            cif.dstore = ((frame_cnt - 1) > 8) ? right[daddr.idx].data[0] : left[daddr.idx].data[0];
        end    
        FLUSH2 : begin
            cif.dWEN = 1;
            cif.daddr = ((frame_cnt - 1) < 8) ? {left[daddr.idx].tag, frame_cnt -1, 3'b100}:{right[daddr.idx], frame_cnt-8, 3'b100};
            cif.dstore = ((frame_cnt - 1) > 8) ? right[daddr.idx].data[1] : left[daddr.idx].data[1];
        end  
        LD2: begin
            cif.dREN = 1;
            cif.daddr = {daddr.tag,daddr.idx,3'h0};
            if (hit_left[daddr.idx]) begin
                n_right[daddr.idx].data[1] = cif.dload;
                n_right[daddr.idx].tag = daddr.tag;
                n_right[daddr.idx].dirty = 0;
                n_right[daddr.idx].valid = 1;
            end   
            else begin
                n_left[daddr.idx].data[1] = cif.dload;
                n_left[daddr.idx].tag = daddr.tag;
                n_left[daddr.idx].dirty = 0;
                n_left[daddr.idx].valid = 1;
            end   
        end
        LD1: begin
            cif.dREN = 1;
            cif.daddr = {daddr.tag,daddr.idx,3'h0};
            if (hit_left[daddr.idx])    n_right[daddr.idx].data[0] = cif.dload;
            else    n_left[daddr.idx].data[0] = cif.dload;
        end
        WB2 : begin
            cif.dWEN = 1;
            cif.daddr = hit_left[daddr.idx] ? {right[daddr.idx].tag,daddr.idx,3'b100} :{left[daddr.idx].tag,daddr.idx,3'b100};
            cif.dstore = hit_left[daddr.idx] ? right[daddr.idx].data[1] : left[daddr.idx].data[1];
        end
        WB1 : begin
            cif.dWEN = 1;
            cif.daddr = hit_left[daddr.idx] ? {right[daddr.idx].tag,daddr.idx,3'h0} :{left[daddr.idx].tag,daddr.idx,3'b000};
            cif.dstore = hit_left[daddr.idx] ? right[daddr.idx].data[0] : left[daddr.idx].data[0];
        end
        IDLE: begin
            if(dcif.dmemREN) begin //read data left frame or right frame or miss
                if(daddr.tag == left[daddr.idx].tag && left[daddr.idx].valid) begin//if left matches, hit
                    n_cnt = cnt + 1;
                    n_hit_left[daddr.idx] = 1; //left hit next try right
                    dcif.dhit = 1;
                    dcif.dmemload = left[daddr.idx].data[daddr.blkoff]; 

                end else if (daddr.tag == right[daddr.idx].tag && right[daddr.idx].valid) begin //if right matches, hit
                    n_cnt = cnt + 1;
                    n_hit_left[daddr.idx] = 0; //right hit next try left
                    dcif.dhit = 1;
                    dcif.dmemload = right[daddr.idx].data[daddr.blkoff]; 

                end else begin
                    miss = 1;
                    n_cnt = cnt - 1; //decrement hit count when miss
                end

            end

            else if(dcif.dmemWEN) begin //read data left frame or right frame or miss
                if(daddr.tag == left[daddr.idx].tag && left[daddr.idx].valid) begin//if left matches, hit
                    dcif.dhit = 1;
                    n_cnt = cnt + 1;
                    n_left[daddr.idx].dirty = 1;
                    n_hit_left[daddr.idx] = 1; //left hit next try right
                    n_left[daddr.idx].data[daddr.blkoff] = dcif.dmemstore;

                end else if (daddr.tag == right[daddr.idx].tag && right[daddr.idx].valid) begin //if right matches, hit
                    dcif.dhit = 1;
                    n_cnt = cnt + 1;
                    n_right[daddr.idx].dirty = 1;
                    n_hit_left[daddr.idx] = 0; //right hit next try left
                    n_right[daddr.idx].data[daddr.blkoff] = dcif.dmemstore;

                end else begin
                    miss = 1;
                    n_cnt = cnt - 1; //decrement hit count when miss
                end
            end
        end
    endcase
end

always_comb begin
n_state = state;
n_frame_cnt = frame_cnt;

case(state)
    IDLE: begin
        if(dcif.halt) n_state = DIRTY;
        else if (miss) begin
            if((hit_left[daddr.idx] == 0 && left[daddr.idx].dirty) || (hit_left[daddr.idx] && right[daddr.idx].dirty)) 
            //left frame or right frame dirty
                n_state = WB1;
            else 
                n_state = LD1;
        end
    end
    DIRTY : begin
        if((left[frame_cnt[2:0]].dirty && frame_cnt < 8) || (right[frame_cnt[2:0]].dirty&& frame_cnt > 8))
        //write back the dirty frame
                n_state = FLUSH1;
        n_frame_cnt = frame_cnt + 1;
        if(frame_cnt == 16) //if went through all the frames, hit cnt +1
            n_state = CNT;
    end
    CNT : begin
        if (!cif.dwait) n_state = HALT;
    end
    WB1: begin
        if (!cif.dwait) n_state = WB2;
    end
    WB2: begin
        if (!cif.dwait) n_state = LD1;
    end 
    LD1: begin
        if (!cif.dwait) n_state = LD2;
    end
    LD2: begin
        if (!cif.dwait) n_state = IDLE;
    end
    FLUSH1 : begin
        if (!cif.dwait) n_state = FLUSH2;
    end
    FLUSH2 : begin
        if (!cif.dwait) n_state = DIRTY;
    end
endcase

end
endmodule