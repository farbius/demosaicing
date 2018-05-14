
set project_name "demosaicing"
set PartDev      "xc7z020clg484-1"

set TclPath      [file dirname [file normalize [info script]]]
set ProjectPath  $TclPath
put $ProjectPath

create_project -force $project_name $ProjectPath -part xc7z020clg484-1

add_files -norecurse -force $ProjectPath/verilog_files/demosaicing.v $ProjectPath/verilog_files/BRAM_Memory_24x24.v $ProjectPath/verilog_files/kernel_3x3.v
update_compile_order -fileset sources_1

set_property SOURCE_SET sources_1 [get_filesets sim_1]
add_files -fileset sim_1 -norecurse -force $ProjectPath/verilog_files/frame_generator.v $ProjectPath/verilog_files/demosaicing_tb.v
update_compile_order -fileset sim_1

set_property SOURCE_SET sources_1 [get_filesets sim_1]
add_files -fileset sim_1 -norecurse $ProjectPath/BayerData.txt
update_compile_order -fileset sim_1

set_property SOURCE_SET sources_1 [get_filesets sim_1]
add_files -fileset sim_1 -norecurse $ProjectPath/parameter.vh
update_compile_order -fileset sim_1

set_property file_type SystemVerilog [get_files $ProjectPath/verilog_files/demosaicing.v]
set_property file_type SystemVerilog [get_files $ProjectPath/verilog_files/BRAM_Memory_24x24.v]
set_property file_type SystemVerilog [get_files $ProjectPath/verilog_files/kernel_3x3.v]
set_property file_type SystemVerilog [get_files $ProjectPath/verilog_files/frame_generator.v]
set_property file_type SystemVerilog [get_files $ProjectPath/verilog_files/demosaicing_tb.v]

launch_simulation
run all
