onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix decimal /dcache_tb/PROG/test_num
add wave -noupdate /dcache_tb/CLK
add wave -noupdate /dcache_tb/nRST
add wave -noupdate /dcache_tb/DUT/state
add wave -noupdate -expand -group cif /dcache_tb/cif/dwait
add wave -noupdate -expand -group cif /dcache_tb/cif/dREN
add wave -noupdate -expand -group cif /dcache_tb/cif/dWEN
add wave -noupdate -expand -group cif /dcache_tb/cif/dload
add wave -noupdate -expand -group cif /dcache_tb/cif/dstore
add wave -noupdate -expand -group cif /dcache_tb/cif/daddr
add wave -noupdate -expand -group dcif /dcache_tb/dcif/halt
add wave -noupdate -expand -group dcif /dcache_tb/dcif/dhit
add wave -noupdate -expand -group dcif /dcache_tb/dcif/datomic
add wave -noupdate -expand -group dcif /dcache_tb/dcif/dmemREN
add wave -noupdate -expand -group dcif /dcache_tb/dcif/dmemWEN
add wave -noupdate -expand -group dcif /dcache_tb/dcif/dmemload
add wave -noupdate -expand -group dcif /dcache_tb/dcif/dmemstore
add wave -noupdate -expand -group dcif /dcache_tb/dcif/dmemaddr
add wave -noupdate /dcache_tb/DUT/left
add wave -noupdate /dcache_tb/DUT/right
add wave -noupdate /dcache_tb/DUT/n_left
add wave -noupdate /dcache_tb/DUT/n_right
add wave -noupdate /dcache_tb/DUT/hit_left
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {164 ns} 0}
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
WaveRestoreZoom {142 ns} {225 ns}
