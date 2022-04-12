onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -group ccif /system_tb/DUT/CPU/ccif/iwait
add wave -noupdate -group ccif /system_tb/DUT/CPU/ccif/dwait
add wave -noupdate -group ccif /system_tb/DUT/CPU/ccif/iREN
add wave -noupdate -group ccif /system_tb/DUT/CPU/ccif/dREN
add wave -noupdate -group ccif /system_tb/DUT/CPU/ccif/dWEN
add wave -noupdate -group ccif /system_tb/DUT/CPU/ccif/iload
add wave -noupdate -group ccif /system_tb/DUT/CPU/ccif/dload
add wave -noupdate -group ccif /system_tb/DUT/CPU/ccif/dstore
add wave -noupdate -group ccif /system_tb/DUT/CPU/ccif/iaddr
add wave -noupdate -group ccif /system_tb/DUT/CPU/ccif/daddr
add wave -noupdate -group ccif /system_tb/DUT/CPU/ccif/ccwait
add wave -noupdate -group ccif /system_tb/DUT/CPU/ccif/ccinv
add wave -noupdate -group ccif /system_tb/DUT/CPU/ccif/ccwrite
add wave -noupdate -group ccif /system_tb/DUT/CPU/ccif/cctrans
add wave -noupdate -group ccif /system_tb/DUT/CPU/ccif/ccsnoopaddr
add wave -noupdate -group ccif /system_tb/DUT/CPU/ccif/ramWEN
add wave -noupdate -group ccif /system_tb/DUT/CPU/ccif/ramREN
add wave -noupdate -group ccif /system_tb/DUT/CPU/ccif/ramstate
add wave -noupdate -group ccif /system_tb/DUT/CPU/ccif/ramaddr
add wave -noupdate -group ccif /system_tb/DUT/CPU/ccif/ramstore
add wave -noupdate -group ccif /system_tb/DUT/CPU/ccif/ramload
add wave -noupdate -group dcif0 /system_tb/DUT/CPU/dcif0/halt
add wave -noupdate -group dcif0 /system_tb/DUT/CPU/dcif0/ihit
add wave -noupdate -group dcif0 /system_tb/DUT/CPU/dcif0/imemREN
add wave -noupdate -group dcif0 /system_tb/DUT/CPU/dcif0/imemload
add wave -noupdate -group dcif0 /system_tb/DUT/CPU/dcif0/imemaddr
add wave -noupdate -group dcif0 /system_tb/DUT/CPU/dcif0/dhit
add wave -noupdate -group dcif0 /system_tb/DUT/CPU/dcif0/datomic
add wave -noupdate -group dcif0 /system_tb/DUT/CPU/dcif0/dmemREN
add wave -noupdate -group dcif0 /system_tb/DUT/CPU/dcif0/dmemWEN
add wave -noupdate -group dcif0 /system_tb/DUT/CPU/dcif0/flushed
add wave -noupdate -group dcif0 /system_tb/DUT/CPU/dcif0/dmemload
add wave -noupdate -group dcif0 /system_tb/DUT/CPU/dcif0/dmemstore
add wave -noupdate -group dcif0 /system_tb/DUT/CPU/dcif0/dmemaddr
add wave -noupdate -group dcif1 /system_tb/DUT/CPU/dcif1/halt
add wave -noupdate -group dcif1 /system_tb/DUT/CPU/dcif1/ihit
add wave -noupdate -group dcif1 /system_tb/DUT/CPU/dcif1/imemREN
add wave -noupdate -group dcif1 /system_tb/DUT/CPU/dcif1/imemload
add wave -noupdate -group dcif1 /system_tb/DUT/CPU/dcif1/imemaddr
add wave -noupdate -group dcif1 /system_tb/DUT/CPU/dcif1/dhit
add wave -noupdate -group dcif1 /system_tb/DUT/CPU/dcif1/datomic
add wave -noupdate -group dcif1 /system_tb/DUT/CPU/dcif1/dmemREN
add wave -noupdate -group dcif1 /system_tb/DUT/CPU/dcif1/dmemWEN
add wave -noupdate -group dcif1 /system_tb/DUT/CPU/dcif1/flushed
add wave -noupdate -group dcif1 /system_tb/DUT/CPU/dcif1/dmemload
add wave -noupdate -group dcif1 /system_tb/DUT/CPU/dcif1/dmemstore
add wave -noupdate -group dcif1 /system_tb/DUT/CPU/dcif1/dmemaddr
add wave -noupdate -group cif0 /system_tb/DUT/CPU/cif0/iwait
add wave -noupdate -group cif0 /system_tb/DUT/CPU/cif0/dwait
add wave -noupdate -group cif0 /system_tb/DUT/CPU/cif0/iREN
add wave -noupdate -group cif0 /system_tb/DUT/CPU/cif0/dREN
add wave -noupdate -group cif0 /system_tb/DUT/CPU/cif0/dWEN
add wave -noupdate -group cif0 /system_tb/DUT/CPU/cif0/iload
add wave -noupdate -group cif0 /system_tb/DUT/CPU/cif0/dload
add wave -noupdate -group cif0 /system_tb/DUT/CPU/cif0/dstore
add wave -noupdate -group cif0 /system_tb/DUT/CPU/cif0/iaddr
add wave -noupdate -group cif0 /system_tb/DUT/CPU/cif0/daddr
add wave -noupdate -group cif0 /system_tb/DUT/CPU/cif0/ccwait
add wave -noupdate -group cif0 /system_tb/DUT/CPU/cif0/ccinv
add wave -noupdate -group cif0 /system_tb/DUT/CPU/cif0/ccwrite
add wave -noupdate -group cif0 /system_tb/DUT/CPU/cif0/cctrans
add wave -noupdate -group cif0 /system_tb/DUT/CPU/cif0/ccsnoopaddr
add wave -noupdate -group cif1 /system_tb/DUT/CPU/cif1/iwait
add wave -noupdate -group cif1 /system_tb/DUT/CPU/cif1/dwait
add wave -noupdate -group cif1 /system_tb/DUT/CPU/cif1/iREN
add wave -noupdate -group cif1 /system_tb/DUT/CPU/cif1/dREN
add wave -noupdate -group cif1 /system_tb/DUT/CPU/cif1/dWEN
add wave -noupdate -group cif1 /system_tb/DUT/CPU/cif1/iload
add wave -noupdate -group cif1 /system_tb/DUT/CPU/cif1/dload
add wave -noupdate -group cif1 /system_tb/DUT/CPU/cif1/dstore
add wave -noupdate -group cif1 /system_tb/DUT/CPU/cif1/iaddr
add wave -noupdate -group cif1 /system_tb/DUT/CPU/cif1/daddr
add wave -noupdate -group cif1 /system_tb/DUT/CPU/cif1/ccwait
add wave -noupdate -group cif1 /system_tb/DUT/CPU/cif1/ccinv
add wave -noupdate -group cif1 /system_tb/DUT/CPU/cif1/ccwrite
add wave -noupdate -group cif1 /system_tb/DUT/CPU/cif1/cctrans
add wave -noupdate -group cif1 /system_tb/DUT/CPU/cif1/ccsnoopaddr
add wave -noupdate -group dcache0 /system_tb/DUT/CPU/CM0/DCACHE/CLK
add wave -noupdate -group dcache0 /system_tb/DUT/CPU/CM0/DCACHE/nRST
add wave -noupdate -group dcache0 /system_tb/DUT/CPU/CM0/DCACHE/daddr
add wave -noupdate -group dcache0 /system_tb/DUT/CPU/CM0/DCACHE/left
add wave -noupdate -group dcache0 /system_tb/DUT/CPU/CM0/DCACHE/right
add wave -noupdate -group dcache0 /system_tb/DUT/CPU/CM0/DCACHE/n_left
add wave -noupdate -group dcache0 /system_tb/DUT/CPU/CM0/DCACHE/n_right
add wave -noupdate -group dcache0 /system_tb/DUT/CPU/CM0/DCACHE/snoopaddr
add wave -noupdate -group dcache0 /system_tb/DUT/CPU/CM0/DCACHE/state
add wave -noupdate -group dcache0 /system_tb/DUT/CPU/CM0/DCACHE/n_state
add wave -noupdate -group dcache0 /system_tb/DUT/CPU/CM0/DCACHE/miss
add wave -noupdate -group dcache0 /system_tb/DUT/CPU/CM0/DCACHE/hit_left
add wave -noupdate -group dcache0 /system_tb/DUT/CPU/CM0/DCACHE/n_hit_left
add wave -noupdate -group dcache0 /system_tb/DUT/CPU/CM0/DCACHE/cnt
add wave -noupdate -group dcache0 /system_tb/DUT/CPU/CM0/DCACHE/n_cnt
add wave -noupdate -group dcache0 /system_tb/DUT/CPU/CM0/DCACHE/frame_cnt
add wave -noupdate -group dcache0 /system_tb/DUT/CPU/CM0/DCACHE/n_frame_cnt
add wave -noupdate -group dcache0 /system_tb/DUT/CPU/CM0/DCACHE/frame_cnt_sub
add wave -noupdate -group dcache0 /system_tb/DUT/CPU/CM0/DCACHE/idx
add wave -noupdate -group dcache0 /system_tb/DUT/CPU/CM0/DCACHE/transition
add wave -noupdate -group dcache0 /system_tb/DUT/CPU/CM0/DCACHE/snoop_miss
add wave -noupdate -group dcache0 /system_tb/DUT/CPU/CM0/DCACHE/sclefthit
add wave -noupdate -group dcache0 /system_tb/DUT/CPU/CM0/DCACHE/scrighthit
add wave -noupdate -group dcache0 /system_tb/DUT/CPU/CM0/DCACHE/n_sclefthit
add wave -noupdate -group dcache0 /system_tb/DUT/CPU/CM0/DCACHE/n_scrighthit
add wave -noupdate -group dcache0 /system_tb/DUT/CPU/CM0/DCACHE/scleft
add wave -noupdate -group dcache0 /system_tb/DUT/CPU/CM0/DCACHE/scright
add wave -noupdate -group dcache1 /system_tb/DUT/CPU/CM1/DCACHE/CLK
add wave -noupdate -group dcache1 /system_tb/DUT/CPU/CM1/DCACHE/nRST
add wave -noupdate -group dcache1 /system_tb/DUT/CPU/CM1/DCACHE/daddr
add wave -noupdate -group dcache1 /system_tb/DUT/CPU/CM1/DCACHE/left
add wave -noupdate -group dcache1 /system_tb/DUT/CPU/CM1/DCACHE/right
add wave -noupdate -group dcache1 /system_tb/DUT/CPU/CM1/DCACHE/n_left
add wave -noupdate -group dcache1 /system_tb/DUT/CPU/CM1/DCACHE/n_right
add wave -noupdate -group dcache1 /system_tb/DUT/CPU/CM1/DCACHE/snoopaddr
add wave -noupdate -group dcache1 /system_tb/DUT/CPU/CM1/DCACHE/state
add wave -noupdate -group dcache1 /system_tb/DUT/CPU/CM1/DCACHE/n_state
add wave -noupdate -group dcache1 /system_tb/DUT/CPU/CM1/DCACHE/miss
add wave -noupdate -group dcache1 /system_tb/DUT/CPU/CM1/DCACHE/hit_left
add wave -noupdate -group dcache1 /system_tb/DUT/CPU/CM1/DCACHE/n_hit_left
add wave -noupdate -group dcache1 /system_tb/DUT/CPU/CM1/DCACHE/cnt
add wave -noupdate -group dcache1 /system_tb/DUT/CPU/CM1/DCACHE/n_cnt
add wave -noupdate -group dcache1 /system_tb/DUT/CPU/CM1/DCACHE/frame_cnt
add wave -noupdate -group dcache1 /system_tb/DUT/CPU/CM1/DCACHE/n_frame_cnt
add wave -noupdate -group dcache1 /system_tb/DUT/CPU/CM1/DCACHE/frame_cnt_sub
add wave -noupdate -group dcache1 /system_tb/DUT/CPU/CM1/DCACHE/idx
add wave -noupdate -group dcache1 /system_tb/DUT/CPU/CM1/DCACHE/transition
add wave -noupdate -group dcache1 /system_tb/DUT/CPU/CM1/DCACHE/snoop_miss
add wave -noupdate -group dcache1 /system_tb/DUT/CPU/CM1/DCACHE/sclefthit
add wave -noupdate -group dcache1 /system_tb/DUT/CPU/CM1/DCACHE/scrighthit
add wave -noupdate -group dcache1 /system_tb/DUT/CPU/CM1/DCACHE/n_sclefthit
add wave -noupdate -group dcache1 /system_tb/DUT/CPU/CM1/DCACHE/n_scrighthit
add wave -noupdate -group dcache1 /system_tb/DUT/CPU/CM1/DCACHE/scleft
add wave -noupdate -group dcache1 /system_tb/DUT/CPU/CM1/DCACHE/scright
add wave -noupdate -expand -group icache0 /system_tb/DUT/CPU/CM0/ICACHE/CLK
add wave -noupdate -expand -group icache0 /system_tb/DUT/CPU/CM0/ICACHE/nRST
add wave -noupdate -expand -group icache0 /system_tb/DUT/CPU/CM0/ICACHE/hashTable
add wave -noupdate -expand -group icache0 /system_tb/DUT/CPU/CM0/ICACHE/tag
add wave -noupdate -expand -group icache0 /system_tb/DUT/CPU/CM0/ICACHE/index
add wave -noupdate -expand -group icache0 /system_tb/DUT/CPU/CM0/ICACHE/imemload
add wave -noupdate -expand -group icache0 /system_tb/DUT/CPU/CM0/ICACHE/ihit
add wave -noupdate -expand -group icache0 /system_tb/DUT/CPU/CM0/ICACHE/i
add wave -noupdate -expand -group icache0 /system_tb/DUT/CPU/CM0/ICACHE/state
add wave -noupdate -expand -group icache0 /system_tb/DUT/CPU/CM0/ICACHE/nextstate
add wave -noupdate -expand -group icache1 /system_tb/DUT/CPU/CM1/ICACHE/CLK
add wave -noupdate -expand -group icache1 /system_tb/DUT/CPU/CM1/ICACHE/nRST
add wave -noupdate -expand -group icache1 /system_tb/DUT/CPU/CM1/ICACHE/hashTable
add wave -noupdate -expand -group icache1 /system_tb/DUT/CPU/CM1/ICACHE/tag
add wave -noupdate -expand -group icache1 /system_tb/DUT/CPU/CM1/ICACHE/index
add wave -noupdate -expand -group icache1 /system_tb/DUT/CPU/CM1/ICACHE/imemload
add wave -noupdate -expand -group icache1 /system_tb/DUT/CPU/CM1/ICACHE/ihit
add wave -noupdate -expand -group icache1 /system_tb/DUT/CPU/CM1/ICACHE/i
add wave -noupdate -expand -group icache1 /system_tb/DUT/CPU/CM1/ICACHE/state
add wave -noupdate -expand -group icache1 /system_tb/DUT/CPU/CM1/ICACHE/nextstate
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1145600 ps} 0}
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
WaveRestoreZoom {0 ps} {358 ns}
