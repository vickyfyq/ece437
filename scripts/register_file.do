onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /register_file_tb/CLK
add wave -noupdate /register_file_tb/nRST
add wave -noupdate /register_file_tb/v1
add wave -noupdate /register_file_tb/v2
add wave -noupdate /register_file_tb/v3
add wave -noupdate -expand -group dut-rfif /register_file_tb/DUT/rfif/WEN
add wave -noupdate -expand -group dut-rfif -radix decimal /register_file_tb/DUT/rfif/wsel
add wave -noupdate -expand -group dut-rfif /register_file_tb/DUT/rfif/rsel1
add wave -noupdate -expand -group dut-rfif /register_file_tb/DUT/rfif/rsel2
add wave -noupdate -expand -group dut-rfif /register_file_tb/DUT/rfif/wdat
add wave -noupdate -expand -group dut-rfif /register_file_tb/DUT/rfif/rdat1
add wave -noupdate -expand -group dut-rfif /register_file_tb/DUT/rfif/rdat2
add wave -noupdate /register_file_tb/PROG/#ublk#502948#54/i
add wave -noupdate -expand /register_file_tb/DUT/registers
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {14 ns} 0}
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
WaveRestoreZoom {0 ns} {200 ns}
