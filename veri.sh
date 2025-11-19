#!/bin/bash

# --- Check args ---
if [ "$#" -lt 1 ]; then
    echo "Usage: $0 file1.v file2.v ... [tb_file.v]"
    exit 1
fi

# --- Unique name (YYYYMMDD_HHMMSS) ---
TS=$(date +"%Y%m%d_%H%M%S")
OUT="sim_$TS.out"

# --- Compile with iverilog ---
echo "Compiling..."
iverilog -o "$OUT" "$@"
if [ $? -ne 0 ]; then
    echo "iverilog compilation failed!"
    exit 1
fi

# --- Run simulation ---
echo "Running simulation..."
vvp "$OUT"

# --- Find VCD file (if exists) ---
VCD=$(ls *.vcd 2>/dev/null | head -n 1)

if [ -n "$VCD" ]; then
    echo "Opening GTKWave: $VCD"
    gtkwave "$VCD" 
else
    echo "No VCD file found."
fi

echo "Done."
