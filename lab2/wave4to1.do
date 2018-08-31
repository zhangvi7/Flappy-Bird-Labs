vlib work
vlog -timescale 1ns/1ns mux4to1.v
vsim mux4to1
log {/*}
add wave {/*}

# Output should be u (high)
force {SW[0]} 1     
force {SW[1]} 0 
force {SW[9]} 0
force {SW[8]} 0
run 10 ns

# Output should be v (high)
force {SW[0]} 0     
force {SW[1]} 1 
force {SW[9]} 1
force {SW[8]} 0
run 10 ns

# Output should be  w (low)
force {SW[2]} 0    
force {SW[3]} 1 
force {SW[9]} 0
force {SW[8]} 1
run 10 ns

# Output should be  w (high)
force {SW[2]} 1     
force {SW[3]} 1 
force {SW[9]} 0
force {SW[8]} 1
run 10 ns

# Output should be  x (high)
force {SW[2]} 1    
force {SW[3]} 1 
force {SW[9]} 1
force {SW[8]} 1
run 10 ns

# Output should be  x (low)
force {SW[2]} 1     
force {SW[3]} 0 
force {SW[9]} 1
force {SW[8]} 1
run 10 ns
