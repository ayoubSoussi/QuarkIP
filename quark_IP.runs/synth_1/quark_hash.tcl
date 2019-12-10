# 
# Synthesis run script generated by Vivado
# 

create_project -in_memory -part xc7z020clg484-1

set_param project.singleFileAddWarning.threshold 0
set_param project.compositeFile.enableAutoGeneration 0
set_param synth.vivado.isSynthRun true
set_property webtalk.parent_dir /tp/xph3seo/xph3seo506/quark_IP/quark_IP.cache/wt [current_project]
set_property parent.project_path /tp/xph3seo/xph3seo506/quark_IP/quark_IP.xpr [current_project]
set_property default_lib xil_defaultlib [current_project]
set_property target_language VHDL [current_project]
set_property board_part em.avnet.com:zed:part0:1.3 [current_project]
set_property ip_output_repo /tp/xph3seo/xph3seo506/quark_IP/quark_IP.cache/ip [current_project]
set_property ip_cache_permissions {read write} [current_project]
read_vhdl -library xil_defaultlib {
  /tp/xph3seo/xph3seo506/quark_IP/quark_IP.srcs/sources_1/new/quark_initialize.vhd
  /tp/xph3seo/xph3seo506/quark_IP/quark_IP.srcs/sources_1/imports/new/quark_hash.vhd
}
# Mark all dcp files as not used in implementation to prevent them from being
# stitched into the results of this synthesis run. Any black boxes in the
# design are intentionally left as such for best results. Dcp files will be
# stitched into the design at a later time, either when this synthesis run is
# opened, or when it is stitched into a dependent implementation run.
foreach dcp [get_files -quiet -all -filter file_type=="Design\ Checkpoint"] {
  set_property used_in_implementation false $dcp
}

synth_design -top quark_hash -part xc7z020clg484-1


write_checkpoint -force -noxdef quark_hash.dcp

catch { report_utilization -file quark_hash_utilization_synth.rpt -pb quark_hash_utilization_synth.pb }
