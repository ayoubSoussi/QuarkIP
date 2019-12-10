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
ExecStep $xv_path/bin/xelab -wto de716fec99bd4178bb9fd88f7dfa3000 -m64 --debug typical --relax --mt 8 -L xil_defaultlib -L secureip --snapshot quark_initialize_behav xil_defaultlib.quark_initialize -log elaborate.log
