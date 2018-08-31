vlib work
vlog -timescale 1ns/1ns hexdisplay.v
vsim hexdisplay
log {/*}
add wave {/*}

# Displaying 123AbC

# 1 - 0001 - HEX1, HEX2 high
force {SW[0]} 0     
force {SW[1]} 0 
force {SW[2]} 0
force {SW[3]} 1
run 10 ns

# 2 - 0010 - HEX2, HEX5 low
force {SW[0]} 0     
force {SW[1]} 0 
force {SW[2]} 1
force {SW[3]} 0
run 10 ns

# 3 - 0011 - HEX4, HEX5 low
force {SW[0]} 0     
force {SW[1]} 0 
force {SW[2]} 1
force {SW[3]} 1
run 10 ns

# A - 1010 - HEX3 low
force {SW[0]} 1     
force {SW[1]} 0 
force {SW[2]} 1
force {SW[3]} 0
run 10 ns

# b - 1011 - HEX0, HEX1 low
force {SW[0]} 1     
force {SW[1]} 0 
force {SW[2]} 1
force {SW[3]} 1
run 10 ns

# C - 1100 - HEX1, HEX2, HEX6 low
force {SW[0]} 1     
force {SW[1]} 1 
force {SW[2]} 0
force {SW[3]} 0
run 10 ns












