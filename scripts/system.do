onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /system_tb/CLK
add wave -noupdate /system_tb/nRST
add wave -noupdate -expand -group {datapath } /system_tb/DUT/CPU/DP/dpif/halt
add wave -noupdate -expand -group {datapath } /system_tb/DUT/CPU/DP/dpif/ihit
add wave -noupdate -expand -group {datapath } /system_tb/DUT/CPU/DP/dpif/imemREN
add wave -noupdate -expand -group {datapath } /system_tb/DUT/CPU/DP/dpif/imemload
add wave -noupdate -expand -group {datapath } /system_tb/DUT/CPU/DP/dpif/imemaddr
add wave -noupdate -expand -group {datapath } /system_tb/DUT/CPU/DP/dpif/dhit
add wave -noupdate -expand -group {datapath } /system_tb/DUT/CPU/DP/dpif/dmemREN
add wave -noupdate -expand -group {datapath } /system_tb/DUT/CPU/DP/dpif/dmemWEN
add wave -noupdate -expand -group {datapath } /system_tb/DUT/CPU/DP/dpif/dmemload
add wave -noupdate -expand -group {datapath } /system_tb/DUT/CPU/DP/dpif/dmemstore
add wave -noupdate -expand -group {datapath } /system_tb/DUT/CPU/DP/dpif/dmemaddr
add wave -noupdate -expand -group {ctrl unit} /system_tb/DUT/CPU/DP/cuif/instruction
add wave -noupdate -expand -group {ctrl unit} /system_tb/DUT/CPU/DP/CU/opcode
add wave -noupdate -expand -group {ctrl unit} /system_tb/DUT/CPU/DP/CU/funct
add wave -noupdate -expand -group {ctrl unit} /system_tb/DUT/CPU/DP/cuif/RegWr
add wave -noupdate -expand -group {ctrl unit} /system_tb/DUT/CPU/DP/cuif/RegDst
add wave -noupdate -expand -group {ctrl unit} /system_tb/DUT/CPU/DP/cuif/zeroext
add wave -noupdate -expand -group {ctrl unit} /system_tb/DUT/CPU/DP/cuif/signext
add wave -noupdate -expand -group {ctrl unit} /system_tb/DUT/CPU/DP/cuif/lui
add wave -noupdate -expand -group {ctrl unit} /system_tb/DUT/CPU/DP/cuif/ALUSrc
add wave -noupdate -expand -group {ctrl unit} /system_tb/DUT/CPU/DP/cuif/ALUOp
add wave -noupdate -expand -group {ctrl unit} /system_tb/DUT/CPU/DP/cuif/MemWr
add wave -noupdate -expand -group {ctrl unit} /system_tb/DUT/CPU/DP/cuif/MemtoReg
add wave -noupdate -expand -group {ctrl unit} /system_tb/DUT/CPU/DP/cuif/beq
add wave -noupdate -expand -group {ctrl unit} /system_tb/DUT/CPU/DP/cuif/bne
add wave -noupdate -expand -group {ctrl unit} /system_tb/DUT/CPU/DP/cuif/jump
add wave -noupdate -expand -group {ctrl unit} /system_tb/DUT/CPU/DP/cuif/jreg
add wave -noupdate -expand -group {ctrl unit} /system_tb/DUT/CPU/DP/cuif/jal
add wave -noupdate -expand -group {ctrl unit} /system_tb/DUT/CPU/DP/cuif/Halt
add wave -noupdate -expand -group {request unit} /system_tb/DUT/CPU/DP/ruif/ihit
add wave -noupdate -expand -group {request unit} /system_tb/DUT/CPU/DP/ruif/dhit
add wave -noupdate -expand -group {request unit} /system_tb/DUT/CPU/DP/ruif/dmemREN
add wave -noupdate -expand -group {request unit} /system_tb/DUT/CPU/DP/ruif/dmemWEN
add wave -noupdate -expand -group {request unit} /system_tb/DUT/CPU/DP/ruif/MemtoReg
add wave -noupdate -expand -group {request unit} /system_tb/DUT/CPU/DP/ruif/MemWr
add wave -noupdate -expand -group {register file} /system_tb/DUT/CPU/DP/RF/registers
add wave -noupdate -expand -group {register file} /system_tb/DUT/CPU/DP/rfif/WEN
add wave -noupdate -expand -group {register file} /system_tb/DUT/CPU/DP/rfif/wsel
add wave -noupdate -expand -group {register file} /system_tb/DUT/CPU/DP/rfif/rsel1
add wave -noupdate -expand -group {register file} /system_tb/DUT/CPU/DP/rfif/rsel2
add wave -noupdate -expand -group {register file} /system_tb/DUT/CPU/DP/rfif/wdat
add wave -noupdate -expand -group {register file} /system_tb/DUT/CPU/DP/rfif/rdat1
add wave -noupdate -expand -group {register file} /system_tb/DUT/CPU/DP/rfif/rdat2
add wave -noupdate -expand -group ALU /system_tb/DUT/CPU/DP/aluif/aluop
add wave -noupdate -expand -group ALU /system_tb/DUT/CPU/DP/aluif/portA
add wave -noupdate -expand -group ALU /system_tb/DUT/CPU/DP/aluif/portB
add wave -noupdate -expand -group ALU /system_tb/DUT/CPU/DP/aluif/outport
add wave -noupdate -expand -group ALU /system_tb/DUT/CPU/DP/aluif/negative
add wave -noupdate -expand -group ALU /system_tb/DUT/CPU/DP/aluif/overflow
add wave -noupdate -expand -group ALU /system_tb/DUT/CPU/DP/aluif/zero
add wave -noupdate -expand -group {logic in pc} /system_tb/DUT/CPU/DP/CLK
add wave -noupdate -expand -group {logic in pc} /system_tb/DUT/CPU/DP/nRST
add wave -noupdate -expand -group {logic in pc} /system_tb/DUT/CPU/DP/pcen
add wave -noupdate -expand -group {logic in pc} /system_tb/DUT/CPU/DP/pc
add wave -noupdate -expand -group {logic in pc} /system_tb/DUT/CPU/DP/npc
add wave -noupdate -expand -group {logic in pc} /system_tb/DUT/CPU/DP/pc_p4
add wave -noupdate -expand -group {logic in pc} /system_tb/DUT/CPU/DP/jtype
add wave -noupdate -expand -group {logic in pc} -expand /system_tb/DUT/CPU/DP/itype
add wave -noupdate -expand -group {logic in pc} /system_tb/DUT/CPU/DP/rtype
add wave -noupdate -expand -group {logic in pc} /system_tb/DUT/CPU/DP/zeroext_imm
add wave -noupdate -expand -group {logic in pc} /system_tb/DUT/CPU/DP/lui_imm
add wave -noupdate -expand -group {logic in pc} /system_tb/DUT/CPU/DP/signext_imm
add wave -noupdate -expand -group {logic in pc} /system_tb/DUT/CPU/DP/cur_imm
add wave -noupdate -expand -group {logic in pc} /system_tb/DUT/CPU/DP/nhalt
add wave -noupdate -expand -group {logic in pc} /system_tb/DUT/CPU/DP/halt
add wave -noupdate /system_tb/DUT/CPU/ccif/iload
add wave -noupdate /system_tb/DUT/CPU/ccif/iREN
add wave -noupdate /system_tb/DUT/CPU/ccif/dREN
add wave -noupdate /system_tb/DUT/CPU/ccif/dWEN
add wave -noupdate /system_tb/DUT/CPU/ccif/ramload
add wave -noupdate /system_tb/DUT/CPU/ccif/dload
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {236694 ps} 0}
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
WaveRestoreZoom {122529 ps} {554529 ps}
