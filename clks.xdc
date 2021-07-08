# set the clock freq
create_clock -period 3.125 -name CLOCK  [get_ports {clk}]

# turn off timing check on the big OR to keep it from hanging P&R  
set_false_path -from [get_clocks CLOCK] -to [get_pins -hierarchical -filter { NAME =~  "*outp_reg/D" }]


set_property PACKAGE_PIN A4 [get_ports clk]
set_property PACKAGE_PIN B4 [get_ports outp]

#set_property DONT_TOUCH true [get_cells *]
#set_property DONT_TOUCH true [get_nets *]
