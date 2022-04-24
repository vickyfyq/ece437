import cpu_types_pkg::*;
`include "datapath_cache_if.vh"
`include "caches_if.vh"
module dcache (
	input logic CLK, nRST,
	datapath_cache_if dcif,
	caches_if.dcache cif
);

//CC Latched signals
logic iREN, dREN, dWEN;
word_t dstore, iaddr, daddr;
logic ccwrite, cctrans;

always_ff @(posedge CLK, negedge nRST) begin
    if (!nRST) begin
        cif.dREN <= 0;
        cif.dWEN <= 0;
        cif.dstore <= 0;
        cif.daddr <= 0;
        cif.ccwrite <= 0;
        cif.cctrans <= 0;
    end
    else begin
        cif.dREN <= dREN;
        cif.dWEN <= dWEN;
        cif.dstore <= dstore;
        cif.daddr <= daddr;
        cif.ccwrite <= ccwrite;
        cif.cctrans <= cctrans;
    end
end

dcachef_t dmemaddr;
dcache_frame [7:0] left, right,n_left, n_right;
// logic valid;
// logic dirty;
// logic [DTAG_W - 1:0] tag;
// word_t [1:0] data;
assign dmemaddr = dcif.dmemaddr;
//     logic [DTAG_W-1:0]  tag;
//     logic [DIDX_W-1:0]  idx;
//     logic [DBLK_W-1:0]  blkoff;
//     logic [DBYT_W-1:0]  bytoff;
dcachef_t snoopaddr;

typedef enum logic[3:0] {
	IDLE, WB1, WB2, LD1, LD2, FLUSH1, FLUSH2, DIRTY, CNT, HALT, TRANS, SHARE1, SHARE2, INVALID
} state_t;
state_t state, n_state;
logic miss;
logic [7:0] hit_left, n_hit_left; //choose left or right frame
word_t cnt, n_cnt; //hit count
logic [4:0] frame_cnt, n_frame_cnt, frame_cnt_sub; //select each row frame
logic [2:0] idx;

///////////////////////////////LL/SC stuff
word_t link_reg, next_link_reg;
logic link_valid, next_link_valid;

///////////////////////////////snoop stuff
logic snoop_dirty; //snoop dirty 
//assign snoop_dirty = 0;
logic snoop_miss;
assign snoopaddr = cif.ccsnoopaddr;
logic sclefthit, scrighthit, n_sclefthit, n_scrighthit;//snoop cache left/right hit
dcache_frame scleft, scright;//snoop cache left/right frame
assign snoop_miss = ~(n_sclefthit || n_scrighthit);


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
        link_reg <= '0;
        link_valid <= 0;
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
        link_reg <= next_link_reg;
        link_valid <= next_link_valid;
        if(state == TRANS || state == SHARE1 || state == SHARE2) begin
            left[snoopaddr.idx] <= scleft;
            right[snoopaddr.idx] <= scright;
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
    daddr = 0;
	dstore = 0;
	dREN = 0;
	dWEN = 0;
    dcif.flushed = 0;
    n_hit_left = hit_left;
    n_cnt = cnt;
    idx = 0;
    frame_cnt_sub = 0;
    snoop_dirty = 0;
    //cif.ccwrite = 0;
    scright = right[snoopaddr.idx];
    scleft = left[snoopaddr.idx];
    n_sclefthit = sclefthit;
    n_scrighthit = scrighthit;
    snoop_dirty = 0;
    cctrans = 0;
    ccwrite = dcif.dmemWEN;
    next_link_reg = link_reg;
    next_link_valid = link_valid;
    case(state)
        TRANS: begin
            n_sclefthit = (snoopaddr.tag == left[snoopaddr.idx].tag) && left[snoopaddr.idx].valid;
            n_scrighthit = (snoopaddr.tag == right[snoopaddr.idx].tag) && right[snoopaddr.idx].valid;
            snoop_dirty = n_sclefthit ? left[snoopaddr.idx].dirty : 
                        (n_scrighthit ? right[snoopaddr.idx].dirty:1'b0);
           

            //not dirty  
            cctrans = snoop_dirty;          
            if (cif.ccinv && !snoop_dirty) begin
                if(n_sclefthit) scleft = '0;
                if(n_scrighthit) scright = '0;
                
            end
            if(snoopaddr == link_reg && cif.ccinv) begin
                next_link_reg = 0;
                next_link_valid = 0;
            end
            
   
        end
        SHARE1: begin
            dWEN = 1;
            cctrans = 1;
            if(sclefthit) begin
                scleft.dirty = 0;
                daddr = {snoopaddr.tag,snoopaddr.idx,3'b000};
                dstore = left[snoopaddr.idx].data[0];
            end 
            else if(scrighthit) begin
                scright.dirty = 0;
                daddr = {snoopaddr.tag,snoopaddr.idx,3'b000};
                dstore = right[snoopaddr.idx].data[0];
            end 
    
        end
        SHARE2: begin
            dWEN = cif.dwait && cif.ccwait;
            cctrans = 1;
            if(sclefthit && cif.ccwait) begin
                scleft.dirty = 0;
                daddr = {snoopaddr.tag,snoopaddr.idx,3'b100};
                dstore = left[snoopaddr.idx].data[1];
                if(!cif.dwait)
                    scleft = '0;
            end 
            else if(scrighthit && cif.ccwait) begin
                scright.dirty = 0;
                daddr = {snoopaddr.tag,snoopaddr.idx,3'b100};
                dstore = right[snoopaddr.idx].data[1];
                if(!cif.dwait)
                    scright = '0;
            end 
        end
        INVALID: begin  
            if(cif.ccinv) begin
                if(sclefthit) 
                    scleft = '0;
                if(scrighthit)
                    scright = '0;
            end
        end

        HALT : begin
            dcif.flushed = 1;
        end
        CNT : begin
			dWEN = 1;
			daddr = 32'h00003100;
			dstore = cnt; 
		end   
        FLUSH1 : begin
            cctrans = 1;
            dWEN = 1;
            ccwrite = 1;
            if(frame_cnt - 1 < 8) begin
                frame_cnt_sub = frame_cnt - 1;
                idx = frame_cnt_sub[2:0];
                daddr = {left[idx].tag, idx, 3'b000};
                dstore = left[idx].data[0];
            end
            else begin
                frame_cnt_sub = frame_cnt - 9;
                idx = frame_cnt_sub[2:0];
                daddr = {right[idx].tag, idx, 3'b000};
                dstore = right[idx].data[0];
            end
        end    
        FLUSH2 : begin
            cctrans = 1;
            dWEN = cif.dwait;
            ccwrite = 1;
            if(frame_cnt - 1 < 8) begin
                frame_cnt_sub = frame_cnt - 1;
                idx = frame_cnt_sub[2:0];
                daddr = {left[idx].tag, idx, 3'b100};
                dstore = left[idx].data[1];
            end
            else begin
                frame_cnt_sub = frame_cnt - 9;
                idx = frame_cnt_sub[2:0];
                daddr = {right[idx].tag, idx, 3'b100};
                dstore = right[idx].data[1];
            end
        end  
        LD2: begin
            dREN = 1;
            //ccwrite = 0;
            daddr = {dmemaddr.tag,dmemaddr.idx,3'b100};
            if (hit_left[dmemaddr.idx] && ~cif.dwait) begin
                n_right[dmemaddr.idx].data[1] = cif.dload;
                n_right[dmemaddr.idx].tag = dmemaddr.tag;
                n_right[dmemaddr.idx].dirty = 0;
                n_right[dmemaddr.idx].valid = 1;
                dREN = 0;
            end   
            else if (~cif.dwait) begin
                n_left[dmemaddr.idx].data[1] = cif.dload;
                n_left[dmemaddr.idx].tag = dmemaddr.tag;
                n_left[dmemaddr.idx].dirty = 0;
                n_left[dmemaddr.idx].valid = 1;
                dREN = 0;
            end    
        end
        LD1: begin
            //ccwrite = 0;
            dREN = 1;
            cctrans = ~cif.ccwait;
            daddr = {dmemaddr.tag,dmemaddr.idx,3'h0};
            if (hit_left[dmemaddr.idx] && ~cif.dwait)    n_right[dmemaddr.idx].data[0] = cif.dload;
            else if (~cif.dwait)    n_left[dmemaddr.idx].data[0] = cif.dload;
        end
        WB2 : begin
            dWEN = cif.dwait;
            daddr = hit_left[dmemaddr.idx] ? {right[dmemaddr.idx].tag,dmemaddr.idx,3'b100} :{left[dmemaddr.idx].tag,dmemaddr.idx,3'b100};
            dstore = hit_left[dmemaddr.idx] ? right[dmemaddr.idx].data[1] : left[dmemaddr.idx].data[1];
        end
        WB1 : begin
            dWEN = 1;
            daddr = hit_left[dmemaddr.idx] ? {right[dmemaddr.idx].tag,dmemaddr.idx,3'h0} :{left[dmemaddr.idx].tag,dmemaddr.idx,3'b000};
            dstore = hit_left[dmemaddr.idx] ? right[dmemaddr.idx].data[0] : left[dmemaddr.idx].data[0];
        end
        IDLE: begin
            daddr = dmemaddr;
            if(snoopaddr.tag == left[snoopaddr.idx].tag && cif.ccinv) begin
                n_left[snoopaddr.idx] = '0;
            end
            if(snoopaddr.tag == right[snoopaddr.idx].tag && cif.ccinv) begin
                n_right[snoopaddr.idx] = '0;
            end

            if(dcif.dmemREN && !cif.ccwait) begin //read data left frame or right frame or miss
                if(dcif.datomic) begin
                    next_link_reg = dcif.dmemaddr;
                    next_link_valid = 1;
                end

                if(dmemaddr.tag == left[dmemaddr.idx].tag && left[dmemaddr.idx].valid) begin//if left matches, hit
                    n_cnt = cnt + 1;
                    n_hit_left[dmemaddr.idx] = 1; //left hit next try right
                    dcif.dhit = 1;
                    dcif.dmemload = left[dmemaddr.idx].data[dmemaddr.blkoff]; 

                end else if (dmemaddr.tag == right[dmemaddr.idx].tag && right[dmemaddr.idx].valid) begin //if right matches, hit
                    n_cnt = cnt + 1;
                    n_hit_left[dmemaddr.idx] = 0; //right hit next try left
                    dcif.dhit = 1;
                    dcif.dmemload = right[dmemaddr.idx].data[dmemaddr.blkoff]; 
                    

                end else begin
                    miss = 1;
                    n_cnt = cnt - 1; //decrement hit count when miss
                end

            end

            else if(dcif.dmemWEN && !cif.ccwait) begin //read data left frame or right frame or miss
                if(dcif.datomic) begin
                    dcif.dmemload = (dmemaddr == link_reg) && link_valid;

                    if(dcif.dmemload) begin
                        if(dmemaddr.tag == left[dmemaddr.idx].tag) begin
                            n_left[dmemaddr.idx].dirty = 1;
                            if(~left[dmemaddr.idx].dirty && left[dmemaddr.idx].valid) begin
                                dcif.dhit = 1;
                                next_link_reg = 0;
                                next_link_valid = 0;
                                n_hit_left[dmemaddr.idx] = 1; 
                                n_left[dmemaddr.idx].data[dmemaddr.blkoff] = dcif.dmemstore;
                                if(link_valid)
                                    next_link_reg = link_reg + 1;
        
                            end else begin
                                miss = 1;
                                n_hit_left[dmemaddr.idx] = 0; 
                            end
                        end
                        else if(dmemaddr.tag == right[dmemaddr.idx].tag) begin
                            n_right[dmemaddr.idx].dirty = 1;
                            if(~right[dmemaddr.idx].dirty && right[dmemaddr.idx].valid) begin
                                dcif.dhit = 1;
                                next_link_reg = 0;
                                next_link_valid = 0;
                                n_hit_left[dmemaddr.idx] = 0; 
                                n_right[dmemaddr.idx].data[dmemaddr.blkoff] = dcif.dmemstore;
                                if(link_valid)
                                    next_link_reg = link_reg + 1;

                            end else begin
                                miss = 1;
                                n_hit_left[dmemaddr.idx] = 1; 
                            end
                        end
                        else begin 
                            miss = 1;
                            if(hit_left[dmemaddr.idx] == 0) begin
                                n_left[dmemaddr.idx].dirty = 0;
                                n_left[dmemaddr.idx].valid = 1;
                            end else begin
                                n_right[dmemaddr.idx].dirty = 0;
                                n_right[dmemaddr.idx].valid = 1;
                            end
                        end
                    end
                    else 
                        dcif.dhit = 1;
                end

                else begin
                    if(dmemaddr == link_reg) begin
                        next_link_reg = 0;
                        next_link_valid = 0;
                    end
                    if(dmemaddr.tag == left[dmemaddr.idx].tag && left[dmemaddr.idx].valid) begin//if left matches, hit
                        dcif.dhit = 1;
                        n_cnt = cnt + 1;
                        n_left[dmemaddr.idx].dirty = 1;
                        n_hit_left[dmemaddr.idx] = 1; //left hit next try right
                        n_left[dmemaddr.idx].data[dmemaddr.blkoff] = dcif.dmemstore;
                        if(link_valid)
                            next_link_reg = link_reg + 1;

                    end else if (dmemaddr.tag == right[dmemaddr.idx].tag && right[dmemaddr.idx].valid) begin //if right matches, hit
                        dcif.dhit = 1;
                        n_cnt = cnt + 1;
                        n_right[dmemaddr.idx].dirty = 1;
                        n_hit_left[dmemaddr.idx] = 0; //right hit next try left
                        n_right[dmemaddr.idx].data[dmemaddr.blkoff] = dcif.dmemstore;
                        if(link_valid)
                            next_link_reg = link_reg + 1;

                    end else begin
                        miss = 1;
                        n_cnt = cnt - 1; //decrement hit count when miss
                        if(hit_left[dmemaddr.idx] == 0) begin
                            n_left[dmemaddr.idx].dirty = 0;
                            n_left[dmemaddr.idx].valid = 1;
                        end else begin
                            n_right[dmemaddr.idx].dirty = 0;
                            n_right[dmemaddr.idx].dirty = 1;
                        end
                    end
                end
            end
/*
            if (miss && ~cif.ccwait && ~dcif.halt) begin
                if(hit_left[daddr.idx] == 0) begin
                //left frame or right frame dirty
                    cctrans = ~left[daddr.idx].dirty;
                end
                else begin
                    cctrans = ~right[daddr.idx].dirty;
                end
            end*/
        end
        default : begin
            n_left = left;
            n_right = right;
            miss = 0;
            //datapath output
            dcif.dhit = 0;
            dcif.dmemload = 0;
            //cache output	
            daddr = 0;
            dstore = 0;
            dREN = 0;
            dWEN = 0;
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


case(state)
    TRANS: begin
        //valid and dirty M->S  go to SHARE1
        //invalid and dirty M->I go to SHARE1
        //invalid and not dirty S -> I to back to idle
        if (cif.ccwait && snoop_dirty ) begin
            n_state = SHARE1;
        end
        //not dirty
        else if (cif.ccwait && !snoop_dirty) begin
            n_state = TRANS;
        end
        else n_state = IDLE;

    end
    SHARE1: begin
        if (!cif.dwait) n_state = SHARE2;
        if (!cif.ccwait) n_state = IDLE;

    end
    SHARE2: begin
        if (!cif.dwait) n_state = IDLE;
        if (!cif.ccwait) n_state = IDLE;

    end
    INVALID: begin
        n_state = IDLE;
    end

    IDLE: begin
        if(dcif.halt) n_state = DIRTY;
        else if (cif.ccwait) n_state = TRANS;
        else if (miss) begin
            if(hit_left[dmemaddr.idx] == 0) begin
            //left frame or right frame dirty
                n_state = left[dmemaddr.idx].dirty ? WB1 : LD1;
            end
            else begin
                n_state = right[dmemaddr.idx].dirty ? WB1 : LD1;
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
        if(cif.ccwait)
            n_state = TRANS;
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