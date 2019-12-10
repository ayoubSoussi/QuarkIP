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
ExecStep $xv_path/bin/xsim quark_initialize_behav -key {Behavioral:sim_2:Functional:quark_initialize} -tclbatch quark_initialize.tcl -log simulate.log
