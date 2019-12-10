#!/bin/bash -f
xv_path="/softslin/vivado_17.1/Vivado/2017.1"
ExecStep()
{
"$@"
RETVAL=$?
if [ $RETVAL -ne 0 ]
then
exit $RETVAL
fi
}
ExecStep $xv_path/bin/xsim tb_top_level_behav -key {Behavioral:sim_1:Functional:tb_top_level} -tclbatch tb_top_level.tcl -log simulate.log
