create_clock -period 500.000 -name clk -waveform {0.000 250.000} [get_ports clk]
set_input_delay -clock clk -max 100.000 [get_ports ENCR_AXIS_TREADY]

