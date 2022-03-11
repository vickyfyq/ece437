onerror {resume}
quietly virtual function -install /icache_tb/PROG/cif -env /icache_tb/PROG/cif { &{/icache_tb/PROG/cif/iwait, /icache_tb/PROG/cif/dwait, /icache_tb/PROG/cif/iREN, /icache_tb/PROG/cif/dREN, /icache_tb/PROG/cif/dWEN, /icache_tb/PROG/cif/iload, /icache_tb/PROG/cif/dload, /icache_tb/PROG/cif/dstore, /icache_tb/PROG/cif/iaddr, /icache_tb/PROG/cif/daddr, /icache_tb/PROG/cif/ccwait, /icache_tb/PROG/cif/ccinv, /icache_tb/PROG/cif/ccwrite, /icache_tb/PROG/cif/cctrans, /icache_tb/PROG/cif/ccsnoopaddr }} cif
quietly WaveActivateNextPane {} 0
add wave -noupdate /icache_tb/CLK
add wave -noupdate /icache_tb/nRST
add wave -noupdate -expand -group dcif /icache_tb/PROG/dcif/ihit
add wave -noupdate -expand -group dcif /icache_tb/PROG/dcif/imemREN
add wave -noupdate -expand -group dcif /icache_tb/PROG/dcif/imemload
add wave -noupdate -expand -group dcif -radix hexadecimal /icache_tb/PROG/dcif/imemaddr
add wave -noupdate -expand -group cif /icache_tb/PROG/cif/iwait
add wave -noupdate -expand -group cif /icache_tb/PROG/cif/iREN
add wave -noupdate -expand -group cif /icache_tb/PROG/cif/iload
add wave -noupdate -expand -group cif /icache_tb/PROG/cif/iaddr
add wave -noupdate /icache_tb/DUT/state
add wave -noupdate /icache_tb/DUT/nextstate
add wave -noupdate -expand /icache_tb/DUT/hashTable
add wave -noupdate /icache_tb/DUT/CLK
add wave -noupdate /icache_tb/DUT/nRST
add wave -noupdate /icache_tb/DUT/tag
add wave -noupdate /icache_tb/DUT/index
add wave -noupdate /icache_tb/DUT/imemload
add wave -noupdate /icache_tb/DUT/ihit
add wave -noupdate /icache_tb/DUT/i
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {104 ns} 0}
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
WaveRestoreZoom {0 ns} {137 ns}
