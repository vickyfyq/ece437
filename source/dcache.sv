import cpu_types_pkg::*;
`include "datapath_cache_if.vh"
`include "caches_if.vh"
module dcache (
	input logic CLK, nRST,
	datapath_cache_if dcif,
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
dcachef_t snoopaddr;

typedef enum logic[3:0] {
	IDLE, WB1, WB2, LD1, LD2, FLUSH1, FLUSH2, DIRTY, CNT, HALT, TRANS, SHARE1, SHARE2
} state_t;
state_t state, n_state;
logic miss;
logic [7:0] hit_left, n_hit_left; //choose left or right frame
word_t cnt, n_cnt; //hit count
logic [4:0] frame_cnt, n_frame_cnt, frame_cnt_sub; //select each row frame
logic [2:0] idx;

///////////////////////////////snoop stuff
logic transition; //snoop dirty 
//assign transition = 0;
logic snoop_miss;
assign snoopaddr = cif.ccsnoopaddr;
logic sclefthit, scrighthit, n_sclefthit, n_scrighthit;//snoop cache left/right hit
dcache_frame scleft, scright;//snoop cache left/right frame
assign snoop_miss = ~(n_sclefthit || n_scrighthit);
assign cif.ccwrite = dcif.dmemWEN;

always_ff @(posedge CLK, negedge nRST) begin
    if (!nRST) begin
        left <= '0;
        right <= '0;
        state <= IDLE;
        frame_cnt <= '0; //count each row of frame from left to right
        cnt <= '0;// count hits
        hit_left <= '0;//choose left data/right data
        sclefthit <= '0;
        scrighthit <= '0;

    end
    else begin
        left <= n_left;
        right <= n_right;
        state <= n_state;
        frame_cnt <= n_frame_cnt;
        cnt <= n_cnt;
        hit_left <= n_hit_left;
        sclefthit <= n_sclefthit;
        scrighthit <= n_scrighthit;
        if(state == TRANS || state == SHARE1 || state == INV) begin
            left[daddr.idx] <= scleft;
            right[daddr.idx] <= scright;
        end
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
    idx = 0;
    frame_cnt_sub = 0;
    transition = 0;

    scright = right;
    scleft = left;
    n_sclefthit = sclefthit;
    n_scrighthit = scrighthit;
    transition = 0;
    case(state)
        TRANS: begin
            n_sclefthit = snoopaddr.tag == left[snoopaddr.idx].tag;
            n_scrighthit = snoopaddr.tag == right[snoopaddr.idx].tag;
            transition = n_sclefthit ? left[snoopaddr.idx].dirty : 
                        (n_scrighthit ? right[snoopaddr.idx].dirty:1'b0);
           

            if (cif.ccwait && transition ) begin
                cif.cctrans = 1;
                cif.ccwrite = 1;
                if(cif.ccinv && !transition && n_sclefthit) scleft = '0;
                if(cif.ccinv && !transition && n_scrighthit) scright = '0;
            end
            //not dirty
            else if (cif.ccwait && !transition) begin
                cif.cctrans = 1;
                cif.ccwrite = 0;
                if(cif.ccinv && !transition && n_sclefthit) scleft = '0;
                if(cif.ccinv && !transition && n_scrighthit) scright = '0;
            end
   
        end
        SHARE1: begin
            cif.dWEN = 1;
            if(sclefthit) begin
                scleft.dirty = 0;
                cif.daddr = {left[snoopaddr.idx],snoopaddr.tag,3'b000};
                cif.dstore = left[snoopaddr.idx].data;
            end 
            else if(scrighthit) begin
                scright.dirty = 0;
                cif.daddr = {right[snoopaddr.idx],snoopaddr.tag,3'b000};
                cif.dstore = right[snoopaddr.idx].data;
            end 
    
        end
        SHARE2: begin
            cif.dWEN = 1;
            if(sclefthit) begin
                scleft.dirty = 0;
                cif.daddr = {left[snoopaddr.idx],snoopaddr.tag,3'b100};
                cif.dstore = left[snoopaddr.idx].data;
            end 
            else if(scrighthit) begin
                scright.dirty = 0;
                cif.daddr = {right[snoopaddr.idx],snoopaddr.tag,3'b100};
                cif.dstore = right[snoopaddr.idx].data;
            end 
    
        end

        HALT : begin
            dcif.flushed = 1;
        end
        CNT : begin
			cif.dWEN = 1;
			cif.daddr = 32'h00003100;
			cif.dstore = cnt; 
		end   
        FLUSH1 : begin
            cif.cctrans = 1;
            cif.dWEN = 1;
            //cif.daddr = ((frame_cnt - 1) < 8) ? {left[frame_cnt -1].tag, frame_cnt -1, 3'b000}:{right[frame_cnt-8].tag, frame_cnt-8, 3'b000};
            //cif.dstore = ((frame_cnt - 1) > 8) ? right[frame_cnt-8].data[0] : left[frame_cnt-1].data[0];
            if(frame_cnt - 1 < 8) begin
                frame_cnt_sub = frame_cnt - 1;
                idx = frame_cnt_sub[2:0];
                cif.daddr = {left[idx].tag, idx, 3'b000};
                //cif.daddr = {left[frame_cnt -1].tag, frame_cnt -1, 3'b000};
                cif.dstore = left[idx].data[0];
            end
            else begin
                frame_cnt_sub = frame_cnt - 9;
                idx = frame_cnt_sub[2:0];
                cif.daddr = {right[idx].tag, idx, 3'b000};
                cif.dstore = right[idx].data[0];
            end
        end    
        FLUSH2 : begin
            cif.cctrans = 1;
            cif.dWEN = 1;
            //cif.daddr = ((frame_cnt - 1) < 8) ? {left[daddr.idx].tag, frame_cnt -1, 3'b100}:{right[daddr.idx].tag, frame_cnt-8, 3'b100};
            //cif.dstore = ((frame_cnt - 1) > 8) ? right[daddr.idx].data[1] : left[daddr.idx].data[1];
            if(frame_cnt - 1 < 8) begin
                frame_cnt_sub = frame_cnt - 1;
                idx = frame_cnt_sub[2:0];
                cif.daddr = {left[idx].tag, idx, 3'b100};
                cif.dstore = left[idx].data[1];
            end
            else begin
                frame_cnt_sub = frame_cnt - 9;
                idx = frame_cnt_sub[2:0];
                cif.daddr = {right[idx].tag, idx, 3'b100};
                cif.dstore = right[idx].data[1];
            end
        end  
        LD2: begin
            cif.dREN = 1;
            cif.cctrans = 1;
            cif.daddr = {daddr.tag,daddr.idx,3'b100};
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
            cif.cctrans = 1;
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
        default : begin
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
            idx = 0;
        end
    endcase
end

always_comb begin
n_state = state;
n_frame_cnt = frame_cnt;
cif.cctrans = 0;

case(state)
    TRANS: begin
        //valid and dirty M->S  go to SHARE1
        //invalid and dirty M->I go to SHARE1
        //invalid and not dirty S -> I to back to idle
        if (cif.ccwait && transition ) begin
            n_state = SHARE1;
        end
        //not dirty
        else if (cif.ccwait && !transition) begin
            n_state = IDLE;
        end
        else n_state = IDLE;

    end
    SHARE1: begin
        if (!cif.dwait) n_state = SHARE2;

    end
    SHARE2: begin
        if (!cif.dwait) n_state = IDLE;

    end

    IDLE: begin
        if(dcif.halt) n_state = DIRTY;
        else if (cif.ccwait) n_state = TRANS;
        else if (miss) begin
            if(hit_left[daddr.idx] == 0) begin
            //left frame or right frame dirty
                n_state = left[daddr.idx].dirty ? WB1 : LD1;
            
            end
            else begin
                n_state = right[daddr.idx].dirty ? WB1 : LD1;
              
            end
        end
    end
    DIRTY : begin
        if((left[frame_cnt[2:0]].dirty && frame_cnt < 8) || (right[frame_cnt[2:0]].dirty&& frame_cnt >= 8))
        //write back the dirty frame
                n_state = FLUSH1;
        n_frame_cnt = frame_cnt + 1;
        if(frame_cnt == 16) //if went through all the frames, hit cnt +1
            n_state = HALT;
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
        if (cif.ccwait) n_state = TRANS;
        cif.cctrans = ~cif.ccwait;
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