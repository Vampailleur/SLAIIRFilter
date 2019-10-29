vlib work

# 2) Compile the half adder
vcom -2008 -explicit -work work %DUT_NAME%.vhd
vcom -2008 -explicit -work work %TB_NAME%.vhd
# 3) Load it for simulation
vsim %TB_NAME%

add wave /%TB_NAME%/*
add wave /%TB_NAME%/DUT/*

run -all;
