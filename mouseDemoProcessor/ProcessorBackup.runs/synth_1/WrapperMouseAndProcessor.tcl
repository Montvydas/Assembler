# 
# Synthesis run script generated by Vivado
# 

debug::add_scope template.lib 1
set_msg_config -id {HDL 9-1061} -limit 100000
set_msg_config -id {HDL 9-1654} -limit 100000
create_project -in_memory -part xc7a35tcpg236-1

set_param project.compositeFile.enableAutoGeneration 0
set_param synth.vivado.isSynthRun true
set_property webtalk.parent_dir /afs/inf.ed.ac.uk/user/s12/s1231174/Documents/Assembler/mouseDemoProcessor/ProcessorBackup.cache/wt [current_project]
set_property parent.project_path /afs/inf.ed.ac.uk/user/s12/s1231174/Documents/Assembler/mouseDemoProcessor/ProcessorBackup.xpr [current_project]
set_property default_lib xil_defaultlib [current_project]
set_property target_language Verilog [current_project]
add_files -quiet /afs/inf.ed.ac.uk/user/s12/s1231174/Documents/Assembler/mouseDemoProcessor/ProcessorBackup.runs/ila_2_synth_1/ila_2.dcp
set_property used_in_implementation false [get_files /afs/inf.ed.ac.uk/user/s12/s1231174/Documents/Assembler/mouseDemoProcessor/ProcessorBackup.runs/ila_2_synth_1/ila_2.dcp]
read_verilog -library xil_defaultlib {
  /afs/inf.ed.ac.uk/user/s12/s1231174/Documents/Assembler/mouseDemoProcessor/ProcessorBackup.srcs/sources_1/imports/imports/mouseCode/GenericCounter.v
  /afs/inf.ed.ac.uk/user/s12/s1231174/Documents/Assembler/mouseDemoProcessor/ProcessorBackup.srcs/sources_1/imports/Desktop/BasicStateMachine.v
  /afs/inf.ed.ac.uk/user/s12/s1231174/Documents/Assembler/mouseDemoProcessor/ProcessorBackup.srcs/sources_1/imports/mouseCode/MouseTransmitter.v
  /afs/inf.ed.ac.uk/user/s12/s1231174/Documents/Assembler/mouseDemoProcessor/ProcessorBackup.srcs/sources_1/imports/mouseCode/MouseReceiver.v
  /afs/inf.ed.ac.uk/user/s12/s1231174/Documents/Assembler/mouseDemoProcessor/ProcessorBackup.srcs/sources_1/imports/mouseCode/MouseMasterSM.v
  /afs/inf.ed.ac.uk/user/s12/s1231174/Documents/Assembler/mouseDemoProcessor/ProcessorBackup.srcs/sources_1/imports/Desktop/IRTransmitterSM.v
  /afs/inf.ed.ac.uk/user/s12/s1231174/Documents/Assembler/mouseDemoProcessor/ProcessorBackup.srcs/sources_1/imports/VGACode/VGA_Sig_Gen.v
  /afs/inf.ed.ac.uk/user/s12/s1231174/Documents/Assembler/mouseDemoProcessor/ProcessorBackup.srcs/sources_1/imports/VGACode/Frame_Buffer.v
  /afs/inf.ed.ac.uk/user/s12/s1231174/Documents/Assembler/mouseDemoProcessor/ProcessorBackup.srcs/sources_1/imports/imports/mouseCode/Multiplexer.v
  /afs/inf.ed.ac.uk/user/s12/s1231174/Documents/Assembler/mouseDemoProcessor/ProcessorBackup.srcs/sources_1/imports/imports/mouseCode/EasyDecode7Seg.v
  /afs/inf.ed.ac.uk/user/s12/s1231174/Documents/Assembler/mouseDemoProcessor/ProcessorBackup.srcs/sources_1/imports/imports/mouseCode/BinaryToBCD.v
  /afs/inf.ed.ac.uk/user/s12/s1231174/Documents/Assembler/mouseDemoProcessor/ProcessorBackup.srcs/sources_1/imports/new/ALU.v
  /afs/inf.ed.ac.uk/user/s12/s1231174/Documents/Assembler/mouseDemoProcessor/ProcessorBackup.srcs/sources_1/imports/mouseCode/MouseTransceiver.v
  /afs/inf.ed.ac.uk/user/s12/s1231174/Documents/Assembler/mouseDemoProcessor/ProcessorBackup.srcs/sources_1/imports/imports/mouseCode/PWM.v
  /afs/inf.ed.ac.uk/user/s12/s1231174/Documents/Assembler/mouseDemoProcessor/ProcessorBackup.srcs/sources_1/imports/Desktop/IRTransmitterWrapper.v
  /afs/inf.ed.ac.uk/user/s12/s1231174/Documents/Assembler/mouseDemoProcessor/ProcessorBackup.srcs/sources_1/imports/VGACode/DSL_VGA.v
  /afs/inf.ed.ac.uk/user/s12/s1231174/Documents/Assembler/mouseDemoProcessor/ProcessorBackup.srcs/sources_1/imports/imports/modifiedCode/DecimelSeg.v
  /afs/inf.ed.ac.uk/user/s12/s1231174/Documents/Assembler/mouseDemoProcessor/ProcessorBackup.srcs/sources_1/imports/modifiedCode/Processor.v
  /afs/inf.ed.ac.uk/user/s12/s1231174/Documents/Assembler/mouseDemoProcessor/ProcessorBackup.srcs/sources_1/imports/modifiedCode/SlideSwitches.v
  /afs/inf.ed.ac.uk/user/s12/s1231174/Documents/Assembler/mouseDemoProcessor/ProcessorBackup.srcs/sources_1/imports/modifiedCode/LED.v
  /afs/inf.ed.ac.uk/user/s12/s1231174/Documents/Assembler/mouseDemoProcessor/ProcessorBackup.srcs/sources_1/imports/new/ROM.v
  /afs/inf.ed.ac.uk/user/s12/s1231174/Documents/Assembler/mouseDemoProcessor/ProcessorBackup.srcs/sources_1/imports/new/RAM.v
  /afs/inf.ed.ac.uk/user/s12/s1231174/Documents/Assembler/mouseDemoProcessor/ProcessorBackup.srcs/sources_1/imports/new/Timer.v
  /afs/inf.ed.ac.uk/user/s12/s1231174/Documents/Assembler/mouseDemoProcessor/ProcessorBackup.srcs/sources_1/imports/modifiedCode/MouseWrapper.v
  /afs/inf.ed.ac.uk/user/s12/s1231174/Documents/Assembler/mouseDemoProcessor/ProcessorBackup.srcs/sources_1/imports/imports/modifiedCode/PWM_Wrapper.v
  /afs/inf.ed.ac.uk/user/s12/s1231174/Documents/Assembler/mouseDemoProcessor/ProcessorBackup.srcs/sources_1/imports/modifiedCode/WrapperMouseAndProcessor.v
}
read_xdc /afs/inf.ed.ac.uk/user/s12/s1231174/Documents/Assembler/mouseDemoProcessor/ProcessorBackup.srcs/constrs_1/new/ProcessorConstrains.xdc
set_property used_in_implementation false [get_files /afs/inf.ed.ac.uk/user/s12/s1231174/Documents/Assembler/mouseDemoProcessor/ProcessorBackup.srcs/constrs_1/new/ProcessorConstrains.xdc]

synth_design -top WrapperMouseAndProcessor -part xc7a35tcpg236-1
write_checkpoint -noxdef WrapperMouseAndProcessor.dcp
catch { report_utilization -file WrapperMouseAndProcessor_utilization_synth.rpt -pb WrapperMouseAndProcessor_utilization_synth.pb }
