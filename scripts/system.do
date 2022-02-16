onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -group {ctrl unit} /system_tb/DUT/CPU/DP/cuif/instruction
add wave -noupdate -group {ctrl unit} /system_tb/DUT/CPU/DP/CU/opcode
add wave -noupdate -group {ctrl unit} /system_tb/DUT/CPU/DP/CU/funct
add wave -noupdate -group {ctrl unit} /system_tb/DUT/CPU/DP/cuif/RegWr
add wave -noupdate -group {ctrl unit} /system_tb/DUT/CPU/DP/cuif/RegDst
add wave -noupdate -group {ctrl unit} /system_tb/DUT/CPU/DP/cuif/zeroext
add wave -noupdate -group {ctrl unit} /system_tb/DUT/CPU/DP/cuif/signext
add wave -noupdate -group {ctrl unit} /system_tb/DUT/CPU/DP/cuif/lui
add wave -noupdate -group {ctrl unit} /system_tb/DUT/CPU/DP/cuif/ALUSrc
add wave -noupdate -group {ctrl unit} /system_tb/DUT/CPU/DP/cuif/ALUOp
add wave -noupdate -group {ctrl unit} /system_tb/DUT/CPU/DP/cuif/MemWr
add wave -noupdate -group {ctrl unit} /system_tb/DUT/CPU/DP/cuif/MemtoReg
add wave -noupdate -group {ctrl unit} /system_tb/DUT/CPU/DP/cuif/beq
add wave -noupdate -group {ctrl unit} /system_tb/DUT/CPU/DP/cuif/bne
add wave -noupdate -group {ctrl unit} /system_tb/DUT/CPU/DP/cuif/jump
add wave -noupdate -group {ctrl unit} /system_tb/DUT/CPU/DP/cuif/jreg
add wave -noupdate -group {ctrl unit} /system_tb/DUT/CPU/DP/cuif/jal
add wave -noupdate -group {ctrl unit} /system_tb/DUT/CPU/DP/cuif/Halt
add wave -noupdate -group {register file} -expand /system_tb/DUT/CPU/DP/RF/registers
add wave -noupdate -group {register file} /system_tb/DUT/CPU/DP/rfif/WEN
add wave -noupdate -group {register file} /system_tb/DUT/CPU/DP/rfif/wsel
add wave -noupdate -group {register file} /system_tb/DUT/CPU/DP/rfif/rsel1
add wave -noupdate -group {register file} /system_tb/DUT/CPU/DP/rfif/rsel2
add wave -noupdate -group {register file} /system_tb/DUT/CPU/DP/rfif/rdat1
add wave -noupdate -group {register file} /system_tb/DUT/CPU/DP/rfif/rdat2
add wave -noupdate -expand -group ALU /system_tb/DUT/CPU/DP/aluif/aluop
add wave -noupdate -expand -group ALU /system_tb/DUT/CPU/DP/aluif/portA
add wave -noupdate -expand -group ALU /system_tb/DUT/CPU/DP/aluif/portB
add wave -noupdate -expand -group ALU /system_tb/DUT/CPU/DP/aluif/outport
add wave -noupdate -expand -group ALU /system_tb/DUT/CPU/DP/aluif/negative
add wave -noupdate -expand -group ALU /system_tb/DUT/CPU/DP/aluif/overflow
add wave -noupdate -expand -group ALU /system_tb/DUT/CPU/DP/aluif/zero
add wave -noupdate -group dp_cache /system_tb/DUT/CPU/DP/dcif/halt
add wave -noupdate -group dp_cache /system_tb/DUT/CPU/DP/dcif/ihit
add wave -noupdate -group dp_cache /system_tb/DUT/CPU/DP/dcif/imemREN
add wave -noupdate -group dp_cache /system_tb/DUT/CPU/DP/dcif/imemload
add wave -noupdate -group dp_cache /system_tb/DUT/CPU/DP/dcif/imemaddr
add wave -noupdate -group dp_cache /system_tb/DUT/CPU/DP/dcif/dhit
add wave -noupdate -group dp_cache /system_tb/DUT/CPU/DP/dcif/datomic
add wave -noupdate -group dp_cache /system_tb/DUT/CPU/DP/dcif/dmemREN
add wave -noupdate -group dp_cache /system_tb/DUT/CPU/DP/dcif/dmemWEN
add wave -noupdate -group dp_cache /system_tb/DUT/CPU/DP/dcif/flushed
add wave -noupdate -group dp_cache /system_tb/DUT/CPU/DP/dcif/dmemload
add wave -noupdate -group dp_cache /system_tb/DUT/CPU/DP/dcif/dmemstore
add wave -noupdate -group dp_cache /system_tb/DUT/CPU/DP/dcif/dmemaddr
add wave -noupdate -expand -group {beef issue} /system_tb/DUT/CPU/DP/aluif/outport
add wave -noupdate -expand -group {beef issue} /system_tb/DUT/CPU/DP/prif/mem.ALUout
add wave -noupdate -expand -group {beef issue} /system_tb/DUT/CPU/DP/prif/wb.ALUout
add wave -noupdate -expand -group {beef issue} /system_tb/DUT/CPU/DP/rfif/wdat
add wave -noupdate -expand -group {beef issue} {/system_tb/DUT/CPU/DP/RF/registers[10]}
add wave -noupdate -expand -group {beef issue} -expand -group npcs /system_tb/DUT/CPU/DP/prif/ex.imemload
add wave -noupdate -expand -group {beef issue} -expand -group npcs /system_tb/DUT/CPU/DP/prif/id.imemload
add wave -noupdate -expand -group {beef issue} -expand -group npcs /system_tb/DUT/CPU/DP/prif/wb.npc
add wave -noupdate -expand -group {beef issue} -expand -group npcs /system_tb/DUT/CPU/DP/prif/mem.npc
add wave -noupdate -expand -group {beef issue} -expand -group npcs /system_tb/DUT/CPU/DP/prif/ex.npc
add wave -noupdate -expand -group {beef issue} -expand -group npcs /system_tb/DUT/CPU/DP/prif/id.npc
add wave -noupdate -expand -group pipeline -expand /system_tb/DUT/CPU/DP/prif/wb
add wave -noupdate -expand -group pipeline -expand /system_tb/DUT/CPU/DP/prif/mem
add wave -noupdate -expand -group pipeline /system_tb/DUT/CPU/DP/prif/ex
add wave -noupdate -expand -group pipeline /system_tb/DUT/CPU/DP/prif/id
add wave -noupdate -expand -group pipeline -group pipeline_input /system_tb/DUT/CPU/DP/prif/in_imemload
add wave -noupdate -expand -group pipeline -group pipeline_input /system_tb/DUT/CPU/DP/prif/in_npc
add wave -noupdate -expand -group pipeline -group pipeline_input /system_tb/DUT/CPU/DP/prif/in_RegDst
add wave -noupdate -expand -group pipeline -group pipeline_input /system_tb/DUT/CPU/DP/prif/in_ALUSrc
add wave -noupdate -expand -group pipeline -group pipeline_input /system_tb/DUT/CPU/DP/prif/in_ALUop
add wave -noupdate -expand -group pipeline -group pipeline_input /system_tb/DUT/CPU/DP/prif/in_MemWr
add wave -noupdate -expand -group pipeline -group pipeline_input /system_tb/DUT/CPU/DP/prif/in_beq
add wave -noupdate -expand -group pipeline -group pipeline_input /system_tb/DUT/CPU/DP/prif/in_bne
add wave -noupdate -expand -group pipeline -group pipeline_input /system_tb/DUT/CPU/DP/prif/in_jump
add wave -noupdate -expand -group pipeline -group pipeline_input /system_tb/DUT/CPU/DP/prif/in_jreg
add wave -noupdate -expand -group pipeline -group pipeline_input /system_tb/DUT/CPU/DP/prif/in_jal
add wave -noupdate -expand -group pipeline -group pipeline_input /system_tb/DUT/CPU/DP/prif/in_RegWr
add wave -noupdate -expand -group pipeline -group pipeline_input /system_tb/DUT/CPU/DP/prif/in_MemtoReg
add wave -noupdate -expand -group pipeline -group pipeline_input /system_tb/DUT/CPU/DP/prif/in_Halt
add wave -noupdate -expand -group pipeline -group pipeline_input /system_tb/DUT/CPU/DP/prif/in_rdat1
add wave -noupdate -expand -group pipeline -group pipeline_input /system_tb/DUT/CPU/DP/prif/in_rdat2
add wave -noupdate -expand -group pipeline -group pipeline_input /system_tb/DUT/CPU/DP/prif/in_cur_imm
add wave -noupdate -expand -group pipeline -group pipeline_input /system_tb/DUT/CPU/DP/prif/in_jumpAddr
add wave -noupdate -expand -group pipeline -group pipeline_input /system_tb/DUT/CPU/DP/prif/in_branchAddr
add wave -noupdate -expand -group pipeline -group pipeline_input /system_tb/DUT/CPU/DP/prif/in_rt
add wave -noupdate -expand -group pipeline -group pipeline_input /system_tb/DUT/CPU/DP/prif/in_rd
add wave -noupdate -expand -group pipeline -group pipeline_input /system_tb/DUT/CPU/DP/prif/in_ALUout
add wave -noupdate -expand -group pipeline -group pipeline_input /system_tb/DUT/CPU/DP/prif/in_zero
add wave -noupdate -expand -group pipeline -group pipeline_input /system_tb/DUT/CPU/DP/prif/in_WrDest
add wave -noupdate -expand -group pipeline -group pipeline_input /system_tb/DUT/CPU/DP/prif/in_dmemload
add wave -noupdate -expand -group datapath /system_tb/DUT/CPU/DP/CLK
add wave -noupdate -expand -group datapath /system_tb/DUT/CPU/DP/nRST
add wave -noupdate -expand -group datapath /system_tb/DUT/CPU/DP/pc
add wave -noupdate -expand -group datapath /system_tb/DUT/CPU/DP/npc
add wave -noupdate -expand -group datapath /system_tb/DUT/CPU/DP/pc_p4
add wave -noupdate -expand -group datapath /system_tb/DUT/CPU/DP/iditype
add wave -noupdate -expand -group datapath /system_tb/DUT/CPU/DP/idrtype
add wave -noupdate -expand -group datapath /system_tb/DUT/CPU/DP/exjtype
add wave -noupdate -expand -group datapath /system_tb/DUT/CPU/DP/WrDest
add wave -noupdate -expand -group datapath /system_tb/DUT/CPU/DP/zeroext_imm
add wave -noupdate -expand -group datapath /system_tb/DUT/CPU/DP/lui_imm
add wave -noupdate -expand -group datapath /system_tb/DUT/CPU/DP/signext_imm
add wave -noupdate -expand -group datapath /system_tb/DUT/CPU/DP/cur_imm
add wave -noupdate -expand -group datapath /system_tb/DUT/CPU/DP/branchAddr
add wave -noupdate -expand -group datapath /system_tb/DUT/CPU/DP/jumpAddr
add wave -noupdate -expand -group datapath /system_tb/DUT/CPU/DP/nhalt
add wave -noupdate -expand -group datapath /system_tb/DUT/CPU/DP/halt
add wave -noupdate -expand -group fwd /system_tb/DUT/CPU/DP/fuif/ex_rs
add wave -noupdate -expand -group fwd /system_tb/DUT/CPU/DP/fuif/ex_rt
add wave -noupdate -expand -group fwd /system_tb/DUT/CPU/DP/fuif/mem_WrDest
add wave -noupdate -expand -group fwd /system_tb/DUT/CPU/DP/fuif/wb_WrDest
add wave -noupdate -expand -group fwd /system_tb/DUT/CPU/DP/fuif/mem_RegWr
add wave -noupdate -expand -group fwd /system_tb/DUT/CPU/DP/fuif/wb_RegWr
add wave -noupdate -expand -group fwd /system_tb/DUT/CPU/DP/fuif/dhit
add wave -noupdate -expand -group fwd /system_tb/DUT/CPU/DP/fuif/mem_MemtoReg
add wave -noupdate -expand -group fwd /system_tb/DUT/CPU/DP/fuif/forwardA
add wave -noupdate -expand -group fwd /system_tb/DUT/CPU/DP/fuif/forwardB
add wave -noupdate -expand -group hzd /system_tb/DUT/CPU/DP/huif/flush
add wave -noupdate -expand -group hzd /system_tb/DUT/CPU/DP/huif/mem
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {4819380 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {4659900 ps} {5017900 ps}
