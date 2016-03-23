# 
# Synthesis run script generated by Vivado
# 

set_param xicom.use_bs_reader 1
debug::add_scope template.lib 1
set_msg_config -id {HDL 9-1061} -limit 100000
set_msg_config -id {HDL 9-1654} -limit 100000
create_project -in_memory -part xc7a35tcpg236-1

set_param project.compositeFile.enableAutoGeneration 0
set_param synth.vivado.isSynthRun true
set_property webtalk.parent_dir /home/s1349598/DSL4/MicroProcessor/Assembler/mouseDemoProcessor/ProcessorBackup.cache/wt [current_project]
set_property parent.project_path /home/s1349598/DSL4/MicroProcessor/Assembler/mouseDemoProcessor/ProcessorBackup.xpr [current_project]
set_property default_lib xil_defaultlib [current_project]
set_property target_language Verilog [current_project]
add_files -quiet /home/s1349598/DSL4/MicroProcessor/Assembler/mouseDemoProcessor/ProcessorBackup.runs/ila_2_synth_1/ila_2.dcp
set_property used_in_implementation false [get_files /home/s1349598/DSL4/MicroProcessor/Assembler/mouseDemoProcessor/ProcessorBackup.runs/ila_2_synth_1/ila_2.dcp]
read_verilog -library xil_defaultlib {
  /home/s1349598/DSL4/MicroProcessor/Assembler/mouseDemoProcessor/ProcessorBackup.srcs/sources_1/imports/mouseCode/MouseTransmitter.v
  /home/s1349598/DSL4/MicroProcessor/Assembler/mouseDemoProcessor/ProcessorBackup.srcs/sources_1/imports/mouseCode/MouseReceiver.v
  /home/s1349598/DSL4/MicroProcessor/Assembler/mouseDemoProcessor/ProcessorBackup.srcs/sources_1/imports/mouseCode/MouseMasterSM.v
  /home/s1349598/DSL4/MicroProcessor/Assembler/mouseDemoProcessor/ProcessorBackup.srcs/sources_1/imports/imports/mouseCode/GenericCounter.v
  /home/s1349598/DSL4/MicroProcessor/Assembler/mouseDemoProcessor/ProcessorBackup.srcs/sources_1/imports/VGACode/VGA_Sig_Gen.v
  /home/s1349598/DSL4/MicroProcessor/Assembler/mouseDemoProcessor/ProcessorBackup.srcs/sources_1/imports/VGACode/Frame_Buffer.v
  /home/s1349598/DSL4/MicroProcessor/Assembler/mouseDemoProcessor/ProcessorBackup.srcs/sources_1/imports/imports/mouseCode/Multiplexer.v
  /home/s1349598/DSL4/MicroProcessor/Assembler/mouseDemoProcessor/ProcessorBackup.srcs/sources_1/imports/imports/mouseCode/EasyDecode7Seg.v
  /home/s1349598/DSL4/MicroProcessor/Assembler/mouseDemoProcessor/ProcessorBackup.srcs/sources_1/imports/imports/mouseCode/BinaryToBCD.v
  /home/s1349598/DSL4/MicroProcessor/Assembler/mouseDemoProcessor/ProcessorBackup.srcs/sources_1/imports/new/ALU.v
  /home/s1349598/DSL4/MicroProcessor/Assembler/mouseDemoProcessor/ProcessorBackup.srcs/sources_1/imports/mouseCode/MouseTransceiver.v
  /home/s1349598/DSL4/MicroProcessor/Assembler/mouseDemoProcessor/ProcessorBackup.srcs/sources_1/imports/imports/mouseCode/PWM.v
  /home/s1349598/DSL4/MicroProcessor/Assembler/mouseDemoProcessor/ProcessorBackup.srcs/sources_1/imports/VGACode/DSL_VGA.v
  /home/s1349598/DSL4/MicroProcessor/Assembler/mouseDemoProcessor/ProcessorBackup.srcs/sources_1/imports/imports/modifiedCode/DecimelSeg.v
  /home/s1349598/DSL4/MicroProcessor/Assembler/mouseDemoProcessor/ProcessorBackup.srcs/sources_1/imports/modifiedCode/Processor.v
  /home/s1349598/DSL4/MicroProcessor/Assembler/mouseDemoProcessor/ProcessorBackup.srcs/sources_1/imports/modifiedCode/SlideSwitches.v
  /home/s1349598/DSL4/MicroProcessor/Assembler/mouseDemoProcessor/ProcessorBackup.srcs/sources_1/imports/modifiedCode/LED.v
  /home/s1349598/DSL4/MicroProcessor/Assembler/mouseDemoProcessor/ProcessorBackup.srcs/sources_1/imports/new/ROM.v
  /home/s1349598/DSL4/MicroProcessor/Assembler/mouseDemoProcessor/ProcessorBackup.srcs/sources_1/imports/new/RAM.v
  /home/s1349598/DSL4/MicroProcessor/Assembler/mouseDemoProcessor/ProcessorBackup.srcs/sources_1/imports/new/Timer.v
  /home/s1349598/DSL4/MicroProcessor/Assembler/mouseDemoProcessor/ProcessorBackup.srcs/sources_1/imports/modifiedCode/MouseWrapper.v
  /home/s1349598/DSL4/MicroProcessor/Assembler/mouseDemoProcessor/ProcessorBackup.srcs/sources_1/imports/imports/modifiedCode/PWM_Wrapper.v
  /home/s1349598/DSL4/MicroProcessor/Assembler/mouseDemoProcessor/ProcessorBackup.srcs/sources_1/imports/modifiedCode/WrapperMouseAndProcessor.v
}
read_xdc /home/s1349598/DSL4/MicroProcessor/Assembler/mouseDemoProcessor/ProcessorBackup.srcs/constrs_1/new/ProcessorConstrains.xdc
set_property used_in_implementation false [get_files /home/s1349598/DSL4/MicroProcessor/Assembler/mouseDemoProcessor/ProcessorBackup.srcs/constrs_1/new/ProcessorConstrains.xdc]

synth_design -top WrapperMouseAndProcessor -part xc7a35tcpg236-1
write_checkpoint -noxdef WrapperMouseAndProcessor.dcp
catch { report_utilization -file WrapperMouseAndProcessor_utilization_synth.rpt -pb WrapperMouseAndProcessor_utilization_synth.pb }
