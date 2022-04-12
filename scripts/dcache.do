onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix decimal /dcache_tb/PROG/test_num
add wave -noupdate /dcache_tb/CLK
add wave -noupdate /dcache_tb/nRST
add wave -noupdate /dcache_tb/DUT/state
add wave -noupdate -expand -group cif /dcache_tb/DUT/cif/dwait
add wave -noupdate -expand -group cif /dcache_tb/DUT/cif/dREN
add wave -noupdate -expand -group cif /dcache_tb/DUT/cif/dWEN
add wave -noupdate -expand -group cif /dcache_tb/DUT/cif/dload
add wave -noupdate -expand -group cif /dcache_tb/DUT/cif/dstore
add wave -noupdate -expand -group cif /dcache_tb/DUT/cif/daddr
add wave -noupdate -expand -group cif /dcache_tb/DUT/cif/ccwait
add wave -noupdate -expand -group cif /dcache_tb/DUT/cif/ccinv
add wave -noupdate -expand -group cif /dcache_tb/DUT/cif/ccwrite
add wave -noupdate -expand -group cif /dcache_tb/DUT/cif/cctrans
add wave -noupdate -expand -group cif /dcache_tb/DUT/cif/ccsnoopaddr
add wave -noupdate -expand -group dcif /dcache_tb/dcif/halt
add wave -noupdate -expand -group dcif /dcache_tb/dcif/dhit
add wave -noupdate -expand -group dcif /dcache_tb/dcif/datomic
add wave -noupdate -expand -group dcif /dcache_tb/dcif/dmemREN
add wave -noupdate -expand -group dcif /dcache_tb/dcif/dmemWEN
add wave -noupdate -expand -group dcif /dcache_tb/dcif/dmemload
add wave -noupdate -expand -group dcif /dcache_tb/dcif/dmemstore
add wave -noupdate -expand -group dcif /dcache_tb/dcif/dmemaddr
add wave -noupdate -expand /dcache_tb/DUT/left
add wave -noupdate /dcache_tb/DUT/right
add wave -noupdate /dcache_tb/DUT/n_left
add wave -noupdate /dcache_tb/DUT/n_right
add wave -noupdate /dcache_tb/DUT/daddr
add wave -noupdate /dcache_tb/PROG/i
add wave -noupdate /dcache_tb/DUT/miss
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {342 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 217
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
WaveRestoreZoom {6169 ns} {6239 ns}
