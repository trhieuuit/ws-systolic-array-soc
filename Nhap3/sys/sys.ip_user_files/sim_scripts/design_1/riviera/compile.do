transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

vlib work
vlib riviera/xilinx_vip
vlib riviera/xpm
vlib riviera/axi_infrastructure_v1_1_0
vlib riviera/axi_vip_v1_1_21
vlib riviera/zynq_ultra_ps_e_vip_v1_0_21
vlib riviera/xil_defaultlib
vlib riviera/axi_datamover_v5_1_37
vlib riviera/axi_sg_v4_1_21
vlib riviera/axi_dma_v7_1_36
vlib riviera/xlconstant_v1_1_10
vlib riviera/proc_sys_reset_v5_0_17
vlib riviera/smartconnect_v1_0
vlib riviera/axi_register_slice_v2_1_35
vlib riviera/xlconcat_v2_1_7

vmap xilinx_vip riviera/xilinx_vip
vmap xpm riviera/xpm
vmap axi_infrastructure_v1_1_0 riviera/axi_infrastructure_v1_1_0
vmap axi_vip_v1_1_21 riviera/axi_vip_v1_1_21
vmap zynq_ultra_ps_e_vip_v1_0_21 riviera/zynq_ultra_ps_e_vip_v1_0_21
vmap xil_defaultlib riviera/xil_defaultlib
vmap axi_datamover_v5_1_37 riviera/axi_datamover_v5_1_37
vmap axi_sg_v4_1_21 riviera/axi_sg_v4_1_21
vmap axi_dma_v7_1_36 riviera/axi_dma_v7_1_36
vmap xlconstant_v1_1_10 riviera/xlconstant_v1_1_10
vmap proc_sys_reset_v5_0_17 riviera/proc_sys_reset_v5_0_17
vmap smartconnect_v1_0 riviera/smartconnect_v1_0
vmap axi_register_slice_v2_1_35 riviera/axi_register_slice_v2_1_35
vmap xlconcat_v2_1_7 riviera/xlconcat_v2_1_7

vlog -work xilinx_vip  -incr "+incdir+C:/Xilinx/2025.1/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xpm -l axi_infrastructure_v1_1_0 -l axi_vip_v1_1_21 -l zynq_ultra_ps_e_vip_v1_0_21 -l xil_defaultlib -l axi_datamover_v5_1_37 -l axi_sg_v4_1_21 -l axi_dma_v7_1_36 -l xlconstant_v1_1_10 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_register_slice_v2_1_35 -l xlconcat_v2_1_7 \
"C:/Xilinx/2025.1/Vivado/data/xilinx_vip/hdl/axi4stream_vip_axi4streampc.sv" \
"C:/Xilinx/2025.1/Vivado/data/xilinx_vip/hdl/axi_vip_axi4pc.sv" \
"C:/Xilinx/2025.1/Vivado/data/xilinx_vip/hdl/xil_common_vip_pkg.sv" \
"C:/Xilinx/2025.1/Vivado/data/xilinx_vip/hdl/axi4stream_vip_pkg.sv" \
"C:/Xilinx/2025.1/Vivado/data/xilinx_vip/hdl/axi_vip_pkg.sv" \
"C:/Xilinx/2025.1/Vivado/data/xilinx_vip/hdl/axi4stream_vip_if.sv" \
"C:/Xilinx/2025.1/Vivado/data/xilinx_vip/hdl/axi_vip_if.sv" \
"C:/Xilinx/2025.1/Vivado/data/xilinx_vip/hdl/clk_vip_if.sv" \
"C:/Xilinx/2025.1/Vivado/data/xilinx_vip/hdl/rst_vip_if.sv" \

vlog -work xpm  -incr "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/7711/hdl" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/f0b6/hdl/verilog" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/a8e4/hdl/verilog" "+incdir+C:/Xilinx/2025.1/Vivado/data/rsb/busdef" "+incdir+C:/Xilinx/2025.1/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xpm -l axi_infrastructure_v1_1_0 -l axi_vip_v1_1_21 -l zynq_ultra_ps_e_vip_v1_0_21 -l xil_defaultlib -l axi_datamover_v5_1_37 -l axi_sg_v4_1_21 -l axi_dma_v7_1_36 -l xlconstant_v1_1_10 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_register_slice_v2_1_35 -l xlconcat_v2_1_7 \
"C:/Xilinx/2025.1/Vivado/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"C:/Xilinx/2025.1/Vivado/data/ip/xpm/xpm_fifo/hdl/xpm_fifo.sv" \
"C:/Xilinx/2025.1/Vivado/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -93  -incr \
"C:/Xilinx/2025.1/Vivado/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work axi_infrastructure_v1_1_0  -incr -v2k5 "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/7711/hdl" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/f0b6/hdl/verilog" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/a8e4/hdl/verilog" "+incdir+C:/Xilinx/2025.1/Vivado/data/rsb/busdef" "+incdir+C:/Xilinx/2025.1/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xpm -l axi_infrastructure_v1_1_0 -l axi_vip_v1_1_21 -l zynq_ultra_ps_e_vip_v1_0_21 -l xil_defaultlib -l axi_datamover_v5_1_37 -l axi_sg_v4_1_21 -l axi_dma_v7_1_36 -l xlconstant_v1_1_10 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_register_slice_v2_1_35 -l xlconcat_v2_1_7 \
"../../../../sys.gen/sources_1/bd/design_1/ipshared/ec67/hdl/axi_infrastructure_v1_1_vl_rfs.v" \

vlog -work axi_vip_v1_1_21  -incr "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/7711/hdl" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/f0b6/hdl/verilog" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/a8e4/hdl/verilog" "+incdir+C:/Xilinx/2025.1/Vivado/data/rsb/busdef" "+incdir+C:/Xilinx/2025.1/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xpm -l axi_infrastructure_v1_1_0 -l axi_vip_v1_1_21 -l zynq_ultra_ps_e_vip_v1_0_21 -l xil_defaultlib -l axi_datamover_v5_1_37 -l axi_sg_v4_1_21 -l axi_dma_v7_1_36 -l xlconstant_v1_1_10 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_register_slice_v2_1_35 -l xlconcat_v2_1_7 \
"../../../../sys.gen/sources_1/bd/design_1/ipshared/f16f/hdl/axi_vip_v1_1_vl_rfs.sv" \

vlog -work zynq_ultra_ps_e_vip_v1_0_21  -incr "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/7711/hdl" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/f0b6/hdl/verilog" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/a8e4/hdl/verilog" "+incdir+C:/Xilinx/2025.1/Vivado/data/rsb/busdef" "+incdir+C:/Xilinx/2025.1/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xpm -l axi_infrastructure_v1_1_0 -l axi_vip_v1_1_21 -l zynq_ultra_ps_e_vip_v1_0_21 -l xil_defaultlib -l axi_datamover_v5_1_37 -l axi_sg_v4_1_21 -l axi_dma_v7_1_36 -l xlconstant_v1_1_10 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_register_slice_v2_1_35 -l xlconcat_v2_1_7 \
"../../../../sys.gen/sources_1/bd/design_1/ipshared/7711/hdl/zynq_ultra_ps_e_vip_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib  -incr -v2k5 "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/7711/hdl" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/f0b6/hdl/verilog" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/a8e4/hdl/verilog" "+incdir+C:/Xilinx/2025.1/Vivado/data/rsb/busdef" "+incdir+C:/Xilinx/2025.1/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xpm -l axi_infrastructure_v1_1_0 -l axi_vip_v1_1_21 -l zynq_ultra_ps_e_vip_v1_0_21 -l xil_defaultlib -l axi_datamover_v5_1_37 -l axi_sg_v4_1_21 -l axi_dma_v7_1_36 -l xlconstant_v1_1_10 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_register_slice_v2_1_35 -l xlconcat_v2_1_7 \
"../../../bd/design_1/ip/design_1_zynq_ultra_ps_e_0_0/sim/design_1_zynq_ultra_ps_e_0_0_vip_wrapper.v" \

vcom -work axi_datamover_v5_1_37 -93  -incr \
"../../../../sys.gen/sources_1/bd/design_1/ipshared/d44a/hdl/axi_datamover_v5_1_vh_rfs.vhd" \

vcom -work axi_sg_v4_1_21 -93  -incr \
"../../../../sys.gen/sources_1/bd/design_1/ipshared/b193/hdl/axi_sg_v4_1_rfs.vhd" \

vcom -work axi_dma_v7_1_36 -93  -incr \
"../../../../sys.gen/sources_1/bd/design_1/ipshared/cb19/hdl/axi_dma_v7_1_vh_rfs.vhd" \

vcom -work xil_defaultlib -93  -incr \
"../../../bd/design_1/ip/design_1_axi_dma_0_0/sim/design_1_axi_dma_0_0.vhd" \

vlog -work xlconstant_v1_1_10  -incr -v2k5 "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/7711/hdl" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/f0b6/hdl/verilog" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/a8e4/hdl/verilog" "+incdir+C:/Xilinx/2025.1/Vivado/data/rsb/busdef" "+incdir+C:/Xilinx/2025.1/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xpm -l axi_infrastructure_v1_1_0 -l axi_vip_v1_1_21 -l zynq_ultra_ps_e_vip_v1_0_21 -l xil_defaultlib -l axi_datamover_v5_1_37 -l axi_sg_v4_1_21 -l axi_dma_v7_1_36 -l xlconstant_v1_1_10 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_register_slice_v2_1_35 -l xlconcat_v2_1_7 \
"../../../../sys.gen/sources_1/bd/design_1/ipshared/a165/hdl/xlconstant_v1_1_vl_rfs.v" \

vlog -work xil_defaultlib  -incr -v2k5 "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/7711/hdl" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/f0b6/hdl/verilog" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/a8e4/hdl/verilog" "+incdir+C:/Xilinx/2025.1/Vivado/data/rsb/busdef" "+incdir+C:/Xilinx/2025.1/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xpm -l axi_infrastructure_v1_1_0 -l axi_vip_v1_1_21 -l zynq_ultra_ps_e_vip_v1_0_21 -l xil_defaultlib -l axi_datamover_v5_1_37 -l axi_sg_v4_1_21 -l axi_dma_v7_1_36 -l xlconstant_v1_1_10 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_register_slice_v2_1_35 -l xlconcat_v2_1_7 \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_0/sim/bd_afc3_one_0.v" \

vcom -work proc_sys_reset_v5_0_17 -93  -incr \
"../../../../sys.gen/sources_1/bd/design_1/ipshared/9438/hdl/proc_sys_reset_v5_0_vh_rfs.vhd" \

vcom -work xil_defaultlib -93  -incr \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_1/sim/bd_afc3_psr_aclk_0.vhd" \

vlog -work smartconnect_v1_0  -incr "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/7711/hdl" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/f0b6/hdl/verilog" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/a8e4/hdl/verilog" "+incdir+C:/Xilinx/2025.1/Vivado/data/rsb/busdef" "+incdir+C:/Xilinx/2025.1/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xpm -l axi_infrastructure_v1_1_0 -l axi_vip_v1_1_21 -l zynq_ultra_ps_e_vip_v1_0_21 -l xil_defaultlib -l axi_datamover_v5_1_37 -l axi_sg_v4_1_21 -l axi_dma_v7_1_36 -l xlconstant_v1_1_10 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_register_slice_v2_1_35 -l xlconcat_v2_1_7 \
"../../../../sys.gen/sources_1/bd/design_1/ipshared/f0b6/hdl/sc_util_v1_0_vl_rfs.sv" \
"../../../../sys.gen/sources_1/bd/design_1/ipshared/3718/hdl/sc_switchboard_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib  -incr "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/7711/hdl" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/f0b6/hdl/verilog" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/a8e4/hdl/verilog" "+incdir+C:/Xilinx/2025.1/Vivado/data/rsb/busdef" "+incdir+C:/Xilinx/2025.1/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xpm -l axi_infrastructure_v1_1_0 -l axi_vip_v1_1_21 -l zynq_ultra_ps_e_vip_v1_0_21 -l xil_defaultlib -l axi_datamover_v5_1_37 -l axi_sg_v4_1_21 -l axi_dma_v7_1_36 -l xlconstant_v1_1_10 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_register_slice_v2_1_35 -l xlconcat_v2_1_7 \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_2/sim/bd_afc3_arinsw_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_3/sim/bd_afc3_rinsw_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_4/sim/bd_afc3_awinsw_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_5/sim/bd_afc3_winsw_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_6/sim/bd_afc3_binsw_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_7/sim/bd_afc3_aroutsw_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_8/sim/bd_afc3_routsw_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_9/sim/bd_afc3_awoutsw_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_10/sim/bd_afc3_woutsw_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_11/sim/bd_afc3_boutsw_0.sv" \

vlog -work smartconnect_v1_0  -incr "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/7711/hdl" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/f0b6/hdl/verilog" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/a8e4/hdl/verilog" "+incdir+C:/Xilinx/2025.1/Vivado/data/rsb/busdef" "+incdir+C:/Xilinx/2025.1/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xpm -l axi_infrastructure_v1_1_0 -l axi_vip_v1_1_21 -l zynq_ultra_ps_e_vip_v1_0_21 -l xil_defaultlib -l axi_datamover_v5_1_37 -l axi_sg_v4_1_21 -l axi_dma_v7_1_36 -l xlconstant_v1_1_10 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_register_slice_v2_1_35 -l xlconcat_v2_1_7 \
"../../../../sys.gen/sources_1/bd/design_1/ipshared/a8e4/hdl/sc_node_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib  -incr "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/7711/hdl" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/f0b6/hdl/verilog" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/a8e4/hdl/verilog" "+incdir+C:/Xilinx/2025.1/Vivado/data/rsb/busdef" "+incdir+C:/Xilinx/2025.1/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xpm -l axi_infrastructure_v1_1_0 -l axi_vip_v1_1_21 -l zynq_ultra_ps_e_vip_v1_0_21 -l xil_defaultlib -l axi_datamover_v5_1_37 -l axi_sg_v4_1_21 -l axi_dma_v7_1_36 -l xlconstant_v1_1_10 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_register_slice_v2_1_35 -l xlconcat_v2_1_7 \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_12/sim/bd_afc3_arni_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_13/sim/bd_afc3_rni_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_14/sim/bd_afc3_awni_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_15/sim/bd_afc3_wni_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_16/sim/bd_afc3_bni_0.sv" \

vlog -work smartconnect_v1_0  -incr "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/7711/hdl" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/f0b6/hdl/verilog" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/a8e4/hdl/verilog" "+incdir+C:/Xilinx/2025.1/Vivado/data/rsb/busdef" "+incdir+C:/Xilinx/2025.1/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xpm -l axi_infrastructure_v1_1_0 -l axi_vip_v1_1_21 -l zynq_ultra_ps_e_vip_v1_0_21 -l xil_defaultlib -l axi_datamover_v5_1_37 -l axi_sg_v4_1_21 -l axi_dma_v7_1_36 -l xlconstant_v1_1_10 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_register_slice_v2_1_35 -l xlconcat_v2_1_7 \
"../../../../sys.gen/sources_1/bd/design_1/ipshared/d800/hdl/sc_mmu_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib  -incr "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/7711/hdl" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/f0b6/hdl/verilog" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/a8e4/hdl/verilog" "+incdir+C:/Xilinx/2025.1/Vivado/data/rsb/busdef" "+incdir+C:/Xilinx/2025.1/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xpm -l axi_infrastructure_v1_1_0 -l axi_vip_v1_1_21 -l zynq_ultra_ps_e_vip_v1_0_21 -l xil_defaultlib -l axi_datamover_v5_1_37 -l axi_sg_v4_1_21 -l axi_dma_v7_1_36 -l xlconstant_v1_1_10 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_register_slice_v2_1_35 -l xlconcat_v2_1_7 \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_17/sim/bd_afc3_s00mmu_0.sv" \

vlog -work smartconnect_v1_0  -incr "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/7711/hdl" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/f0b6/hdl/verilog" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/a8e4/hdl/verilog" "+incdir+C:/Xilinx/2025.1/Vivado/data/rsb/busdef" "+incdir+C:/Xilinx/2025.1/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xpm -l axi_infrastructure_v1_1_0 -l axi_vip_v1_1_21 -l zynq_ultra_ps_e_vip_v1_0_21 -l xil_defaultlib -l axi_datamover_v5_1_37 -l axi_sg_v4_1_21 -l axi_dma_v7_1_36 -l xlconstant_v1_1_10 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_register_slice_v2_1_35 -l xlconcat_v2_1_7 \
"../../../../sys.gen/sources_1/bd/design_1/ipshared/2da8/hdl/sc_transaction_regulator_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib  -incr "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/7711/hdl" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/f0b6/hdl/verilog" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/a8e4/hdl/verilog" "+incdir+C:/Xilinx/2025.1/Vivado/data/rsb/busdef" "+incdir+C:/Xilinx/2025.1/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xpm -l axi_infrastructure_v1_1_0 -l axi_vip_v1_1_21 -l zynq_ultra_ps_e_vip_v1_0_21 -l xil_defaultlib -l axi_datamover_v5_1_37 -l axi_sg_v4_1_21 -l axi_dma_v7_1_36 -l xlconstant_v1_1_10 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_register_slice_v2_1_35 -l xlconcat_v2_1_7 \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_18/sim/bd_afc3_s00tr_0.sv" \

vlog -work smartconnect_v1_0  -incr "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/7711/hdl" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/f0b6/hdl/verilog" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/a8e4/hdl/verilog" "+incdir+C:/Xilinx/2025.1/Vivado/data/rsb/busdef" "+incdir+C:/Xilinx/2025.1/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xpm -l axi_infrastructure_v1_1_0 -l axi_vip_v1_1_21 -l zynq_ultra_ps_e_vip_v1_0_21 -l xil_defaultlib -l axi_datamover_v5_1_37 -l axi_sg_v4_1_21 -l axi_dma_v7_1_36 -l xlconstant_v1_1_10 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_register_slice_v2_1_35 -l xlconcat_v2_1_7 \
"../../../../sys.gen/sources_1/bd/design_1/ipshared/dce3/hdl/sc_si_converter_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib  -incr "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/7711/hdl" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/f0b6/hdl/verilog" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/a8e4/hdl/verilog" "+incdir+C:/Xilinx/2025.1/Vivado/data/rsb/busdef" "+incdir+C:/Xilinx/2025.1/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xpm -l axi_infrastructure_v1_1_0 -l axi_vip_v1_1_21 -l zynq_ultra_ps_e_vip_v1_0_21 -l xil_defaultlib -l axi_datamover_v5_1_37 -l axi_sg_v4_1_21 -l axi_dma_v7_1_36 -l xlconstant_v1_1_10 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_register_slice_v2_1_35 -l xlconcat_v2_1_7 \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_19/sim/bd_afc3_s00sic_0.sv" \

vlog -work smartconnect_v1_0  -incr "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/7711/hdl" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/f0b6/hdl/verilog" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/a8e4/hdl/verilog" "+incdir+C:/Xilinx/2025.1/Vivado/data/rsb/busdef" "+incdir+C:/Xilinx/2025.1/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xpm -l axi_infrastructure_v1_1_0 -l axi_vip_v1_1_21 -l zynq_ultra_ps_e_vip_v1_0_21 -l xil_defaultlib -l axi_datamover_v5_1_37 -l axi_sg_v4_1_21 -l axi_dma_v7_1_36 -l xlconstant_v1_1_10 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_register_slice_v2_1_35 -l xlconcat_v2_1_7 \
"../../../../sys.gen/sources_1/bd/design_1/ipshared/cef3/hdl/sc_axi2sc_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib  -incr "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/7711/hdl" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/f0b6/hdl/verilog" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/a8e4/hdl/verilog" "+incdir+C:/Xilinx/2025.1/Vivado/data/rsb/busdef" "+incdir+C:/Xilinx/2025.1/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xpm -l axi_infrastructure_v1_1_0 -l axi_vip_v1_1_21 -l zynq_ultra_ps_e_vip_v1_0_21 -l xil_defaultlib -l axi_datamover_v5_1_37 -l axi_sg_v4_1_21 -l axi_dma_v7_1_36 -l xlconstant_v1_1_10 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_register_slice_v2_1_35 -l xlconcat_v2_1_7 \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_20/sim/bd_afc3_s00a2s_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_21/sim/bd_afc3_sarn_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_22/sim/bd_afc3_srn_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_23/sim/bd_afc3_sawn_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_24/sim/bd_afc3_swn_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_25/sim/bd_afc3_sbn_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_26/sim/bd_afc3_s01mmu_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_27/sim/bd_afc3_s01tr_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_28/sim/bd_afc3_s01sic_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_29/sim/bd_afc3_s01a2s_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_30/sim/bd_afc3_sarn_1.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_31/sim/bd_afc3_srn_1.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_32/sim/bd_afc3_sawn_1.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_33/sim/bd_afc3_swn_1.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_34/sim/bd_afc3_sbn_1.sv" \

vlog -work smartconnect_v1_0  -incr "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/7711/hdl" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/f0b6/hdl/verilog" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/a8e4/hdl/verilog" "+incdir+C:/Xilinx/2025.1/Vivado/data/rsb/busdef" "+incdir+C:/Xilinx/2025.1/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xpm -l axi_infrastructure_v1_1_0 -l axi_vip_v1_1_21 -l zynq_ultra_ps_e_vip_v1_0_21 -l xil_defaultlib -l axi_datamover_v5_1_37 -l axi_sg_v4_1_21 -l axi_dma_v7_1_36 -l xlconstant_v1_1_10 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_register_slice_v2_1_35 -l xlconcat_v2_1_7 \
"../../../../sys.gen/sources_1/bd/design_1/ipshared/7f4f/hdl/sc_sc2axi_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib  -incr "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/7711/hdl" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/f0b6/hdl/verilog" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/a8e4/hdl/verilog" "+incdir+C:/Xilinx/2025.1/Vivado/data/rsb/busdef" "+incdir+C:/Xilinx/2025.1/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xpm -l axi_infrastructure_v1_1_0 -l axi_vip_v1_1_21 -l zynq_ultra_ps_e_vip_v1_0_21 -l xil_defaultlib -l axi_datamover_v5_1_37 -l axi_sg_v4_1_21 -l axi_dma_v7_1_36 -l xlconstant_v1_1_10 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_register_slice_v2_1_35 -l xlconcat_v2_1_7 \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_35/sim/bd_afc3_m00s2a_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_36/sim/bd_afc3_m00arn_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_37/sim/bd_afc3_m00rn_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_38/sim/bd_afc3_m00awn_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_39/sim/bd_afc3_m00wn_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_40/sim/bd_afc3_m00bn_0.sv" \

vlog -work smartconnect_v1_0  -incr "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/7711/hdl" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/f0b6/hdl/verilog" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/a8e4/hdl/verilog" "+incdir+C:/Xilinx/2025.1/Vivado/data/rsb/busdef" "+incdir+C:/Xilinx/2025.1/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xpm -l axi_infrastructure_v1_1_0 -l axi_vip_v1_1_21 -l zynq_ultra_ps_e_vip_v1_0_21 -l xil_defaultlib -l axi_datamover_v5_1_37 -l axi_sg_v4_1_21 -l axi_dma_v7_1_36 -l xlconstant_v1_1_10 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_register_slice_v2_1_35 -l xlconcat_v2_1_7 \
"../../../../sys.gen/sources_1/bd/design_1/ipshared/0133/hdl/sc_exit_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib  -incr "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/7711/hdl" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/f0b6/hdl/verilog" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/a8e4/hdl/verilog" "+incdir+C:/Xilinx/2025.1/Vivado/data/rsb/busdef" "+incdir+C:/Xilinx/2025.1/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xpm -l axi_infrastructure_v1_1_0 -l axi_vip_v1_1_21 -l zynq_ultra_ps_e_vip_v1_0_21 -l xil_defaultlib -l axi_datamover_v5_1_37 -l axi_sg_v4_1_21 -l axi_dma_v7_1_36 -l xlconstant_v1_1_10 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_register_slice_v2_1_35 -l xlconcat_v2_1_7 \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_41/sim/bd_afc3_m00e_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_42/sim/bd_afc3_m01s2a_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_43/sim/bd_afc3_m01arn_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_44/sim/bd_afc3_m01rn_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_45/sim/bd_afc3_m01awn_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_46/sim/bd_afc3_m01wn_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_47/sim/bd_afc3_m01bn_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_48/sim/bd_afc3_m01e_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_49/sim/bd_afc3_m02s2a_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_50/sim/bd_afc3_m02arn_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_51/sim/bd_afc3_m02rn_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_52/sim/bd_afc3_m02awn_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_53/sim/bd_afc3_m02wn_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_54/sim/bd_afc3_m02bn_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_55/sim/bd_afc3_m02e_0.sv" \

vlog -work xil_defaultlib  -incr -v2k5 "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/7711/hdl" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/f0b6/hdl/verilog" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/a8e4/hdl/verilog" "+incdir+C:/Xilinx/2025.1/Vivado/data/rsb/busdef" "+incdir+C:/Xilinx/2025.1/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xpm -l axi_infrastructure_v1_1_0 -l axi_vip_v1_1_21 -l zynq_ultra_ps_e_vip_v1_0_21 -l xil_defaultlib -l axi_datamover_v5_1_37 -l axi_sg_v4_1_21 -l axi_dma_v7_1_36 -l xlconstant_v1_1_10 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_register_slice_v2_1_35 -l xlconcat_v2_1_7 \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/sim/bd_afc3.v" \

vlog -work axi_register_slice_v2_1_35  -incr -v2k5 "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/7711/hdl" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/f0b6/hdl/verilog" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/a8e4/hdl/verilog" "+incdir+C:/Xilinx/2025.1/Vivado/data/rsb/busdef" "+incdir+C:/Xilinx/2025.1/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xpm -l axi_infrastructure_v1_1_0 -l axi_vip_v1_1_21 -l zynq_ultra_ps_e_vip_v1_0_21 -l xil_defaultlib -l axi_datamover_v5_1_37 -l axi_sg_v4_1_21 -l axi_dma_v7_1_36 -l xlconstant_v1_1_10 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_register_slice_v2_1_35 -l xlconcat_v2_1_7 \
"../../../../sys.gen/sources_1/bd/design_1/ipshared/c5b7/hdl/axi_register_slice_v2_1_vl_rfs.v" \

vlog -work xil_defaultlib  -incr "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/7711/hdl" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/f0b6/hdl/verilog" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/a8e4/hdl/verilog" "+incdir+C:/Xilinx/2025.1/Vivado/data/rsb/busdef" "+incdir+C:/Xilinx/2025.1/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xpm -l axi_infrastructure_v1_1_0 -l axi_vip_v1_1_21 -l zynq_ultra_ps_e_vip_v1_0_21 -l xil_defaultlib -l axi_datamover_v5_1_37 -l axi_sg_v4_1_21 -l axi_dma_v7_1_36 -l xlconstant_v1_1_10 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_register_slice_v2_1_35 -l xlconcat_v2_1_7 \
"../../../bd/design_1/ip/design_1_axi_smc_0/sim/design_1_axi_smc_0.sv" \

vcom -work xil_defaultlib -93  -incr \
"../../../bd/design_1/ip/design_1_rst_ps8_0_99M_0/sim/design_1_rst_ps8_0_99M_0.vhd" \
"../../../bd/design_1/ip/design_1_axi_dma_1_0/sim/design_1_axi_dma_1_0.vhd" \

vlog -work xlconcat_v2_1_7  -incr -v2k5 "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/7711/hdl" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/f0b6/hdl/verilog" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/a8e4/hdl/verilog" "+incdir+C:/Xilinx/2025.1/Vivado/data/rsb/busdef" "+incdir+C:/Xilinx/2025.1/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xpm -l axi_infrastructure_v1_1_0 -l axi_vip_v1_1_21 -l zynq_ultra_ps_e_vip_v1_0_21 -l xil_defaultlib -l axi_datamover_v5_1_37 -l axi_sg_v4_1_21 -l axi_dma_v7_1_36 -l xlconstant_v1_1_10 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_register_slice_v2_1_35 -l xlconcat_v2_1_7 \
"../../../../sys.srcs/sources_1/bd/design_1/ipshared/9c1a/hdl/xlconcat_v2_1_vl_rfs.v" \

vlog -work xil_defaultlib  -incr -v2k5 "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/7711/hdl" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/f0b6/hdl/verilog" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/a8e4/hdl/verilog" "+incdir+C:/Xilinx/2025.1/Vivado/data/rsb/busdef" "+incdir+C:/Xilinx/2025.1/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xpm -l axi_infrastructure_v1_1_0 -l axi_vip_v1_1_21 -l zynq_ultra_ps_e_vip_v1_0_21 -l xil_defaultlib -l axi_datamover_v5_1_37 -l axi_sg_v4_1_21 -l axi_dma_v7_1_36 -l xlconstant_v1_1_10 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_register_slice_v2_1_35 -l xlconcat_v2_1_7 \
"../../../bd/design_1/ip/design_1_xlconcat_0_0/sim/design_1_xlconcat_0_0.v" \
"../../../bd/design_1/ip/design_1_smartconnect_0_0/bd_0/ip/ip_0/sim/bd_48ac_one_0.v" \

vcom -work xil_defaultlib -93  -incr \
"../../../bd/design_1/ip/design_1_smartconnect_0_0/bd_0/ip/ip_1/sim/bd_48ac_psr_aclk_0.vhd" \

vlog -work xil_defaultlib  -incr "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/7711/hdl" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/f0b6/hdl/verilog" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/a8e4/hdl/verilog" "+incdir+C:/Xilinx/2025.1/Vivado/data/rsb/busdef" "+incdir+C:/Xilinx/2025.1/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xpm -l axi_infrastructure_v1_1_0 -l axi_vip_v1_1_21 -l zynq_ultra_ps_e_vip_v1_0_21 -l xil_defaultlib -l axi_datamover_v5_1_37 -l axi_sg_v4_1_21 -l axi_dma_v7_1_36 -l xlconstant_v1_1_10 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_register_slice_v2_1_35 -l xlconcat_v2_1_7 \
"../../../bd/design_1/ip/design_1_smartconnect_0_0/bd_0/ip/ip_2/sim/bd_48ac_arsw_0.sv" \
"../../../bd/design_1/ip/design_1_smartconnect_0_0/bd_0/ip/ip_3/sim/bd_48ac_rsw_0.sv" \
"../../../bd/design_1/ip/design_1_smartconnect_0_0/bd_0/ip/ip_4/sim/bd_48ac_awsw_0.sv" \
"../../../bd/design_1/ip/design_1_smartconnect_0_0/bd_0/ip/ip_5/sim/bd_48ac_wsw_0.sv" \
"../../../bd/design_1/ip/design_1_smartconnect_0_0/bd_0/ip/ip_6/sim/bd_48ac_bsw_0.sv" \
"../../../bd/design_1/ip/design_1_smartconnect_0_0/bd_0/ip/ip_7/sim/bd_48ac_s00mmu_0.sv" \
"../../../bd/design_1/ip/design_1_smartconnect_0_0/bd_0/ip/ip_8/sim/bd_48ac_s00tr_0.sv" \
"../../../bd/design_1/ip/design_1_smartconnect_0_0/bd_0/ip/ip_9/sim/bd_48ac_s00sic_0.sv" \
"../../../bd/design_1/ip/design_1_smartconnect_0_0/bd_0/ip/ip_10/sim/bd_48ac_s00a2s_0.sv" \
"../../../bd/design_1/ip/design_1_smartconnect_0_0/bd_0/ip/ip_11/sim/bd_48ac_sarn_0.sv" \
"../../../bd/design_1/ip/design_1_smartconnect_0_0/bd_0/ip/ip_12/sim/bd_48ac_srn_0.sv" \
"../../../bd/design_1/ip/design_1_smartconnect_0_0/bd_0/ip/ip_13/sim/bd_48ac_m00s2a_0.sv" \
"../../../bd/design_1/ip/design_1_smartconnect_0_0/bd_0/ip/ip_14/sim/bd_48ac_m00arn_0.sv" \
"../../../bd/design_1/ip/design_1_smartconnect_0_0/bd_0/ip/ip_15/sim/bd_48ac_m00rn_0.sv" \
"../../../bd/design_1/ip/design_1_smartconnect_0_0/bd_0/ip/ip_16/sim/bd_48ac_m00e_0.sv" \

vlog -work xil_defaultlib  -incr -v2k5 "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/7711/hdl" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/f0b6/hdl/verilog" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/a8e4/hdl/verilog" "+incdir+C:/Xilinx/2025.1/Vivado/data/rsb/busdef" "+incdir+C:/Xilinx/2025.1/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xpm -l axi_infrastructure_v1_1_0 -l axi_vip_v1_1_21 -l zynq_ultra_ps_e_vip_v1_0_21 -l xil_defaultlib -l axi_datamover_v5_1_37 -l axi_sg_v4_1_21 -l axi_dma_v7_1_36 -l xlconstant_v1_1_10 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_register_slice_v2_1_35 -l xlconcat_v2_1_7 \
"../../../bd/design_1/ip/design_1_smartconnect_0_0/bd_0/sim/bd_48ac.v" \

vlog -work xil_defaultlib  -incr "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/7711/hdl" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/f0b6/hdl/verilog" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/a8e4/hdl/verilog" "+incdir+C:/Xilinx/2025.1/Vivado/data/rsb/busdef" "+incdir+C:/Xilinx/2025.1/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xpm -l axi_infrastructure_v1_1_0 -l axi_vip_v1_1_21 -l zynq_ultra_ps_e_vip_v1_0_21 -l xil_defaultlib -l axi_datamover_v5_1_37 -l axi_sg_v4_1_21 -l axi_dma_v7_1_36 -l xlconstant_v1_1_10 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_register_slice_v2_1_35 -l xlconcat_v2_1_7 \
"../../../bd/design_1/ip/design_1_smartconnect_0_0/sim/design_1_smartconnect_0_0.sv" \

vlog -work xil_defaultlib  -incr -v2k5 "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/7711/hdl" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/f0b6/hdl/verilog" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/a8e4/hdl/verilog" "+incdir+C:/Xilinx/2025.1/Vivado/data/rsb/busdef" "+incdir+C:/Xilinx/2025.1/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xpm -l axi_infrastructure_v1_1_0 -l axi_vip_v1_1_21 -l zynq_ultra_ps_e_vip_v1_0_21 -l xil_defaultlib -l axi_datamover_v5_1_37 -l axi_sg_v4_1_21 -l axi_dma_v7_1_36 -l xlconstant_v1_1_10 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_register_slice_v2_1_35 -l xlconcat_v2_1_7 \
"../../../bd/design_1/ip/design_1_smartconnect_0_1/bd_0/ip/ip_0/sim/bd_886d_one_0.v" \

vcom -work xil_defaultlib -93  -incr \
"../../../bd/design_1/ip/design_1_smartconnect_0_1/bd_0/ip/ip_1/sim/bd_886d_psr_aclk_0.vhd" \

vlog -work xil_defaultlib  -incr "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/7711/hdl" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/f0b6/hdl/verilog" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/a8e4/hdl/verilog" "+incdir+C:/Xilinx/2025.1/Vivado/data/rsb/busdef" "+incdir+C:/Xilinx/2025.1/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xpm -l axi_infrastructure_v1_1_0 -l axi_vip_v1_1_21 -l zynq_ultra_ps_e_vip_v1_0_21 -l xil_defaultlib -l axi_datamover_v5_1_37 -l axi_sg_v4_1_21 -l axi_dma_v7_1_36 -l xlconstant_v1_1_10 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_register_slice_v2_1_35 -l xlconcat_v2_1_7 \
"../../../bd/design_1/ip/design_1_smartconnect_0_1/bd_0/ip/ip_2/sim/bd_886d_arsw_0.sv" \
"../../../bd/design_1/ip/design_1_smartconnect_0_1/bd_0/ip/ip_3/sim/bd_886d_rsw_0.sv" \
"../../../bd/design_1/ip/design_1_smartconnect_0_1/bd_0/ip/ip_4/sim/bd_886d_awsw_0.sv" \
"../../../bd/design_1/ip/design_1_smartconnect_0_1/bd_0/ip/ip_5/sim/bd_886d_wsw_0.sv" \
"../../../bd/design_1/ip/design_1_smartconnect_0_1/bd_0/ip/ip_6/sim/bd_886d_bsw_0.sv" \
"../../../bd/design_1/ip/design_1_smartconnect_0_1/bd_0/ip/ip_7/sim/bd_886d_s00mmu_0.sv" \
"../../../bd/design_1/ip/design_1_smartconnect_0_1/bd_0/ip/ip_8/sim/bd_886d_s00tr_0.sv" \
"../../../bd/design_1/ip/design_1_smartconnect_0_1/bd_0/ip/ip_9/sim/bd_886d_s00sic_0.sv" \
"../../../bd/design_1/ip/design_1_smartconnect_0_1/bd_0/ip/ip_10/sim/bd_886d_s00a2s_0.sv" \
"../../../bd/design_1/ip/design_1_smartconnect_0_1/bd_0/ip/ip_11/sim/bd_886d_sarn_0.sv" \
"../../../bd/design_1/ip/design_1_smartconnect_0_1/bd_0/ip/ip_12/sim/bd_886d_srn_0.sv" \
"../../../bd/design_1/ip/design_1_smartconnect_0_1/bd_0/ip/ip_13/sim/bd_886d_m00s2a_0.sv" \
"../../../bd/design_1/ip/design_1_smartconnect_0_1/bd_0/ip/ip_14/sim/bd_886d_m00arn_0.sv" \
"../../../bd/design_1/ip/design_1_smartconnect_0_1/bd_0/ip/ip_15/sim/bd_886d_m00rn_0.sv" \
"../../../bd/design_1/ip/design_1_smartconnect_0_1/bd_0/ip/ip_16/sim/bd_886d_m00e_0.sv" \

vlog -work xil_defaultlib  -incr -v2k5 "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/7711/hdl" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/f0b6/hdl/verilog" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/a8e4/hdl/verilog" "+incdir+C:/Xilinx/2025.1/Vivado/data/rsb/busdef" "+incdir+C:/Xilinx/2025.1/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xpm -l axi_infrastructure_v1_1_0 -l axi_vip_v1_1_21 -l zynq_ultra_ps_e_vip_v1_0_21 -l xil_defaultlib -l axi_datamover_v5_1_37 -l axi_sg_v4_1_21 -l axi_dma_v7_1_36 -l xlconstant_v1_1_10 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_register_slice_v2_1_35 -l xlconcat_v2_1_7 \
"../../../bd/design_1/ip/design_1_smartconnect_0_1/bd_0/sim/bd_886d.v" \

vlog -work xil_defaultlib  -incr "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/7711/hdl" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/f0b6/hdl/verilog" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/a8e4/hdl/verilog" "+incdir+C:/Xilinx/2025.1/Vivado/data/rsb/busdef" "+incdir+C:/Xilinx/2025.1/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xpm -l axi_infrastructure_v1_1_0 -l axi_vip_v1_1_21 -l zynq_ultra_ps_e_vip_v1_0_21 -l xil_defaultlib -l axi_datamover_v5_1_37 -l axi_sg_v4_1_21 -l axi_dma_v7_1_36 -l xlconstant_v1_1_10 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_register_slice_v2_1_35 -l xlconcat_v2_1_7 \
"../../../bd/design_1/ip/design_1_smartconnect_0_1/sim/design_1_smartconnect_0_1.sv" \

vlog -work xil_defaultlib  -incr -v2k5 "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/7711/hdl" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/f0b6/hdl/verilog" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/a8e4/hdl/verilog" "+incdir+C:/Xilinx/2025.1/Vivado/data/rsb/busdef" "+incdir+C:/Xilinx/2025.1/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xpm -l axi_infrastructure_v1_1_0 -l axi_vip_v1_1_21 -l zynq_ultra_ps_e_vip_v1_0_21 -l xil_defaultlib -l axi_datamover_v5_1_37 -l axi_sg_v4_1_21 -l axi_dma_v7_1_36 -l xlconstant_v1_1_10 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_register_slice_v2_1_35 -l xlconcat_v2_1_7 \
"../../../bd/design_1/ip/design_1_smartconnect_0_2/bd_0/ip/ip_0/sim/bd_892d_one_0.v" \

vcom -work xil_defaultlib -93  -incr \
"../../../bd/design_1/ip/design_1_smartconnect_0_2/bd_0/ip/ip_1/sim/bd_892d_psr_aclk_0.vhd" \

vlog -work xil_defaultlib  -incr "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/7711/hdl" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/f0b6/hdl/verilog" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/a8e4/hdl/verilog" "+incdir+C:/Xilinx/2025.1/Vivado/data/rsb/busdef" "+incdir+C:/Xilinx/2025.1/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xpm -l axi_infrastructure_v1_1_0 -l axi_vip_v1_1_21 -l zynq_ultra_ps_e_vip_v1_0_21 -l xil_defaultlib -l axi_datamover_v5_1_37 -l axi_sg_v4_1_21 -l axi_dma_v7_1_36 -l xlconstant_v1_1_10 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_register_slice_v2_1_35 -l xlconcat_v2_1_7 \
"../../../bd/design_1/ip/design_1_smartconnect_0_2/bd_0/ip/ip_2/sim/bd_892d_arsw_0.sv" \
"../../../bd/design_1/ip/design_1_smartconnect_0_2/bd_0/ip/ip_3/sim/bd_892d_rsw_0.sv" \
"../../../bd/design_1/ip/design_1_smartconnect_0_2/bd_0/ip/ip_4/sim/bd_892d_awsw_0.sv" \
"../../../bd/design_1/ip/design_1_smartconnect_0_2/bd_0/ip/ip_5/sim/bd_892d_wsw_0.sv" \
"../../../bd/design_1/ip/design_1_smartconnect_0_2/bd_0/ip/ip_6/sim/bd_892d_bsw_0.sv" \
"../../../bd/design_1/ip/design_1_smartconnect_0_2/bd_0/ip/ip_7/sim/bd_892d_s00mmu_0.sv" \
"../../../bd/design_1/ip/design_1_smartconnect_0_2/bd_0/ip/ip_8/sim/bd_892d_s00tr_0.sv" \
"../../../bd/design_1/ip/design_1_smartconnect_0_2/bd_0/ip/ip_9/sim/bd_892d_s00sic_0.sv" \
"../../../bd/design_1/ip/design_1_smartconnect_0_2/bd_0/ip/ip_10/sim/bd_892d_s00a2s_0.sv" \
"../../../bd/design_1/ip/design_1_smartconnect_0_2/bd_0/ip/ip_11/sim/bd_892d_sawn_0.sv" \
"../../../bd/design_1/ip/design_1_smartconnect_0_2/bd_0/ip/ip_12/sim/bd_892d_swn_0.sv" \
"../../../bd/design_1/ip/design_1_smartconnect_0_2/bd_0/ip/ip_13/sim/bd_892d_sbn_0.sv" \
"../../../bd/design_1/ip/design_1_smartconnect_0_2/bd_0/ip/ip_14/sim/bd_892d_m00s2a_0.sv" \
"../../../bd/design_1/ip/design_1_smartconnect_0_2/bd_0/ip/ip_15/sim/bd_892d_m00awn_0.sv" \
"../../../bd/design_1/ip/design_1_smartconnect_0_2/bd_0/ip/ip_16/sim/bd_892d_m00wn_0.sv" \
"../../../bd/design_1/ip/design_1_smartconnect_0_2/bd_0/ip/ip_17/sim/bd_892d_m00bn_0.sv" \
"../../../bd/design_1/ip/design_1_smartconnect_0_2/bd_0/ip/ip_18/sim/bd_892d_m00e_0.sv" \

vlog -work xil_defaultlib  -incr -v2k5 "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/7711/hdl" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/f0b6/hdl/verilog" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/a8e4/hdl/verilog" "+incdir+C:/Xilinx/2025.1/Vivado/data/rsb/busdef" "+incdir+C:/Xilinx/2025.1/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xpm -l axi_infrastructure_v1_1_0 -l axi_vip_v1_1_21 -l zynq_ultra_ps_e_vip_v1_0_21 -l xil_defaultlib -l axi_datamover_v5_1_37 -l axi_sg_v4_1_21 -l axi_dma_v7_1_36 -l xlconstant_v1_1_10 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_register_slice_v2_1_35 -l xlconcat_v2_1_7 \
"../../../bd/design_1/ip/design_1_smartconnect_0_2/bd_0/sim/bd_892d.v" \

vlog -work xil_defaultlib  -incr "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/7711/hdl" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/f0b6/hdl/verilog" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/a8e4/hdl/verilog" "+incdir+C:/Xilinx/2025.1/Vivado/data/rsb/busdef" "+incdir+C:/Xilinx/2025.1/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xpm -l axi_infrastructure_v1_1_0 -l axi_vip_v1_1_21 -l zynq_ultra_ps_e_vip_v1_0_21 -l xil_defaultlib -l axi_datamover_v5_1_37 -l axi_sg_v4_1_21 -l axi_dma_v7_1_36 -l xlconstant_v1_1_10 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_register_slice_v2_1_35 -l xlconcat_v2_1_7 \
"../../../bd/design_1/ip/design_1_smartconnect_0_2/sim/design_1_smartconnect_0_2.sv" \

vlog -work xil_defaultlib  -incr -v2k5 "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/7711/hdl" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/f0b6/hdl/verilog" "+incdir+../../../../sys.gen/sources_1/bd/design_1/ipshared/a8e4/hdl/verilog" "+incdir+C:/Xilinx/2025.1/Vivado/data/rsb/busdef" "+incdir+C:/Xilinx/2025.1/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xpm -l axi_infrastructure_v1_1_0 -l axi_vip_v1_1_21 -l zynq_ultra_ps_e_vip_v1_0_21 -l xil_defaultlib -l axi_datamover_v5_1_37 -l axi_sg_v4_1_21 -l axi_dma_v7_1_36 -l xlconstant_v1_1_10 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_register_slice_v2_1_35 -l xlconcat_v2_1_7 \
"../../../bd/design_1/ipshared/c008/hdl/myip_slave_lite_v1_0_S00_AXI.v" \
"../../../bd/design_1/ipshared/c008/src/accelerator_top.v" \
"../../../bd/design_1/ipshared/c008/src/controller.v" \
"../../../bd/design_1/ipshared/c008/src/input_fifo.v" \
"../../../bd/design_1/ipshared/c008/src/output_fifo.v" \
"../../../bd/design_1/ipshared/c008/src/pe.v" \
"../../../bd/design_1/ipshared/c008/src/pe_grid.v" \
"../../../bd/design_1/ipshared/c008/src/systolic_array.v" \
"../../../bd/design_1/ipshared/c008/src/tdp_bram.v" \
"../../../bd/design_1/ipshared/c008/src/tilling_agu.v" \
"../../../bd/design_1/ipshared/c008/src/weight_fifo.v" \
"../../../bd/design_1/ipshared/c008/hdl/myip.v" \
"../../../bd/design_1/ip/design_1_myip_0_0/sim/design_1_myip_0_0.v" \
"../../../bd/design_1/sim/design_1.v" \

vlog -work xil_defaultlib \
"glbl.v"

